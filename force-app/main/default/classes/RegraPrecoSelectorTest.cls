@isTest
private class RegraPrecoSelectorTest {

    @testSetup
    static void setupData() {
        
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        Product2 produto1 = new Product2(Name = 'Produto Teste 1', IsActive = true);
        Product2 produto2 = new Product2(Name = 'Produto Teste 2', IsActive = true);
        insert new List<Product2>{produto1, produto2};

        // Criação de regras de preço associadas aos produtos
        RegraPreco__c regra1 = new RegraPreco__c(
            Produto__c = produto1.Id
        );

        RegraPreco__c regra2 = new RegraPreco__c(
            Produto__c = produto1.Id
        );

        RegraPreco__c regra3 = new RegraPreco__c(
            Produto__c = produto2.Id
        );

        insert new List<RegraPreco__c>{regra1, regra2, regra3};
    }

    @isTest
    static void testSelectByIdProducts() {
        // Recupera os IDs dos produtos criados no @testSetup
        Set<Id> idProducts = new Set<Id>{
            [SELECT Id FROM Product2 WHERE Name = 'Produto Teste 1' LIMIT 1].Id,
            [SELECT Id FROM Product2 WHERE Name = 'Produto Teste 2' LIMIT 1].Id
        };

        RegraPrecoSelector selector = new RegraPrecoSelector();
        Map<Id, List<RegraPreco__c>> result = selector.selectByIdProducts(idProducts);

        System.assertNotEquals(result, null, 'O mapa de resultado não deve ser nulo.');
        Id firstIdProduct = idProducts.iterator().next();
        System.assert(result.containsKey(firstIdProduct), 'O mapa deve conter o primeiro produto.');
        System.assertEquals(2, result.get(firstIdProduct).size(), 'Devem haver 2 regras associadas ao primeiro produto.');
    }

    @isTest
    static void testGetSObjectType() {
        RegraPrecoSelector selector = new RegraPrecoSelector();
        Schema.SObjectType sObjectType = selector.getSObjectType();

        System.assertEquals(RegraPreco__c.SObjectType, sObjectType, 'O tipo de objeto deve ser RegraPreco__c.');
    }

    @isTest
    static void testGetSObjectFieldList() {
        RegraPrecoSelector selector = new RegraPrecoSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();

        System.assertNotEquals(fieldList, null, 'A lista de campos não deve ser nula.');
        System.assert(fieldList.contains(RegraPreco__c.Id), 'A lista de campos deve conter RegraPreco__c.Id.');
    }
}