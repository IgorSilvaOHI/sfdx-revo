@isTest
public with sharing class FlowCriarLinkPagamentoOportunidadeTest {
    
    // Mock para simular o callout da API de pagamento
    public class PaymentLinkCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            
            // Simula a resposta da API com um link de pagamento
            String responseBody = '{"data":{"payment_link": "https://payment.example.com/pay/123456789"}}';
            response.setBody(responseBody);
            
            return response;
        }
    }
    
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void testFlowCriarLinkPagamentoShuttleSeat(){
        
        // Configurar o mock para o callout
        Test.setMock(HttpCalloutMock.class, new PaymentLinkCalloutMock());
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);
        Test.startTest();
        List<String> resultado = FlowCriarLinkPagamentoOportunidade.criarLinkPagamentoOportunidade(idsOportunidade);
        Test.stopTest();
        
        // Assertions para verificar o sucesso da criação do link de pagamento
        System.assertEquals(1, resultado.size(), 'Deve retornar um resultado para cada oportunidade');
        System.debug(resultado[0]);
        System.assertEquals('SUCESSO', resultado[0], 'O resultado deve ser SUCESSO quando o link de pagamento for criado com sucesso');
        
        // Verificar se o link de pagamento foi criado na oportunidade
        Opportunity oportunidade = [SELECT Id, LinkPagamento__c FROM Opportunity WHERE Id = :idsOportunidade[0]];
        System.assertNotEquals(null, oportunidade.LinkPagamento__c, 'O campo Link de Pagamento deve ser preenchido na oportunidade');
        System.assert(oportunidade.LinkPagamento__c.length() > 0, 'O link de pagamento não pode estar vazio');
        System.assertEquals('https://payment.example.com/pay/123456789', oportunidade.LinkPagamento__c, 'O link de pagamento deve corresponder ao mock');
        
        // Verificar se o pagamento foi criado corretamente
        List<Pagamento__c> pagamentos = [SELECT Id, OportunidadeOrigem__c, StatusPagamento__c 
                                        FROM Pagamento__c 
                                        WHERE OportunidadeOrigem__c = :idsOportunidade[0]];
        System.assertEquals(1, pagamentos.size(), 'Deve existir exatamente um pagamento para a oportunidade');
        System.assertEquals(idsOportunidade[0], pagamentos[0].OportunidadeOrigem__c, 'O pagamento deve estar vinculado à oportunidade correta');
        System.assertEquals('Pendente', pagamentos[0].StatusPagamento__c, 'O status do pagamento deve ser Pendente');
    }
    
    // Mock para simular erro no callout
    public class PaymentLinkErrorCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('Bad Request');
            response.setBody('{"data": {"msg": "Erro na API de pagamento"}}');
            return response;
        }
    }
    
    @IsTest
    static void testFlowCriarLinkPagamentoComErroCallout(){
        
        // Configurar o mock para simular erro no callout
        Test.setMock(HttpCalloutMock.class, new PaymentLinkErrorCalloutMock());
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);
        
        Test.startTest();
        List<String> resultado = FlowCriarLinkPagamentoOportunidade.criarLinkPagamentoOportunidade(idsOportunidade);
        Test.stopTest();
        
        // Verificar que o erro foi capturado e retornado
        System.assertEquals(1, resultado.size(), 'Deve retornar um resultado para cada oportunidade');
        System.assert(resultado[0].contains('Erro ao gerar link de pagamento'), 'Deve retornar mensagem de erro quando o callout falhar');
        
        // Verificar que o link de pagamento não foi criado na oportunidade
        Opportunity oportunidade = [SELECT Id, LinkPagamento__c FROM Opportunity WHERE Id = :idsOportunidade[0]];
        System.assertEquals(null, oportunidade.LinkPagamento__c, 'O campo Link de Pagamento não deve ser preenchido quando houver erro no callout');
    }
}