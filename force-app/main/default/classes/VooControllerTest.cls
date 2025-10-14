@isTest
private class VooControllerTest {
    @TestSetup
    static void Setup(){
        TestUtil.SetupStandardPricebook();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        TestUtil2.criarVooRascunho(System.now().addMinutes(120), true, uow);
        uow.commitWork();
    }

    @isTest
    static void getVooTest() {
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();
        voo = VooController.getVoo(voo.Id);
        Test.stopTest();
        
        System.assert(voo.Id != null,
            'Algo não correu bem.\nClasse: \'VooController\'' + '\nFunção:\'getVoo\'\n'
            + voo);
    }

    @isTest
    static void getTrechosTest() {
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();
        List<Trecho__c> trechoList = VooController.getTrechos(voo.Id);        
        Test.stopTest();
        
        System.assert(trechoList.size() > 0,
            'Algo não correu bem.\nClasse: \'VooController\'' + '\nFunção:\'getTrechos\'\n'
            + trechoList);
    }

    @isTest
    static void validarVooTest() {
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();
        VooController.validarVoo(voo.Id);        
        Test.stopTest();
    }

    @isTest
    static void checkStatusRascunhoTest() {
        Test.startTest();

        Boolean checkStatusRascunho = VooController.checkStatusRascunho([SELECT Id FROM Voo__c LIMIT 1].Id);
        
        Test.stopTest();
        
        System.assert(checkStatusRascunho);
    }

    @isTest
    static void checkPassageirosCargasTest() {
        Test.startTest();

        Boolean checkPassageirosCargas = VooController.checkPassageirosCargas([SELECT Id FROM Voo__c LIMIT 1].Id);
        System.assert(
            checkPassageirosCargas,
            'Algo não correu bem.\nClasse: \'VooController\''
            + '\nFunção:\'checkPassageirosCargas\'');
        Test.stopTest();
    }
	
    @isTest
    static void checkVooNaoGerenciavelTest() {
        Test.startTest();

        Boolean checkVooNaoGerenciavel = VooController.checkVooNaoGerenciavel([SELECT Id FROM Voo__c LIMIT 1].Id);
        
        Test.stopTest();
        
        System.assert(
            !checkVooNaoGerenciavel,
            'Algo não correu bem.\nClasse: \'VooController\''
            + '\nFunção:\'checkVooNaoGerenciavel\'\n');
    }
    
    @isTest
    static void getVooWrapperTest()
    {
        Test.startTest();
        
        String str = VooController.getVooWrapper([SELECT Id FROM Voo__c LIMIT 1].Id);
        
        Test.stopTest();
    }
}