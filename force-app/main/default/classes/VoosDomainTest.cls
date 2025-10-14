@IsTest
private class VoosDomainTest {

    private static final Integer BULK_SIZE = 2;

    @TestSetup
    static void setup() {
       
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();

        // Custom bulk data with unique CNPJ to avoid duplicates
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                CNPJCPF__c = GeraCpfCnpj.cnpj(true),  // Unique CNPJ
                BillingCountry = 'Brasil',
                BillingCity = 'São Paulo',
                BillingPostalCode = '12345-678',
                BillingState = 'SP',
                BillingStreet = 'Rua Teste ' + i,
                Type = 'Cliente',
                Industry = 'Outros',
                Mercado__c = 'Nacional',
                Phone = '12345678' + i,
                ContribuinteICMS__c = 'Não',
                ContribuinteIPI__c = 'Não',
                ContribuinteISS__c = 'Não',
                BeneficioFiscal__c = 'Não',
                AutarquiaMista__c = 'Não',
                OptantePeloSimples__c = 'Não',
                EnderecoIgualEmpresa__c = 'Sim',
                ShippingState = 'RJ',
                ShippingCountry = 'Brasil',
                ShippingStreet = 'Av. Rio Branco ' + i,
                ShippingCity = 'Rio',
                ShippingPostalCode = '2222222' + i,
                Email__c = 'test' + i + '@email.com'
            );
            accounts.add(acc);
        }
        insert accounts;

        // Create bulk Contacts linked to Accounts
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Passageiro').getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Contact con = new Contact(
                LastName = 'Test Contact ' + i,
                AccountId = accounts[i].Id,
                Email = 'contact' + i + '@test.com',
                NumeroDocumento__c = GeraCpfCnpj.cpf(true),  // Unique CPF
                Nacionalidade__c = 'BR',
                TipoDocumento__c = 'RG',
                RecordTypeId = contactRecordTypeId
            );
            contacts.add(con);
        }
        insert contacts;

        // Create bulk Product2 for aircraft models
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Product2 prod = new Product2(
                Name = 'Model ' + i,
                IsActive = true,
                CapacidadePassageiros__c = 10,
                Autonomia__c = 500,
                Alcance__c = 2000,
                Velocidade__c = 140
            );
            products.add(prod);
        }
        insert products;

        // Create bulk Locais
        List<Local__c> locais = new List<Local__c>();

        Local__c base = new Local__c(
            Name = 'Local base',
            Tipo__c = 'Onshore',
            CodigoLocal__c = 'LOCB',
            Status__c = 'Validado',
            Coordenadas__Latitude__s = TestUtil.getRandomLatitude(),
            Coordenadas__Longitude__s = TestUtil.getRandomLongitude(),
            Base__c = true
        );
        insert base;
        for (Integer i = 0; i < BULK_SIZE * 2; i++) { 
            
            Local__c loc = new Local__c(
                Name = 'Local ' + i,
                Tipo__c = 'Onshore',
                CodigoLocal__c = 'LOC' + i,
                Status__c = 'Validado',
                Coordenadas__Latitude__s = TestUtil.getRandomLatitude(),
                Coordenadas__Longitude__s = TestUtil.getRandomLongitude()
            );
            locais.add(loc);
        }
        insert locais;

        
        // Create bulk Aeronaves linked to models
        List<Aeronave__c> aeronaves = new List<Aeronave__c>();
        Aeronave__c aero = TestUtil.createAeronave('PR-OOE', products[0], base);
        aeronaves.add(aero);

        insert aeronaves;

        // Dynamically get valid picklist values
        String validVooStatus = Voo__c.Status__c.getDescribe().getPicklistValues()[0].getValue();
        String validTrechoStatus = Trecho__c.Status__c.getDescribe().getPicklistValues()[0].getValue();
        String validTipo = Voo__c.Tipo__c.getDescribe().getPicklistValues()[0].getValue();

        // Create bulk Voos linked to Accounts and Aeronaves
        List<Voo__c> voos = new List<Voo__c>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Voo__c voo = new Voo__c(
                Status__c = 'Rascunho',
                Cliente__c = accounts[i].Id,
                Prefixo__c = aeronaves[0].Id,
                DataVoo__c = System.now().addDays(1 + i),
                Tipo__c = validTipo
            );
            voos.add(voo);
        }
        insert voos;

        // Create bulk Trechos linked to Voos, with Origins and Destinations from Locais
        List<Trecho__c> trechos = new List<Trecho__c>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Trecho__c trecho = new Trecho__c(
                Voo__c = voos[i].Id,
                Origem__c = locais[i].Id,
                Destino__c = locais[i + BULK_SIZE].Id,
                Status__c = validTrechoStatus,
                OrdemExecucao__c = 10,
                Tipo__c = 'Passageiros'
            );
            trechos.add(trecho);
        }
        insert trechos;

        // Create bulk Passageiros linked to Trechos and Contacts
        List<Passageiro__c> passageiros = new List<Passageiro__c>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Passageiro__c pass = new Passageiro__c(
                Trecho__c = trechos[i].Id,
                Contato__c = contacts[i].Id
            );
            passageiros.add(pass);
        }
        insert passageiros;
    }

    @IsTest
    static void testConstructor() {
        List<Voo__c> voosRecords = [SELECT Id FROM Voo__c LIMIT :BULK_SIZE];
        System.assertEquals(BULK_SIZE, voosRecords.size(), 'Bulk voos should be created');

        Test.startTest();
        Voos domain = (Voos) Application.Domain.newInstance(voosRecords);
        System.assertNotEquals(null, domain, 'Domain constructor should succeed');
        Test.stopTest();
    }

    @IsTest
    static void testValidationsAndTriggers() {
        // Dynamically get valid picklist value
        Schema.DescribeFieldResult statusField = Voo__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> statusEntries = statusField.getPicklistValues();
        String validStatus = statusEntries[0].getValue();

        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;  // Use real ID from setup

        List<Voo__c> voosRecords = [SELECT Id FROM Voo__c LIMIT :BULK_SIZE];

        List<Voo__c> voos = new List<Voo__c>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            Voo__c voo = voosRecords[i];
            voo.Status__c = 'Reservado';
            voo.Cliente__c = accountId;
            voo.DataVoo__c = System.now().addDays(1 + i * 10);
            voos.add(voo);
        }

        Test.startTest();
        update voos;
        System.assertEquals(BULK_SIZE, [SELECT COUNT() FROM Voo__c], 'Bulk insert should succeed');

        voos[0].Status__c = 'Cancelado';
        voos[0].MotivoCancelamento__c = 'Teste';

        update voos[0];
        delete voos[1];

        Test.stopTest();
    }

    // Add more tests for other methods, exceptions, edge cases...

}