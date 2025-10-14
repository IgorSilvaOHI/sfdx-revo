@isTest
private class ConfiguracaoPacoteSelectorTest {

    @testSetup
    static void setupData() {
        // Criação de dados de teste
        
        Id standardPricebookId = TestUtil.SetupStandardPricebook();

        
        Id productRecordType = Schema.getGlobalDescribe()
                    .get('Product2')
                    .getDescribe()
                    .getRecordTypeInfosByDeveloperName()
                    .get('ServicosTaxas')
                    .getRecordTypeId();

        Product2 produtoPai = new Product2(Name = 'Produto Pai Teste', IsActive = true, RecordTypeId = productRecordType);
        Product2 produtoFilho = new Product2(Name = 'Produto Filho Teste', IsActive = true, RecordTypeId = productRecordType);
        insert new List<Product2> { produtoPai, produtoFilho };

        ConfiguracaoPacote__c configuracao1 = new ConfiguracaoPacote__c(
            ProdutoPai__c = produtoPai.Id,
            Posicao__c = 1,
            ProdutoPacote__c = produtoFilho.Id
        );

        ConfiguracaoPacote__c configuracao2 = new ConfiguracaoPacote__c(
            ProdutoPai__c = produtoPai.Id,
            Posicao__c = 2,
            ProdutoPacote__c = produtoFilho.Id
        );

        insert new List<ConfiguracaoPacote__c>{configuracao1, configuracao2};
    }

    @isTest
    static void testSelectByIdProducts() {
        // Recupera o ID do produto pai criado no @testSetup
        Set<Id> idProducts = new Set<Id>{[SELECT Id FROM Product2 WHERE Name = 'Produto Pai Teste' LIMIT 1].Id};
        Id firstIdProduct = idProducts.isEmpty() ? null : idProducts.iterator().next();

        ConfiguracaoPacoteSelector selector = new ConfiguracaoPacoteSelector();
        Map<Id, List<ConfiguracaoPacote__c>> result = selector.selectByIdProducts(idProducts);

        System.assertNotEquals(result, null, 'O resultado não deve ser nulo.');
        System.assert(result.containsKey(firstIdProduct), 'O mapa de resultado deve conter o produto pai.');
        System.assertEquals(2, result.get(firstIdProduct).size(), 'Devem haver exatamente 2 configurações associadas ao produto pai.');
    }

    @isTest
    static void testGetSObjectType() {
        ConfiguracaoPacoteSelector selector = new ConfiguracaoPacoteSelector();
        Schema.SObjectType sObjectType = selector.getSObjectType();

        System.assertEquals(ConfiguracaoPacote__c.SObjectType, sObjectType, 'O tipo de objeto deve ser ConfiguracaoPacote__c.');
    }

    @isTest
    static void testGetSObjectFieldList() {
        ConfiguracaoPacoteSelector selector = new ConfiguracaoPacoteSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();

        System.assertNotEquals(fieldList, null, 'A lista de campos não deve ser nula.');
        System.assert(fieldList.contains(ConfiguracaoPacote__c.Id), 'A lista de campos deve conter ConfiguracaoPacote__c.Id.');
    }
}