@isTest
private class RegraProdutoSelectorTest {

    @testSetup
    static void setupData() {
        
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        Product2 produto1 = new Product2(Name = 'Produto Teste 1', IsActive = true);
        Product2 produto2 = new Product2(Name = 'Produto Teste 2', IsActive = true);
        insert new List<Product2>{produto1, produto2};

        // Criação de regras de produto associadas
        RegraProduto__c regra1 = new RegraProduto__c(
            Produto__c = produto1.Id
        );

        RegraProduto__c regra2 = new RegraProduto__c(
            Produto__c = produto1.Id
        );

        RegraProduto__c regra3 = new RegraProduto__c(
            Produto__c = produto2.Id
        );

        insert new List<RegraProduto__c>{regra1, regra2, regra3};
    }

    @isTest
    static void testSelectByIdProducts() {
        // Obtenção dos IDs de produtos criados no @testSetup
        Set<Id> idProducts = new Set<Id>{
            [SELECT Id FROM Product2 WHERE Name = 'Produto Teste 1' LIMIT 1].Id,
            [SELECT Id FROM Product2 WHERE Name = 'Produto Teste 2' LIMIT 1].Id
        };

        RegraProdutoSelector selector = new RegraProdutoSelector();
        Map<Id, List<RegraProduto__c>> result = selector.selectByIdProducts(idProducts);

        System.assertNotEquals(result, null, 'O mapa de resultado não deve ser nulo.');
        System.assert(result.containsKey(idProducts.iterator().next()), 'O mapa deve conter o primeiro produto.');
        System.assertEquals(2, result.get(idProducts.iterator().next()).size(), 'Devem haver 2 regras associadas ao primeiro produto.');
    }

    @isTest
    static void testGetSObjectType() {
        RegraProdutoSelector selector = new RegraProdutoSelector();
        Schema.SObjectType sObjectType = selector.getSObjectType();

        System.assertEquals(RegraProduto__c.SObjectType, sObjectType, 'O tipo de objeto deve ser RegraProduto__c.');
    }

    @isTest
    static void testGetSObjectFieldList() {
        RegraProdutoSelector selector = new RegraProdutoSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();

        System.assertNotEquals(fieldList, null, 'A lista de campos não deve ser nula.');
        System.assert(fieldList.contains(RegraProduto__c.Id), 'A lista de campos deve conter RegraProduto__c.Id.');
    }
}