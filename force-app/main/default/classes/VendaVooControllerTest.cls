@isTest
public with sharing class VendaVooControllerTest {
    @TestSetup
    static void makeData(){
        RevoTestUtil.ConfigurarOportunidadeShuttleSeat();
    }

    @IsTest
    static void testGetMalhaVoo(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        List<PesquisaMalha> result = VendaVooController.getMalhaVoo(acc.Id, localOrigem.Id, localDestino.Id, 1, Date.today() + 2, null);

        System.assertNotEquals(null, result);

    }

    @IsTest
    static void testeResumeShuttleSeat(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        List<PesquisaMalha> result = VendaVooController.getMalhaVoo(acc.Id, localOrigem.Id, localDestino.Id, 1, Date.today() + 2, null);

        VendaVooController.ShuttleSeatWrapper shuttleSeatWrapper = new VendaVooController.ShuttleSeatWrapper();
        shuttleSeatWrapper.productId = result[0].produto;
        shuttleSeatWrapper.routeId = result[0].malhaId;
        shuttleSeatWrapper.departurePointId = result[0].origem;
        shuttleSeatWrapper.destinationPointId = result[0].destino;
        shuttleSeatWrapper.flightDateTime = result[0].dataHora;
        shuttleSeatWrapper.quantity = 1;
        shuttleSeatWrapper.services = new List<VendaVooController.PackageServicesWrapper>();

        PesquisaMalha result2 = VendaVooController.resumeShuttleSeat(acc.Id, shuttleSeatWrapper, null);

        System.assertNotEquals(null, result2);

    }    

    @isTest
    static void testGetVooCharterClient(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        VendaVooController.DestinoCharter destinoCharter = new VendaVooController.DestinoCharter();
        destinoCharter.id = localOrigem.Id;

        VendaVooController.DestinoCharter destinoCharter2 = new VendaVooController.DestinoCharter();
        destinoCharter2.id = localDestino.Id;

        List<PesquisaCharter> result = VendaVooController.getVooCharterClient(new List<VendaVooController.DestinoCharter>{destinoCharter, destinoCharter2}, DateTime.now(), acc.Id, null);

        System.assertNotEquals(null, result);
    }


    @IsTest
    static void testResumeCharter(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        VendaVooController.DestinoCharter destinoCharter = new VendaVooController.DestinoCharter();
        destinoCharter.id = localOrigem.Id;

        VendaVooController.DestinoCharter destinoCharter2 = new VendaVooController.DestinoCharter();
        destinoCharter2.id = localDestino.Id;        

        List<PesquisaCharter> result = VendaVooController.getVooCharterClient(new List<VendaVooController.DestinoCharter>{destinoCharter, destinoCharter2}, DateTime.now(), acc.Id, null);

        VendaVooController.CharterWrapper charterWrapper = new VendaVooController.CharterWrapper();
        charterWrapper.productId = result[0].produto;
        charterWrapper.modeloId = result[0].modeloId;
        charterWrapper.route = new List<VendaVooController.DestinoCharter>();
        charterWrapper.route.add(destinoCharter);
        charterWrapper.route.add(destinoCharter2);
        charterWrapper.aircraftModel = result[0].modeloId;
        charterWrapper.flightDateTime = result[0].horarios[0].data;
        charterWrapper.services = new List<VendaVooController.PackageServicesWrapper>();

        PesquisaCharter result2 = VendaVooController.resumeCharter(acc.Id, charterWrapper, null);

        System.assertNotEquals(null, result2);

    }            

    @isTest
    static void testGetVooFullCabin(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        List<PesquisaFullCabin> result = VendaVooController.getVooFullCabin(acc.Id, localOrigem.Id, localDestino.Id, Date.today(), null);

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testResumeFullCabin(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'REVO' LIMIT 1];
        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        List<PesquisaFullCabin> result = VendaVooController.getVooFullCabin(acc.Id, localOrigem.Id, localDestino.Id, Date.today(), null);

        VendaVooController.FullCabinWrapper fullCabinWrapper = new VendaVooController.FullCabinWrapper();
        fullCabinWrapper.productId = result[0].produto;
        fullCabinWrapper.modeloId = result[0].modeloId;
        fullCabinWrapper.departurePointId = result[0].origem;
        fullCabinWrapper.destinationPointId = result[0].destino;
        fullCabinWrapper.flightDateTime = result[0].horarios[0].data;
        fullCabinWrapper.services = new List<VendaVooController.PackageServicesWrapper>();

        PesquisaFullCabin result2 = VendaVooController.resumeFullCabin(acc.Id, fullCabinWrapper, null);

        System.assertNotEquals(null, result2);

    }        

    @isTest
    static void testGetOpportunityLineItems(){
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1];

        List<OpportunityLineItem> result = VendaVooController.getOpportunityLineItems(oportunidade.Id);

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testIsInCommunity(){
        Boolean result = VendaVooController.isInCommunity();

        System.assertEquals(false, result);
    }

    @isTest
    static void testCreateOpportunityLineItem(){
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1];

        Product2 modelo1 = [SELECT Id FROM Product2 WHERE Name = 'H-135' LIMIT 1];

        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];

        Product2 produto1 = [SELECT Id FROM Product2 WHERE ProductCode = 'Shuttle Seat SBGR > SBGR' LIMIT 1];

        List<PesquisaMalha> pesquisaMalha = VendaVooController.getMalhaVoo(oportunidade.Id, localOrigem.Id, localDestino.Id, 1, Date.today() + 2, null);

        VendaVooController.VooShuttleWrapper vooShuttle = new VendaVooController.VooShuttleWrapper();
        vooShuttle.dataVoo = pesquisaMalha[0].dataHora;
        vooShuttle.produto = pesquisaMalha[0].produto;
        vooShuttle.modeloId = pesquisaMalha[0].modeloId;
        vooShuttle.voo = pesquisaMalha[0];

        List<OpportunityLineItem> result = VendaVooController.criarLinhasOportunidade('Shuttle', JSON.serialize(vooShuttle));

        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCreateOpportunityLineItemFullCabin(){
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1];

        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];
        
        List<PesquisaFullCabin> pesquisaFullCabin = VendaVooController.getVooFullCabin(oportunidade.Id, localOrigem.Id, localDestino.Id, Date.today(), null);

        VendaVooController.VooFullCabinWrapper vooFullCabin = new VendaVooController.VooFullCabinWrapper();
        vooFullCabin.dataHora = pesquisaFullCabin[0].horarios[0].data;
        vooFullCabin.produto = pesquisaFullCabin[0].produto;
        vooFullCabin.voo = pesquisaFullCabin[0].horarios[0];

        List<OpportunityLineItem> result = VendaVooController.criarLinhasOportunidade('FullCabin', JSON.serialize(vooFullCabin));

        System.assertNotEquals(null, result);

    }    

    @isTest
    static void testCreateOpportunityLineItemCharter(){
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE Type = 'ShuttleSeat' LIMIT 1];

        Local__c localOrigem = [SELECT Id FROM Local__c WHERE Name = 'Aeroporto Internacional de São Paulo - Guarulhos' LIMIT 1];
        Local__c localDestino = [SELECT Id FROM Local__c WHERE Name = 'São Paulo - Vl. Olímpia: Condomínio Edifício Paladio' LIMIT 1];
        
        VendaVooController.DestinoCharter destinoCharter = new VendaVooController.DestinoCharter();
        destinoCharter.id = localOrigem.Id;

        VendaVooController.DestinoCharter destinoCharter2 = new VendaVooController.DestinoCharter();
        destinoCharter2.id = localDestino.Id;

        List<PesquisaCharter> pesquisaCharter = VendaVooController.getVooCharterClient(new List<VendaVooController.DestinoCharter>{destinoCharter, destinoCharter2}, DateTime.now(), oportunidade.Id, null);

        VendaVooController.VooCharterWrapper vooCharter = new VendaVooController.VooCharterWrapper();
        vooCharter.dataHora = pesquisaCharter[0].horarios[0].data;
        vooCharter.produto = pesquisaCharter[0].produto;
        vooCharter.voo = pesquisaCharter[0].horarios[0];

        vooCharter.voo.precoUnitario = 100;
        vooCharter.voo.precoFinal = 100;
        vooCharter.voo.precoRevoSeats = 0;
        vooCharter.voo.precoFinalRevoSeats = 0;
        vooCharter.voo.tempoMissao = 1;

        List<OpportunityLineItem> result = VendaVooController.criarLinhasOportunidade('Charter', JSON.serialize(vooCharter));

        System.assertNotEquals(null, result);

    }    

    @isTest
    static void testAllInnerClasses() {
        // Teste da classe FlightRecalculateResumeWrapper
        VendaVooController.FlightRecalculateResumeWrapper resumeWrapper = new VendaVooController.FlightRecalculateResumeWrapper();
        resumeWrapper.priceBlockUntil = DateTime.now();
        resumeWrapper.shuttleSeats = new List<PesquisaMalha>();
        resumeWrapper.fullCabins = new List<PesquisaFullCabin>();
        resumeWrapper.charters = new List<PesquisaCharter>();
        
        System.assertNotEquals(null, resumeWrapper);
        System.assertNotEquals(null, resumeWrapper.priceBlockUntil);
        System.assertNotEquals(null, resumeWrapper.shuttleSeats);
        System.assertNotEquals(null, resumeWrapper.fullCabins);
        System.assertNotEquals(null, resumeWrapper.charters);

        // Teste da classe FlightRecalculateWrapper
        VendaVooController.FlightRecalculateWrapper recalculateWrapper = new VendaVooController.FlightRecalculateWrapper();
        recalculateWrapper.account = '001000000000001';
        recalculateWrapper.oppotunityType = 'ShuttleSeat';
        recalculateWrapper.promotionalCode = 'PROMO123';
        recalculateWrapper.shuttleSeats = new List<VendaVooController.ShuttleSeatWrapper>();
        recalculateWrapper.fullCabins = new List<VendaVooController.FullCabinWrapper>();
        recalculateWrapper.charters = new List<VendaVooController.CharterWrapper>();
        
        System.assertNotEquals(null, recalculateWrapper);
        System.assertEquals('001000000000001', recalculateWrapper.account);
        System.assertEquals('ShuttleSeat', recalculateWrapper.oppotunityType);
        System.assertEquals('PROMO123', recalculateWrapper.promotionalCode);

        // Teste da classe ShuttleSeatWrapper
        VendaVooController.ShuttleSeatWrapper shuttleSeatWrapper = new VendaVooController.ShuttleSeatWrapper();
        shuttleSeatWrapper.productId = '01t000000000001';
        shuttleSeatWrapper.routeId = 'a0X000000000001';
        shuttleSeatWrapper.departurePointId = 'a0Y000000000001';
        shuttleSeatWrapper.destinationPointId = 'a0Y000000000002';
        shuttleSeatWrapper.flightDateTime = DateTime.now().addDays(1);
        shuttleSeatWrapper.quantity = 2;
        shuttleSeatWrapper.services = new List<VendaVooController.PackageServicesWrapper>();
        
        System.assertNotEquals(null, shuttleSeatWrapper);
        System.assertEquals('01t000000000001', shuttleSeatWrapper.productId);
        System.assertEquals('a0X000000000001', shuttleSeatWrapper.routeId);
        System.assertEquals(2, shuttleSeatWrapper.quantity);

        // Teste da classe FullCabinWrapper
        VendaVooController.FullCabinWrapper fullCabinWrapper = new VendaVooController.FullCabinWrapper();
        fullCabinWrapper.productId = '01t000000000002';
        fullCabinWrapper.modeloId = '01t000000000003';
        fullCabinWrapper.departurePointId = 'a0Y000000000003';
        fullCabinWrapper.destinationPointId = 'a0Y000000000004';
        fullCabinWrapper.flightDateTime = DateTime.now().addDays(2);
        fullCabinWrapper.services = new List<VendaVooController.PackageServicesWrapper>();
        
        System.assertNotEquals(null, fullCabinWrapper);
        System.assertEquals('01t000000000002', fullCabinWrapper.productId);
        System.assertEquals('01t000000000003', fullCabinWrapper.modeloId);

        // Teste da classe CharterWrapper
        VendaVooController.CharterWrapper charterWrapper = new VendaVooController.CharterWrapper();
        charterWrapper.productId = '01t000000000004';
        charterWrapper.modeloId = '01t000000000005';
        charterWrapper.route = new List<VendaVooController.DestinoCharter>();
        charterWrapper.aircraftModel = 'H-135';
        charterWrapper.flightDateTime = DateTime.now().addDays(3);
        charterWrapper.services = new List<VendaVooController.PackageServicesWrapper>();
        
        System.assertNotEquals(null, charterWrapper);
        System.assertEquals('01t000000000004', charterWrapper.productId);
        System.assertEquals('H-135', charterWrapper.aircraftModel);

        // Teste da classe PackageServicesWrapper
        VendaVooController.PackageServicesWrapper packageServicesWrapper = new VendaVooController.PackageServicesWrapper();
        packageServicesWrapper.productId = '01t000000000006';
        packageServicesWrapper.quantity = 1;
        
        System.assertNotEquals(null, packageServicesWrapper);
        System.assertEquals('01t000000000006', packageServicesWrapper.productId);
        System.assertEquals(1, packageServicesWrapper.quantity);

        // Teste da classe VooShuttleWrapper
        VendaVooController.VooShuttleWrapper vooShuttleWrapper = new VendaVooController.VooShuttleWrapper();
        vooShuttleWrapper.dataVoo = DateTime.now().addDays(1);
        vooShuttleWrapper.produto = '01t000000000007';
        vooShuttleWrapper.modeloId = '01t000000000008';
        vooShuttleWrapper.voo = new PesquisaMalha();
        
        System.assertNotEquals(null, vooShuttleWrapper);
        System.assertEquals('01t000000000007', vooShuttleWrapper.produto);
        System.assertEquals('01t000000000008', vooShuttleWrapper.modeloId);

        // Teste da classe VooCharterWrapper
        VendaVooController.VooCharterWrapper vooCharterWrapper = new VendaVooController.VooCharterWrapper();
        vooCharterWrapper.dataHora = DateTime.now().addDays(2);
        vooCharterWrapper.produto = '01t000000000009';
        vooCharterWrapper.voo = null;
        
        System.assertNotEquals(null, vooCharterWrapper);
        System.assertEquals('01t000000000009', vooCharterWrapper.produto);

        // Teste da classe VooFullCabinWrapper
        VendaVooController.VooFullCabinWrapper vooFullCabinWrapper = new VendaVooController.VooFullCabinWrapper();
        vooFullCabinWrapper.dataHora = DateTime.now().addDays(3);
        vooFullCabinWrapper.produto = '01t000000000010';
        vooFullCabinWrapper.origem = 'a0Y000000000005';
        vooFullCabinWrapper.destino = 'a0Y000000000006';
        vooFullCabinWrapper.voo = null;
        
        System.assertNotEquals(null, vooFullCabinWrapper);
        System.assertEquals('01t000000000010', vooFullCabinWrapper.produto);
        System.assertEquals('a0Y000000000005', vooFullCabinWrapper.origem);
        System.assertEquals('a0Y000000000006', vooFullCabinWrapper.destino);

        // Teste da classe DestinoCharter
        VendaVooController.DestinoCharter destinoCharter = new VendaVooController.DestinoCharter();
        destinoCharter.sequencia = 1;
        destinoCharter.id = 'a0Y000000000007';
        destinoCharter.latitude = -23.5505;
        destinoCharter.longitude = -46.6333;
        
        System.assertNotEquals(null, destinoCharter);
        System.assertEquals(1, destinoCharter.sequencia);
        System.assertEquals('a0Y000000000007', destinoCharter.id);
        System.assertEquals(-23.5505, destinoCharter.latitude);
        System.assertEquals(-46.6333, destinoCharter.longitude);

        // Teste de serialização e deserialização das classes
        String serializedShuttleSeat = JSON.serialize(shuttleSeatWrapper);
        VendaVooController.ShuttleSeatWrapper deserializedShuttleSeat = (VendaVooController.ShuttleSeatWrapper)JSON.deserialize(serializedShuttleSeat, VendaVooController.ShuttleSeatWrapper.class);
        System.assertEquals(shuttleSeatWrapper.productId, deserializedShuttleSeat.productId);

        String serializedFullCabin = JSON.serialize(fullCabinWrapper);
        VendaVooController.FullCabinWrapper deserializedFullCabin = (VendaVooController.FullCabinWrapper)JSON.deserialize(serializedFullCabin, VendaVooController.FullCabinWrapper.class);
        System.assertEquals(fullCabinWrapper.productId, deserializedFullCabin.productId);

        String serializedCharter = JSON.serialize(charterWrapper);
        VendaVooController.CharterWrapper deserializedCharter = (VendaVooController.CharterWrapper)JSON.deserialize(serializedCharter, VendaVooController.CharterWrapper.class);
        System.assertEquals(charterWrapper.productId, deserializedCharter.productId);

        // Teste de listas das classes wrapper
        List<VendaVooController.ShuttleSeatWrapper> shuttleSeatList = new List<VendaVooController.ShuttleSeatWrapper>();
        shuttleSeatList.add(shuttleSeatWrapper);
        System.assertEquals(1, shuttleSeatList.size());

        List<VendaVooController.FullCabinWrapper> fullCabinList = new List<VendaVooController.FullCabinWrapper>();
        fullCabinList.add(fullCabinWrapper);
        System.assertEquals(1, fullCabinList.size());

        List<VendaVooController.CharterWrapper> charterList = new List<VendaVooController.CharterWrapper>();
        charterList.add(charterWrapper);
        System.assertEquals(1, charterList.size());

        List<VendaVooController.DestinoCharter> destinoCharterList = new List<VendaVooController.DestinoCharter>();
        destinoCharterList.add(destinoCharter);
        System.assertEquals(1, destinoCharterList.size());
    }


}