@IsTest
public with sharing class RevoSiteTransactionTest {

    @TestSetup
    static void setup() {
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
    }
    
    @IsTest
    static void testTransaction_Success() {
        // Criar pagamento e oportunidade
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);
        
        // Buscar o pagamento criado
        Pagamento__c pagamento = [SELECT Id FROM Pagamento__c WHERE OportunidadeOrigem__c = :idsOportunidade[0] LIMIT 1];
        
        // Primeiro, chamar o payment view para obter os dados do pagamento
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/payment/view', 'POST');
        
        RevoSitePaymentView.PaymentView viewParam = new RevoSitePaymentView.PaymentView();
        viewParam.salesforcePaymentId = pagamento.Id;
        
        RevoSitePaymentView.view(viewParam);
        
        // Deserializar resposta do payment view
        String responseBody = RestContext.response.responseBody.toString();
        RevoSitePaymentView.PaymentViewResult paymentViewResult = (RevoSitePaymentView.PaymentViewResult) JSON.deserialize(responseBody, RevoSitePaymentView.PaymentViewResult.class);
        
        // Verificar se o payment view retornou dados válidos
        System.assertNotEquals(null, paymentViewResult, 'Payment view deve retornar dados');
        System.assertEquals('Pendente', paymentViewResult.paymentStatus, 'Status do pagamento deve ser Pendente');
        System.assertNotEquals(0, paymentViewResult.totalPending, 'Total pendente deve ser maior que zero');
        
        // Agora configurar contexto REST para a transação
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/payment/transaction', 'POST');
        
        // Criar parâmetro de transação usando dados do payment view
        RevoSiteTransaction.RevoSiteUserTransaction transactionParam = new RevoSiteTransaction.RevoSiteUserTransaction();
        transactionParam.salesforcePaymentId = pagamento.Id;
        transactionParam.gatewayName = 'TestGateway';
        transactionParam.paymentMethod = 'Cartão de Crédito';
        transactionParam.transactionId = 'TXN-' + String.valueOf(System.currentTimeMillis());
        transactionParam.transactionStatus = 'Authorized';
        transactionParam.gatewayMessage = 'Transaction authorized successfully';
        transactionParam.transactionValue = paymentViewResult.totalPending; // Usar o valor total pendente do payment view
        
        Test.startTest();
        RevoSiteTransaction.transaction(transactionParam);
        Test.stopTest();
                
        // Verificar se a transação foi registrada no banco
        List<TransacaoGateway__c> transacoes = [
            SELECT Id, Pagamento__c, NomeGateway__c,  
                   IdTransacaoGateway__c, StatusGateway__c, 
                   ValorTransacao__c
            FROM TransacaoGateway__c 
            WHERE Pagamento__c = :pagamento.Id
        ];
        
        System.assertEquals(1, transacoes.size(), 'Deve ter uma transação registrada');
        System.assertEquals('TestGateway', transacoes[0].NomeGateway__c, 'Nome do gateway deve ser TestGateway');
        System.assertEquals(transactionParam.transactionId, transacoes[0].IdTransacaoGateway__c, 'ID da transação deve corresponder ao enviado');
        System.assertEquals('Authorized', transacoes[0].StatusGateway__c, 'Status da transação deve ser Authorized');
        System.assertEquals(paymentViewResult.totalPending, transacoes[0].ValorTransacao__c, 'Valor da transação deve ser igual ao total pendente do payment view');
        
        // Verificar se o status do pagamento foi atualizado para 'Efetuado'
        Pagamento__c pagamentoAtualizado = [SELECT Id, StatusPagamento__c, ValorPagamento__c FROM Pagamento__c WHERE Id = :pagamento.Id];
        System.assertEquals('Efetuado', pagamentoAtualizado.StatusPagamento__c, 'Status do pagamento deve ser Efetuado');
        System.assertEquals(paymentViewResult.totalPending, pagamentoAtualizado.ValorPagamento__c, 'Valor do pagamento deve ser igual ao total pendente do payment view');
    }
}