@isTest
public with sharing class FlowPagaServicoTest  {
    
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);
        FlowCriarPagamentoOportunidade.criarPagamentoOportunidade(idsOportunidade);        
    }

    @IsTest
    static void testFlowPagaServicoShuttleSeat(){
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};


        Pagamento__c pagamento = [SELECT Id, ValorPagamento__c FROM Pagamento__c WHERE OportunidadeOrigem__c = :idsOportunidade[0] LIMIT 1];
        pagamento.ValorPagamento__c = 100000;
        update pagamento;

        List<Empenho__c> empenhos = [SELECT Id FROM Empenho__c WHERE Pagamento__c = :pagamento.Id];
        delete empenhos;
        
        FlowPagaServico.FlowPagaServicoChamada chamada = new FlowPagaServico.FlowPagaServicoChamada();
        chamada.pagamentoId = pagamento.Id;
        chamada.servicoIds = new List<Id>{[SELECT Id FROM Servico__c WHERE Oportunidade__c = :idsOportunidade[0] LIMIT 1].Id};    

        List<String> result = FlowPagaServico.pagaOportunidade(new List<FlowPagaServico.FlowPagaServicoChamada>{chamada});

        System.assertEquals(1, result.size());
        System.assertEquals('SUCESSO', result[0]);
    }
    
}