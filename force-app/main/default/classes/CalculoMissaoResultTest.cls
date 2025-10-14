@isTest
public with sharing class CalculoMissaoResultTest {
    
    @TestSetup
    static void makeData(){

        Id standardPricebookId = TestUtil.SetupStandardPricebook();

        Date dataMissao = Date.today().addDays(2);
        Datetime data = Datetime.newInstance(dataMissao, Time.newInstance(15, 0, 0, 0));

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(data, false, uow);
        uow.commitWork();

        Trecho__c primeiroTrecho = [SELECT Id, Destino__c FROM Trecho__c WHERE OrdemExecucao__c = 10 AND Voo__c = :voo.Id];
        Local__c localDestino = new Local__c(Id = primeiroTrecho.Destino__c, Tipo__c='Offshore');
        update localDestino;

        IntervaloSol__c intervalo = new IntervaloSol__c(
            CodigoICAO__c = 'ABCD',
            Date__c = dataMissao,
            Sunrise__c = Time.newInstance(20, 0, 0, 0),
            Sunset__c = Time.newInstance(6, 0, 0, 0));
        insert intervalo;
        
        Local__c base = new Local__c(
            Name='Teste',
            Tipo__c='Onshore',
            Categoria__c='Base',
            Base__c=true,
            CodigoLocal__c='ABCD',
            CodigoICAO__c='ABCD',
            Status__c='Validado',
            Abastecimento__c='QAV',
            CoordenadasLatitudeGraus__c=22,
            CoordenadasLatitudeMinutos__c=22,
            CoordenadasLatitudeSegundos__c=0,
            CoordenadasLatitudeDirecao__c='S',
            CoordenadasLongitudeGraus__c=41,
            CoordenadasLongitudeMinutos__c=41,
            CoordenadasLongitudeSegundos__c=0);
        insert base;

        Aeronave__c aeronave = [SELECT Id, Name, BaseMae__c FROM Aeronave__c WHERE Id = :voo.Prefixo__c LIMIT 1];
        aeronave.BaseMae__c = base.Id;
        update aeronave;
    }

    @isTest
    static void ExecutarCalculoMissaoTest(){
        Voo__c voo = [SELECT Id, Prefixo__c, Prefixo__r.Name FROM Voo__c LIMIT 1];

        Map<Id, Voo__c> mapVooComTrecho = new Map<Id, Voo__c>(VoosSelector.newInstance().selectWithTrechosById(new Set<Id> {voo.Id}));
        List<Local__c> trajeto = Trechos.newInstance(mapVooComTrecho.get(voo.Id).Trechos__r).getTrajeto();
        
        Test.startTest();
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        cmr.ExecutarCalculoMissao(voo.Prefixo__r, trajeto, mapVooComTrecho.get(voo.Id).DataVoo__c.date());
        Test.stopTest();
    }
}