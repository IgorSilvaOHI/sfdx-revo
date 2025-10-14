@isTest
private class VooDomainTest {
    @TestSetup
    static void Setup(){
        TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();    
    }

    @isTest
    static void checkStatusRascunhoTest() {
        TestUtil.SetupAccountContactVoo('Fernando', 'test@gmail.com', 'Rascunho');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        VooDomain vooDomain = new VooDomain();

        Test.startTest();

        voo = VooService.getVooById(voo.Id);
        Boolean statusRascunho = vooDomain.checkStatusRascunho(voo);
        System.assert(
            statusRascunho && voo.Status__c == 'Rascunho' &&
            voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'vooDomain\''
            + '\nFunção:\'checkStatusRascunho\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }
    
    @isTest
    static void checkPassageirosCargasTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(system.now()+10, false, uow);
        voo.Status__c = 'Reservado';
        voo.IgnorarTrigger__c = true;
        uow.commitWork();

        Test.startTest();
        VooDomain vd = new VooDomain();
        Boolean check = vd.checkPassageirosCargas(voo);
        Test.stopTest();
        system.assertEquals(check, false);
    }

    @isTest
    static void checkPassageirosCargasTest2() {
        TestUtil.SetupAccountContactVooComTrecho('Fernando', 'test@gmail.com', 'Rascunho', 'Não Iniciado');
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        VooDomain vooDomain = new VooDomain();

        Test.startTest();

        voo = VooService.getVooById(voo.Id);
        Boolean checkPassageirosCargas = vooDomain.checkPassageirosCargas(voo);
        System.assert(
            checkPassageirosCargas && voo.Status__c == 'Rascunho' &&
            voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'vooDomain\''
            + '\nFunção:\'checkPassageirosCargas\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }
    
    @isTest
    static void checkVooNaoGerenciavelTest() {
        Test.startTest();
        Voo__c voo = new Voo__c(Status__c='Rascunho');
        VooDomain vooDomain = new VooDomain();
        Boolean checkVooNaoGerenciavel = vooDomain.checkVooNaoGerenciavel(voo);
        System.assert(
            !checkVooNaoGerenciavel, 'Algo não correu bem.\nClasse: \'vooDomain\'' + '\nFunção:\'checkVooNaoGerenciavel\'\n' + voo);
        Test.stopTest();
    }
}