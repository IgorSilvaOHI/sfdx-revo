@isTest
public class GeraPDFOportunidadeControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Usar a configuração padrão do RevoTestUtil que já cria produtos e configurações
        RevoTestUtil.ConfigurarProdutosEServicos();
        
        // Buscar a conta de cliente criada pelo RevoTestUtil
        Account customerAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ClientePF' LIMIT 1];
        
        // Criar Opportunity de teste
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = customerAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Buscar os modelos de aeronaves criados pelo RevoTestUtil
        List<Product2> modelos = [SELECT Id, Name FROM Product2 WHERE RecordType.DeveloperName = 'Modelo' AND Name IN ('H-135', 'H-155')];
        
        // Buscar PricebookEntry existentes para os modelos específicos
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Set<Id> modeloIds = new Set<Id>();
        for (Product2 modelo : modelos) {
            modeloIds.add(modelo.Id);
        }
        
        List<PricebookEntry> existingEntries = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id AND Product2Id IN :modeloIds];
        
        // Verificar quais modelos já têm PricebookEntry
        Set<Id> existingProductIds = new Set<Id>();
        for (PricebookEntry entry : existingEntries) {
            existingProductIds.add(entry.Product2Id);
        }
        
        // Criar apenas PricebookEntry que não existem
        List<PricebookEntry> entriesToInsert = new List<PricebookEntry>();
        for (Product2 modelo : modelos) {
            if (!existingProductIds.contains(modelo.Id)) {
                entriesToInsert.add(new PricebookEntry(
                    Pricebook2Id = standardPricebook.Id,
                    Product2Id = modelo.Id,
                    UnitPrice = 1000,
                    IsActive = true
                ));
            }
        }
        
        if (!entriesToInsert.isEmpty()) {
            insert entriesToInsert;
            // Adicionar os novos entries à lista existente
            existingEntries.addAll(entriesToInsert);
        }
        
        // Criar OpportunityLineItems
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        
        // Criar mapa de Product2Id para PricebookEntryId
        Map<Id, Id> productToEntryMap = new Map<Id, Id>();
        for (PricebookEntry entry : existingEntries) {
            productToEntryMap.put(entry.Product2Id, entry.Id);
        }
        
        for (Product2 modelo : modelos) {
            if (productToEntryMap.containsKey(modelo.Id)) {
                lineItems.add(new OpportunityLineItem(
                    OpportunityId = testOpp.Id,
                    PricebookEntryId = productToEntryMap.get(modelo.Id),
                    Quantity = 1,
                    UnitPrice = 1000,
                    ModeloSelecionado__c = modelo.Id
                ));
            }
        }
        insert lineItems;
    }
    
    @isTest
    static void testConstructorWithValidOpportunity() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Simular parâmetros da página
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        // Criar StandardController e instanciar o controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar inicialização das propriedades
        System.assertEquals('', controller.imageUrl, 'imageUrl deve ser inicializada como string vazia');
        System.assertEquals(false, controller.hasLogo, 'hasLogo deve ser inicializada como false');
        System.assertEquals('', controller.footerLogoUrl, 'footerLogoUrl deve ser inicializada como string vazia');
        System.assertEquals(false, controller.hasFooterLogo, 'hasFooterLogo deve ser inicializada como false');
        
        // Verificar inicialização das URLs das aeronaves (serão URLs com null quando não há ContentDocuments)
        System.assert(controller.h135ExteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h135ExteriorUrl deve conter a URL base');
        System.assert(controller.h135InteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h135InteriorUrl deve conter a URL base');
        System.assert(controller.h155ExteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h155ExteriorUrl deve conter a URL base');
        System.assert(controller.h155InteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h155InteriorUrl deve conter a URL base');
        
        // Verificar inicialização das URLs das substâncias (serão URLs com null quando não há ContentDocuments)
        System.assert(controller.corrosivosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'corrosivosUrl deve conter a URL base');
        System.assert(controller.explosivosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'explosivosUrl deve conter a URL base');
        System.assert(controller.gasesUrl.contains('/sfc/servlet.shepherd/version/download/'), 'gasesUrl deve conter a URL base');
        System.assert(controller.radioativosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'radioativosUrl deve conter a URL base');
        System.assert(controller.liquidosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'liquidosUrl deve conter a URL base');
        System.assert(controller.miscelaneosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'miscelaneosUrl deve conter a URL base');
        System.assert(controller.solidosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'solidosUrl deve conter a URL base');
        System.assert(controller.toxicosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'toxicosUrl deve conter a URL base');
        System.assert(controller.oxidantesUrl.contains('/sfc/servlet.shepherd/version/download/'), 'oxidantesUrl deve conter a URL base');
        System.assert(controller.facaUrl.contains('/sfc/servlet.shepherd/version/download/'), 'facaUrl deve conter a URL base');
        System.assert(controller.armaUrl.contains('/sfc/servlet.shepherd/version/download/'), 'armaUrl deve conter a URL base');
        System.assert(controller.tesouraUrl.contains('/sfc/servlet.shepherd/version/download/'), 'tesouraUrl deve conter a URL base');
        
        // Verificar se os modelos foram detectados corretamente (o construtor já executa checkAircraftModels)
        System.assertEquals(true, controller.hasH135Model, 'hasH135Model deve ser true quando há modelo H-135');
        System.assertEquals(true, controller.hasH155Model, 'hasH155Model deve ser true quando há modelo H-155');
    }
    
    @isTest
    static void testConstructorWithoutOpportunityId() {
        // Simular página sem parâmetro id
        PageReference pageRef = Page.GeraPDFOportunidade;
        Test.setCurrentPage(pageRef);
        
        // Criar uma Opportunity fictícia para o StandardController
        Opportunity testOpp = new Opportunity();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        
        // Instanciar o controller - não deve gerar exceção
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se as propriedades foram inicializadas corretamente
        System.assertEquals('', controller.imageUrl, 'imageUrl deve ser inicializada como string vazia');
        System.assertEquals(false, controller.hasLogo, 'hasLogo deve ser inicializada como false');
    }
    
    @isTest
    static void testFormatDateTimeWithValidDateTime() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Testar com DateTime válido
        DateTime testDateTime = DateTime.newInstance(2024, 1, 15, 14, 30, 0);
        String formattedDateTime = controller.formatDateTime(testDateTime);
        
        // Verificar se a formatação está correta (formato: dd/MM/yyyy HH:mm)
        System.assert(formattedDateTime.contains('15/01/2024'), 'Data deve estar no formato dd/MM/yyyy');
        System.assert(formattedDateTime.contains('14:30'), 'Hora deve estar no formato HH:mm');
    }
    
    @isTest
    static void testFormatDateTimeWithNullDateTime() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Testar com DateTime nulo
        String formattedDateTime = controller.formatDateTime(null);
        
        // Verificar se retorna string vazia
        System.assertEquals('', formattedDateTime, 'Deve retornar string vazia para DateTime nulo');
    }
    
    @isTest
    static void testCheckAircraftModelsWithH135AndH155() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se os modelos foram detectados corretamente
        System.assertEquals(true, controller.hasH135Model, 'hasH135Model deve ser true quando há modelo H-135');
        System.assertEquals(true, controller.hasH155Model, 'hasH155Model deve ser true quando há modelo H-155');
    }
    
    @isTest
    static void testCheckAircraftModelsWithOnlyH135() {
        // Criar nova Opportunity com apenas H-135
        Account customerAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ClientePF' LIMIT 1];
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity H135 Only',
            AccountId = customerAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Buscar o modelo H-135 criado pelo RevoTestUtil
        Product2 h135Model = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Modelo' AND Name = 'H-135' LIMIT 1];
        
        // Buscar PricebookEntry existente ou criar novo
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        List<PricebookEntry> existingEntries = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id AND Product2Id = :h135Model.Id];
        PricebookEntry h135Entry;
        
        if (existingEntries.isEmpty()) {
            h135Entry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = h135Model.Id,
                UnitPrice = 1000,
                IsActive = true
            );
            insert h135Entry;
        } else {
            h135Entry = existingEntries[0];
        }
        
        // Criar OpportunityLineItem apenas com H-135
        OpportunityLineItem h135LineItem = new OpportunityLineItem(
            OpportunityId = testOpp.Id,
            PricebookEntryId = h135Entry.Id,
            Quantity = 1,
            UnitPrice = 1000,
            ModeloSelecionado__c = h135Model.Id
        );
        insert h135LineItem;
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se apenas H-135 foi detectado
        System.assertEquals(true, controller.hasH135Model, 'hasH135Model deve ser true');
        System.assertEquals(false, controller.hasH155Model, 'hasH155Model deve ser false');
    }
    
    @isTest
    static void testCheckAircraftModelsWithNoModels() {
        // Criar nova Opportunity sem modelos
        Account customerAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'ClientePF' LIMIT 1];
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity No Models',
            AccountId = customerAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se nenhum modelo foi detectado
        System.assertEquals(false, controller.hasH135Model, 'hasH135Model deve ser false');
        System.assertEquals(false, controller.hasH155Model, 'hasH155Model deve ser false');
    }
    
    @isTest
    static void testCheckAircraftModelsWithNullOpportunityId() {
        // Simular página sem parâmetro id
        PageReference pageRef = Page.GeraPDFOportunidade;
        Test.setCurrentPage(pageRef);
        
        Opportunity testOpp = new Opportunity();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se nenhum modelo foi detectado quando não há ID
        System.assertEquals(false, controller.hasH135Model, 'hasH135Model deve ser false quando não há ID');
        System.assertEquals(false, controller.hasH155Model, 'hasH155Model deve ser false quando não há ID');
    }
    
    @isTest
    static void testLoadAircraftImages() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Como não temos os ContentDocuments reais no teste, as URLs terão null no final
        // mas o método não deve gerar exceção
        System.assert(controller.h135ExteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h135ExteriorUrl deve conter a URL base');
        System.assert(controller.h135InteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h135InteriorUrl deve conter a URL base');
        System.assert(controller.h155ExteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h155ExteriorUrl deve conter a URL base');
        System.assert(controller.h155InteriorUrl.contains('/sfc/servlet.shepherd/version/download/'), 'h155InteriorUrl deve conter a URL base');
    }
    
    @isTest
    static void testLoadSubstanceImages() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Como não temos os ContentDocuments reais no teste, as URLs terão null no final
        // mas o método não deve gerar exceção
        System.assert(controller.corrosivosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'corrosivosUrl deve conter a URL base');
        System.assert(controller.explosivosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'explosivosUrl deve conter a URL base');
        System.assert(controller.gasesUrl.contains('/sfc/servlet.shepherd/version/download/'), 'gasesUrl deve conter a URL base');
        System.assert(controller.radioativosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'radioativosUrl deve conter a URL base');
        System.assert(controller.liquidosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'liquidosUrl deve conter a URL base');
        System.assert(controller.miscelaneosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'miscelaneosUrl deve conter a URL base');
        System.assert(controller.solidosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'solidosUrl deve conter a URL base');
        System.assert(controller.toxicosUrl.contains('/sfc/servlet.shepherd/version/download/'), 'toxicosUrl deve conter a URL base');
        System.assert(controller.oxidantesUrl.contains('/sfc/servlet.shepherd/version/download/'), 'oxidantesUrl deve conter a URL base');
        System.assert(controller.facaUrl.contains('/sfc/servlet.shepherd/version/download/'), 'facaUrl deve conter a URL base');
        System.assert(controller.armaUrl.contains('/sfc/servlet.shepherd/version/download/'), 'armaUrl deve conter a URL base');
        System.assert(controller.tesouraUrl.contains('/sfc/servlet.shepherd/version/download/'), 'tesouraUrl deve conter a URL base');
    }
    
    @isTest
    static void testExceptionHandlingInConstructor() {
        // Testar se o construtor lida bem com exceções
        // Simular uma situação que pode gerar exceção
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', 'invalid_id');
        Test.setCurrentPage(pageRef);
        
        Opportunity testOpp = new Opportunity();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        
        // O construtor deve executar sem gerar exceção não tratada
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Verificar se as propriedades foram inicializadas mesmo com erro
        System.assertEquals('', controller.imageUrl, 'imageUrl deve ser inicializada mesmo com erro');
        System.assertEquals(false, controller.hasLogo, 'hasLogo deve ser inicializada mesmo com erro');
    }
    
    @isTest
    static void testPropertySettersAndGetters() {
        // Buscar a Opportunity criada no setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        PageReference pageRef = Page.GeraPDFOportunidade;
        pageRef.getParameters().put('id', testOpp.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        GeraPDFOportunidadeController controller = new GeraPDFOportunidadeController(stdController);
        
        // Testar setters e getters das propriedades
        controller.imageUrl = 'test_url';
        System.assertEquals('test_url', controller.imageUrl, 'imageUrl getter/setter deve funcionar');
        
        controller.hasLogo = true;
        System.assertEquals(true, controller.hasLogo, 'hasLogo getter/setter deve funcionar');
        
        controller.footerLogoUrl = 'test_footer_url';
        System.assertEquals('test_footer_url', controller.footerLogoUrl, 'footerLogoUrl getter/setter deve funcionar');
        
        controller.hasFooterLogo = true;
        System.assertEquals(true, controller.hasFooterLogo, 'hasFooterLogo getter/setter deve funcionar');
        
        controller.hasH135Model = true;
        System.assertEquals(true, controller.hasH135Model, 'hasH135Model getter/setter deve funcionar');
        
        controller.hasH155Model = true;
        System.assertEquals(true, controller.hasH155Model, 'hasH155Model getter/setter deve funcionar');
    }
}