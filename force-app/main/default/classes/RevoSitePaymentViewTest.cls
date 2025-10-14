@IsTest
public with sharing class RevoSitePaymentViewTest {
    
    @TestSetup
    static void setup() {
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }
    
    @IsTest
    static void testViewPayment_Success() {
        // Configurar contexto REST
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/payment/view', 'POST');
        
        // Criar pagamento e oportunidade
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);
        
        // Buscar o pagamento criado
        Pagamento__c pagamento = [SELECT Id FROM Pagamento__c WHERE OportunidadeOrigem__c = :idsOportunidade[0] LIMIT 1];
        
        // Criar parâmetro de teste
        RevoSitePaymentView.PaymentView param = new RevoSitePaymentView.PaymentView();
        param.salesforcePaymentId = pagamento.Id;
        
        Test.startTest();
        RevoSitePaymentView.view(param);
        Test.stopTest();
        
        // Verificar resposta
        System.assertNotEquals(null, RestContext.response.responseBody, 'Resposta deve ter corpo');
        
        // Deserializar e verificar conteúdo
        String responseBody = RestContext.response.responseBody.toString();
        RevoSitePaymentView.PaymentViewResult result = (RevoSitePaymentView.PaymentViewResult) JSON.deserialize(responseBody, RevoSitePaymentView.PaymentViewResult.class);
        
        // Verificar dados do cliente
        System.assertNotEquals(null, result.customerName, 'Nome do cliente deve estar preenchido');
        System.assertNotEquals(null, result.customerDocument, 'Documento do cliente deve estar preenchido');
        System.assertNotEquals(null, result.customerEmail, 'Email do cliente deve estar preenchido');
        System.assertEquals('Pendente', result.paymentStatus, 'Status do pagamento deve ser Pendente');
        System.assertNotEquals(null, result.servicesToPay, 'Lista de serviços deve estar inicializada');
    }
}