@IsTest
public class AddHorarioMalhaControllerTest {
    
    @TestSetup
    static void setup() {
        // Configura produtos e serviços usando RevoTestUtil
        RevoTestUtil.ConfigurarProdutosEServicos();
    }
    
    @IsTest
    static void testGetProducts() {
        Test.startTest();
        List<AddHorarioMalhaController.OptionDTO> result = AddHorarioMalhaController.getProducts();
        Test.stopTest();
        
        // Verifica se retornou produtos dos tipos corretos
        System.assertNotEquals(0, result.size(), 'Deve retornar pelo menos 1 produto');
        
        // Verifica se os produtos retornados são dos tipos esperados
        Set<Id> productIds = new Set<Id>();
        for (AddHorarioMalhaController.OptionDTO option : result) {
            productIds.add(option.value);
        }
        
        List<Product2> products = [SELECT Id, Name, RecordType.Name FROM Product2 WHERE Id IN :productIds];
        System.assertNotEquals(0, products.size(), 'Deve encontrar produtos válidos');
        
        // Verifica se pelo menos um produto tem um dos tipos esperados
        Boolean hasValidType = false;
        for (Product2 p : products) {
            if (p.RecordType.Name == 'Charter Flight' || 
                p.RecordType.Name == 'Shuttle Seat' || 
                p.RecordType.Name == 'Full Cabin') {
                hasValidType = true;
                break;
            }
        }
        System.assert(hasValidType, 'Deve ter pelo menos um produto com tipo válido');
    }
    
    @IsTest
    static void testGetMalhasByProduct() {
        // Busca um produto existente do tipo Shuttle Seat
        List<Product2> shuttleProducts = [SELECT Id, Name FROM Product2 
                                         WHERE RecordType.Name = 'Shuttle Seat' 
                                         AND IsActive = true 
                                         LIMIT 1];
        
        System.assertNotEquals(0, shuttleProducts.size(), 'Deve ter pelo menos um produto Shuttle Seat');
        
        Product2 testProduct = shuttleProducts[0];
        
        // Verifica quantas malhas já existem para este produto
        List<MalhaVoo__c> existingMalhas = [SELECT Id FROM MalhaVoo__c WHERE Produto__c = :testProduct.Id];
        Integer initialCount = existingMalhas.size();
        
        // Busca uma conta existente para usar como operador
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        System.assertNotEquals(0, accounts.size(), 'Deve ter pelo menos uma conta');
        
        // Cria malha vinculada ao produto existente
        MalhaVoo__c m = new MalhaVoo__c(
            Produto__c = testProduct.Id, 
            DataInicio__c = Date.today(),
            DataFim__c = Date.today().addYears(1),
            OperadorMalha__c = accounts[0].Id
        ); 
        insert m;
        
        Test.startTest();
        List<AddHorarioMalhaController.OptionDTO> result = AddHorarioMalhaController.getMalhasByProduct(testProduct.Id);
        Test.stopTest();
        
        // Deve retornar todas as malhas (existentes + nova)
        System.assertEquals(initialCount + 1, result.size(), 'Deve retornar todas as malhas do produto');
        
        // Verifica se a nova malha está na lista
        Boolean foundNewMalha = false;
        for (AddHorarioMalhaController.OptionDTO option : result) {
            if (option.value == m.Id) {
                foundNewMalha = true;
                break;
            }
        }
        System.assert(foundNewMalha, 'Deve incluir a nova malha criada');
    }
    
    @IsTest
    static void testGetMalhasByProductWithNull() {
        Test.startTest();
        List<AddHorarioMalhaController.OptionDTO> result = AddHorarioMalhaController.getMalhasByProduct(null);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Com productId nulo deve retornar vazio');
    }
    
    @IsTest
    static void testCreateHorarioExtraSuccess() {
        // Busca um produto existente
        List<Product2> products = [SELECT Id FROM Product2 
                                 WHERE RecordType.Name IN ('Shuttle Seat', 'Full Cabin', 'Charter Flight')
                                 AND IsActive = true 
                                 LIMIT 1];
        
        System.assertNotEquals(0, products.size(), 'Deve ter pelo menos um produto válido');
        
        // Cria malha vinculada ao produto existente
        MalhaVoo__c m = new MalhaVoo__c(
            Produto__c = products[0].Id
        );
        insert m;
        
        DateTime dt = System.now().addDays(1);
        
        Test.startTest();
        Id recId = AddHorarioMalhaController.createHorarioExtra(m.Id, dt);
        Test.stopTest();
        
        Horarioextradamalha__c insertedRec = [SELECT Id, MalhadeVoo__c, DataHoraExtra__c FROM Horarioextradamalha__c WHERE Id = :recId];
        System.assertEquals(m.Id, insertedRec.MalhadeVoo__c);
        System.assertEquals(dt, insertedRec.DataHoraExtra__c);
    }
    
    @IsTest
    static void testCreateHorarioExtraWithNulls() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            AddHorarioMalhaController.createHorarioExtra(null, System.now());
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Deve lançar exceção se malhaId for nulo');
    }
    
    @IsTest
    static void testCreateHorarioExtraWithNullDateTime() {
        // Busca um produto existente
        List<Product2> products = [SELECT Id FROM Product2 
                                 WHERE RecordType.Name IN ('Shuttle Seat', 'Full Cabin', 'Charter Flight')
                                 AND IsActive = true 
                                 LIMIT 1];
        
        System.assertNotEquals(0, products.size(), 'Deve ter pelo menos um produto válido');
        
        // Cria malha vinculada ao produto existente
        MalhaVoo__c m = new MalhaVoo__c(
            Produto__c = products[0].Id
        );
        insert m;
        
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            AddHorarioMalhaController.createHorarioExtra(m.Id, null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Deve lançar exceção se dataHora for nulo');
    }
}