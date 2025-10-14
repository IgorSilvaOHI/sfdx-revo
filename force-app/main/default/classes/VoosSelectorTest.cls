@isTest
private class VoosSelectorTest {

    @TestSetup
    static void setup()
    {
        TestUtil.SetupStandardPricebook();
    }
    
    @isTest
    public static void selectRastreaveisBetweenDatesTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Date data = System.today().addDays(50);
        Datetime dataVoo = Datetime.newInstance(data, Time.newInstance(12, 0, 0, 0));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, true, uow);
        uow.commitWork();
        Test.startTest();
        List<Voo__c> voosRastreaveis = VoosSelector.newInstance().selectRastreaveisBetweenDates(data, data);
        System.assertEquals(0, voosRastreaveis.size());
        voo.Status__c = 'Confirmado';
        update voo;
        voosRastreaveis = VoosSelector.newInstance().selectRastreaveisBetweenDates(Datetime.newInstance(data, Time.newInstance(0, 0, 0, 0)), Datetime.newInstance(data.addDays(1), Time.newInstance(0, 0, 0, 0)));
        System.assertEquals(1, voosRastreaveis.size());
        Test.stopTest();
        
    }
    
  
    @isTest
    private static void selectWithLeadByIdTest()
    {
        Test.startTest();
        List<Voo__c> voosSelecionados = VoosSelector.newInstance().selectByIdWithLead(new Set<Id>());
        Test.stopTest();
        System.assertEquals(0, voosSelecionados.size());
    }
    
    @IsTest
    public static void selectRecentsWithTrechosTest()
    {
        
        Test.startTest();
        List<Voo__c> voosRecentes = VoosSelector.newInstance().selectRecentsWithTrechos();
        Test.stopTest();
        
        System.assertEquals(0, voosRecentes.size());
    }
    
    @isTest
    public static void selectDeletedByIdTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime dataVoo = Datetime.newInstance(System.today()+10, Time.newInstance(12, 00, 00, 00));
        Voo__c voo = TestUtil2.criarVooRascunho(dataVoo, true, uow);
        uow.commitWork();
        delete voo;
        Test.startTest();
        List<Voo__c> voosDeletados = VoosSelector.newInstance().selectDeletedById(new Set<Id>{voo.Id});
        System.assertEquals(1, voosDeletados.size());
        Test.stopTest();
    }
    
    @isTest
    public static void getVoosHojeByStatusTest()
    {
        Test.startTest();
        List<Voo__c> voosList = VoosSelector.newInstance().getVoosAmanhaByStatus(Voos.RASCUNHO);
        Test.stopTest();
        System.assertEquals(0, voosList.size());
    }
    
    @isTest
    public static void selectByIdWithCombinedAttachmentsTest()
    {
        Test.startTest();
        VoosSelector.newInstance().selectByIdWithCombinedAttachments(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    public static void selectByIdToInteressadosFaturamentoTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime diavoo = Datetime.newInstance((Date.today()).addDays(1) , time.newInstance(13, 0, 0, 0));
        Voo__c voo = TestUtil2.criarVooRascunho(diavoo, true, uow);
        //voo.FaturamentoInformado__c = true;
        uow.commitWork();
        Test.startTest();
        List<Voo__c> selecteds = VoosSelector.newInstance().selectByIdToInteressadosFaturamento(new Set<Id>{voo.Id});
        Test.stopTest();
        System.assertEquals(1, selecteds.size());
    }
    
    @isTest
    public static void selectWithPrefixosAndBetweenDatesTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime diavoo = Datetime.newInstance((Date.today()).addDays(1) , time.newInstance(13, 0, 0, 0));
        Voo__c voo = TestUtil2.criarVooRascunho(diavoo, true, uow);
        uow.commitWork();
        Test.startTest();
        Date menorData = voo.DataVoo__c.date().addDays(-1);
        Date maiorData = voo.DataVoo__c.date().addDays(1);
        List<Voo__c> voosNoIntervalo = VoosSelector.newInstance().selectWithPrefixosAndBetweenDates(new Set<Id>{voo.Prefixo__c}, menorData, maiorData);
        system.assert(voosNoIntervalo.size() == 1);
        Test.stopTest();
    }
    
    
    @isTest
    public static void selectWithPrimeiroTrechoByIdTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Datetime diavoo = Datetime.newInstance(Date.today() , time.newInstance(13, 0, 0, 0));
        Voo__c voo = TestUtil2.criarVooRascunho(diavoo, true, uow);
        uow.commitWork();

        Test.startTest();
        List<Voo__c> voos = VoosSelector.newInstance().selectWithPrimeiroTrechoById(new Set<Id>{voo.id});
        system.assert(voos.size() == 1);
        system.assertEquals(1, voos[0].trechos__r.size());
        system.assertEquals(true, voos[0].trechos__r[0].primeiroTrecho__c);
        Test.stopTest();
    }
    

}