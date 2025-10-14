@IsTest
public with sharing class FlowCancelarOportunidadeTest {
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void cancelarOportunidadeShuttleSeat(){
        
        List<Id> idsOportunidade = new List<Id>{[SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1].Id};
        FlowCheckoutOportunidade.checkoutOportunidade(idsOportunidade);

        Test.startTest();
        List<String> resultados = FlowCancelarOportunidade.cancelarOportunidade(idsOportunidade);
        Test.stopTest();

        // Assert para verificar se o método retornou sucesso
        System.assertEquals(1, resultados.size(), 'Deve retornar um resultado para cada oportunidade');
        System.assertEquals('SUCESSO', resultados[0], 'O cancelamento deve ter sido executado com sucesso');
        
        // Assert para verificar se a oportunidade está realmente cancelada no banco de dados
        Opportunity oportunidadeCancelada = [SELECT Id, StageName, Sistema__c FROM Opportunity WHERE Id = :idsOportunidade[0]];
        System.assertEquals('Cancelado', oportunidadeCancelada.StageName, 'A oportunidade deve estar com StageName = Cancelado');
                
        // Assert para verificar se os serviços relacionados foram deletados
        List<Servico__c> servicosRestantes = [SELECT Id FROM Servico__c WHERE Oportunidade__c = :idsOportunidade[0]];
        System.assertEquals(0, servicosRestantes.size(), 'Todos os serviços da oportunidade devem ter sido deletados');
        
        // Assert para verificar se as promoções da oportunidade foram deletadas
        List<PromocaoOportunidade__c> promocoesRestantes = [SELECT Id FROM PromocaoOportunidade__c WHERE Oportunidade__c = :idsOportunidade[0]];
        System.assertEquals(0, promocoesRestantes.size(), 'Todas as promoções da oportunidade devem ter sido deletadas');
    }

    @IsTest
    static void excluirProdutoOportunidade(){
        Test.startTest();
        delete [SELECT ID FROM ProdutoPassageiro__c];
        delete [SELECT ID FROM PassageiroOportunidade__c];
        Test.stopTest();
    }
}