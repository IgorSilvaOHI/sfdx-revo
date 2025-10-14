@IsTest
public with sharing class FlowCriarPagamentoOportunidadeTest {
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void testFlowCriarPagamentoShuttleSeat(){
        
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        Test.startTest();
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);
        Test.stopTest();
        // Verificar se o pagamento foi criado corretamente
        List<Pagamento__c> pagamentos = [SELECT Id, OportunidadeOrigem__c, StatusPagamento__c 
                                        FROM Pagamento__c 
                                        WHERE OportunidadeOrigem__c = :idsOportunidade[0]];
        System.assertEquals(1, pagamentos.size(), 'Deve existir exatamente um pagamento para a oportunidade');
        System.assertEquals(idsOportunidade[0], pagamentos[0].OportunidadeOrigem__c, 'O pagamento deve estar vinculado à oportunidade correta');
        System.assertEquals('Pendente', pagamentos[0].StatusPagamento__c, 'O status do pagamento deve ser Pendente');
    }
}