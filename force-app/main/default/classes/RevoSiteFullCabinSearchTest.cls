@IsTest
public with sharing class RevoSiteFullCabinSearchTest {
    @TestSetup
    static void setup() {
        RevoTestUtil.setupSiteUser('ws-user');
        RevoTestUtil.ConfigurarProdutosEServicos();
    }

    @IsTest
    static void testSearch() {
        // Cria usuário do site com conta vinculada
        
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/fullcabin/search', 'POST');

        // Monta o payload com webSiteUserId existente
        RevoSiteFullCabinSearch.FullCabinSearch param = new RevoSiteFullCabinSearch.FullCabinSearch();
        param.webSiteUserId = 'ws-user';
        param.departurePointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SBGR' limit 1].Id;
        param.destinationPointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SDOF' limit 1].Id;
        param.flightDate = Date.today().addDays(1);
        param.promotionalCode = 'PROMO10';

        Test.startTest();
        RevoSiteFullCabinSearch.search(param);
        Test.stopTest();
        // Verifica se retornou pelo menos uma configuração de data disponível
        System.assertNotEquals(null, RestContext.response.responseBody, 'Resposta deve ter corpo');
        
        // Deserializa o JSON para verificar se há pelo menos uma configuração disponível
        String responseBody = RestContext.response.responseBody.toString();
        
        List<RevoSiteFullCabinSearch.FullCabinResults> results = 
            (List<RevoSiteFullCabinSearch.FullCabinResults>) JSON.deserialize(responseBody, List<RevoSiteFullCabinSearch.FullCabinResults>.class);
        
        System.assert(results != null && results.size() > 0, 'Deve retornar pelo menos uma configuração de data disponível');
    }

    
}