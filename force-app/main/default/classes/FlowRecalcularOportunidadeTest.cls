@isTest
public with sharing class FlowRecalcularOportunidadeTest  {
    
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void testFlowCriarLinkPagamentoShuttleSeat(){
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};

        List<String> result = FlowRecalcularOportunidade.recalculaOportunidade(idsOportunidade);

        System.assertEquals(1, result.size());
        System.assertEquals('SUCESSO', result[0]);
    }
    
}