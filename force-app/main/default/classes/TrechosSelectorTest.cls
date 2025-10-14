@isTest
private class TrechosSelectorTest {

    @testSetup
    static void setupData() {

        Account conta = TestFactory.createBusinessAccount('Conta Padrão');

        insert conta;

        // Criação dos objetos Local__c
        Local__c origem = new Local__c(Name = 'Origem Teste', CodigoLocal__c = 'LOCAL DE ORIGEM', Tipo__c = 'Onshore');
        Local__c destino = new Local__c(Name = 'Destino Teste', CodigoLocal__c = 'LOCAL DE DESTINO', Tipo__c = 'Onshore');
        insert new List<Local__c>{origem, destino};

        // Criação do objeto Voo__c
        Voo__c voo = new Voo__c(Cliente__c = conta.Id);
        insert voo;

        // Criação dos objetos Trecho__c
        Trecho__c trecho1 = new Trecho__c(
            Voo__c = voo.Id,
            OrdemExecucao__c = 1,
            Origem__c = origem.Id,
            Destino__c = destino.Id,
            PrevisaoDecolagem__c = DateTime.now().addHours(1)
        );

        Trecho__c trecho2 = new Trecho__c(
            Voo__c = voo.Id,
            OrdemExecucao__c = 2,
            Origem__c = origem.Id,
            Destino__c = destino.Id,
            PrevisaoDecolagem__c = DateTime.now().addDays(1)
        );

        insert new List<Trecho__c>{trecho1, trecho2};
    }

    @isTest
    static void testSelectById() {
        Set<Id> idSet = new Set<Id>{[SELECT Id FROM Trecho__c LIMIT 1].Id};

        TrechosSelector selector = new TrechosSelector();
        List<Trecho__c> result = selector.selectById(idSet);

        System.assertNotEquals(result, null, 'A lista de trechos não deve ser nula.');
        System.assertEquals(1, result.size(), 'O resultado deve conter exatamente 1 trecho.');
    }

    @isTest
    static void testSelectByVooId() {
        Set<Id> vooIdSet = new Set<Id>{[SELECT Id FROM Voo__c LIMIT 1].Id};

        TrechosSelector selector = new TrechosSelector();
        List<Trecho__c> result = selector.selectByVooId(vooIdSet);

        System.assertNotEquals(result, null, 'A lista de trechos não deve ser nula.');
        System.assert(result.size() > 0, 'O resultado deve conter pelo menos 1 trecho.');
    }

    @isTest
    static void testGetSObjectType() {
        TrechosSelector selector = new TrechosSelector();
        Schema.SObjectType sObjectType = selector.getSObjectType();

        System.assertEquals(Trecho__c.SObjectType, sObjectType, 'O tipo de objeto deve ser Trecho__c.');
    }

    @isTest
    static void testSelectByVooIdOrderByOrdemExecucao() {
        Set<Id> vooIdSet = new Set<Id>{[SELECT Id FROM Voo__c LIMIT 1].Id};

        TrechosSelector selector = new TrechosSelector();
        List<Trecho__c> result = selector.selectByVooIdOrderByOrdemExecucao(vooIdSet);

        System.assertNotEquals(result, null, 'A lista de trechos ordenados não deve ser nula.');
        System.assertEquals(2, result.size(), 'O resultado deve conter exatamente 2 trechos.');
        System.assertEquals(1, result[0].OrdemExecucao__c, 'O primeiro trecho deve ter OrdemExecucao igual a 1.');
    }

    @isTest
    static void testGetTrechoWithPassageirosByVooId() {
        Set<Id> vooIdSet = new Set<Id>{[SELECT Id FROM Voo__c LIMIT 1].Id};
        Set<Id> contatosId = new Set<Id>();

        TrechosSelector selector = new TrechosSelector();
        List<Trecho__c> result = selector.getTrechoWithPassageirosByVooId(vooIdSet, contatosId);

        System.assertNotEquals(result, null, 'A lista de trechos com passageiros não deve ser nula.');
    }
/*
    @isTest
    static void testGetTrechosByRouteAndDate() {
        Id origemId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'LOCAL DE ORIGEM' LIMIT 1].Id;
        Id destinoId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'LOCAL DE DESTINO' LIMIT 1].Id;

        TrechosSelector selector = new TrechosSelector();
        List<Trecho__c> result = selector.getTrechosByRouteAndDate(origemId, destinoId, DateTime.now(), DateTime.now().addDays(2));

        System.assertNotEquals(result, null, 'A lista de trechos por rota e data não deve ser nula.');
        System.assert(result.size() > 0, 'O resultado deve conter pelo menos 1 trecho.');
    }
        */
}