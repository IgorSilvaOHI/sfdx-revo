@isTest
public with sharing class FlowCheckoutOportunidadeTest {
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void testFlowCriarLinkPagamentoShuttleSeat(){
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        
        Test.startTest();
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        Test.stopTest();
    }
}