@isTest
private class VooServiceTest {
    @TestSetup
    static void Setup(){
        TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();
    }

    @isTest
    static void getVooById() {
        TestUtil.SetupAccountContactVoo('Fernando', 'test@gmail.com', 'Rascunho');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();

        voo = VooService.getVooById(voo.Id);
        System.assert(
            voo.Status__c == 'Rascunho' && voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'VooService\''
            + '\nFunção:\'getVooById\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }
    
    @isTest
    public static void validarVooTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(System.now()+10, false, uow);
        uow.commitWork();
        Test.startTest();
        Boolean status = VooService.validarVoo(voo.Id);
        System.assert(status);
        Test.stopTest();
    }

    @isTest
    static void checkStatusRascunhoTest() {
        TestUtil.SetupAccountContactVoo('Fernando', 'test@gmail.com', 'Rascunho');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];
        voo = VooSelector.getVooById(voo.Id);

        Test.startTest();

        Boolean checkStatusRascunho = VooService.checkStatusRascunho(voo.Id);
        System.assert(
            checkStatusRascunho && voo.Status__c == 'Rascunho' &&
            voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'VooService\''
            + '\nFunção:\'checkStatusRascunho\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }

    @isTest
    static void checkPassageirosCargasTest() {
        TestUtil.SetupAccountContactVooComTrecho('Fernando', 'test@gmail.com', 'Rascunho', 'Não Iniciado');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];
        voo = VooSelector.getVooById(voo.Id);

        Test.startTest();

        Boolean checkPassageirosCargas = VooService.checkPassageirosCargas(voo.Id);
        System.assert(
            checkPassageirosCargas && voo.Status__c == 'Rascunho' &&
            voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'VooService\''
            + '\nFunção:\'checkPassageirosCargas\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }

    @isTest
    static void checkVooNaoGerenciavelTest() {
        TestUtil.SetupAccountContactVoo('Fernando', 'test@gmail.com', 'Rascunho');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];
        voo = VooSelector.getVooById(voo.Id);

        Test.startTest();

        Boolean checkVooNaoGerenciavel = VooService.checkVooNaoGerenciavel(voo.Id);
        System.assert(
            !checkVooNaoGerenciavel && voo.Status__c == 'Rascunho' &&
            voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'VooService\''
            + '\nFunção:\'checkVooNaoGerenciavel\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }
}