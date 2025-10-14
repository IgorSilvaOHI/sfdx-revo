@isTest
public with sharing class FlowBuscaContatoPorTelefoneTest {
    @TestSetup
    static void makeData(){
        
        Contact contato = TestUtil.createContactPassageiro(null, 'Caio Bernardi');
        insert contato;

    }

    @IsTest
    static void testeBuscaContatoPorTelefone(){
        Contact contato = [SELECT Id, Phone FROM Contact LIMIT 1];
        
        List<Id> fixedResults = new List<Id>{contato.Id};


        List<String> telefones = new List<String>{contato.Phone};
        
        Test.setFixedSearchResults(fixedResults);

        List<FlowBuscaContatoPorTelefone.ResultadoBusca> result = FlowBuscaContatoPorTelefone.buscaContatoPorTelefone(telefones);
        
        System.debug('result: ' + result);

        System.assertNotEquals(null, result);
    }
}