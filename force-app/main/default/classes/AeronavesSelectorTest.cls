@isTest
private class AeronavesSelectorTest {
	@TestSetup
    private static void Setup() {


        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        Product2 prod = TestUtil.createProduct('Modelo 1');
        insert prod;

        Local__c baseMae = TestUtil.carregaLocais(1)[0];
        insert baseMae;

        Aeronave__c aeronave = TestUtil.createAeronave('Modelo 1', prod, baseMae);
        insert aeronave;
    }
    
    @isTest
    private static void getSObjectFieldListTest() {
        Test.startTest();
        System.assert(new AeronavesSelector().getSObjectFieldList().size() > 0,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'getSObjectFieldList\'\n'
                      + new AeronavesSelector().getSObjectFieldList());
        Test.stopTest();
    }
    
    @isTest
    public static void selectTodasAtivas()
    {
        Product2 prod = [SELECT Id FROM Product2];
        Aeronave__c aeronave = TestUtil.createAeronave('Modelo 2', prod);
        aeronave.Desativada__c = true;
            
        Test.startTest();
        List<Aeronave__c> aeronaves = AeronavesSelector.newInstance().selectTodasAtivas();
        System.assertEquals(1, aeronaves.size(), 'deve haver uma aeronave válida');
        Test.stopTest();
    }
    
    @isTest
    private static void selectByIdTest() {
        List<Aeronave__c> aeronaveMap = [SELECT Id, Name FROM Aeronave__c];
        Test.startTest();
        List<Aeronave__c> aeronaveList = AeronavesSelector.newInstance().selectById(new Set<Id> {aeronaveMap[0].Id});
        Test.stopTest();
        System.assert(aeronaveList.size() > 0,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'selectById\'\n'
                      + aeronaveList);
    }
    
    @isTest
    private static void selectAllTest() {
        Test.startTest();
        List<Aeronave__c> aeronaveList = new AeronavesSelector().selectAll();
        Test.stopTest();
        
        System.assert(aeronaveList.size() == 1,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'selectAllTest\'\n'
                      + aeronaveList);
    }
    
    @isTest
    private static void selectAeronaveAndModeloTest()
    {
        Set<Id> ids = new Set<Id>{[SELECT Id FROM Aeronave__c LIMIT 1].Id};
        Test.startTest();
        List<Aeronave__c> aeronaveList = AeronavesSelector.newInstance().selectAeronaveAndModelo(ids);
        Test.stopTest();
        
         System.assert(aeronaveList.size() == 1,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'selectAeronaveAndModeloTest\'\n'
                      + aeronaveList);
    }
    
}