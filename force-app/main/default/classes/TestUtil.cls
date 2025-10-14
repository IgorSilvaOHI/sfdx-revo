@isTest
public class TestUtil {
    /* ########################################
     * # Métodos de Setup para Classes de Teste
     * ######################################## */

    public static Id SetupStandardPricebook() {
        Id standardPricebookId = Test.getStandardPricebookId();

        Boolean updated = false;
        Integer i = 0;
        do{
            i++;
            updated = false;
            try{
                update new Pricebook2(Id = standardPricebookId);
                updated = true;
            }catch(Exception e){
                updated = false;
            }
        }while ( i < 20 && !updated);

        return standardPricebookId;
    }

    public static void SetupAccountUserForTest() {
        TestUtil.SetupAccountUserForTest('frrm@gmail.com', 'test@gmail.com');
    }

    public static void SetupAccountUserForTest(
        String adminEmail,
        String userEmail
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        UserRole portalRole = TestUtil.getRoleByName('%Admin%');
        Profile profile1 = TestUtil.getProfileByName('%Admin%');

        User thisUser = TestUtil.createUser(adminEmail);
        thisUser.UserRoleId = portalRole.Id;
        thisUser.ProfileId = profile1.Id;
        uow.registerNew(thisUser);
        uow.commitWork();

        System.runAs(thisUser) {
            insereConfiguracoesGerais();
            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
            Account acc = TestUtil.createAccount('Voe Omni', true);
            uow2.registerNew(acc);

            Contact con = TestUtil.createContact(acc, 'Martins');
            con.Email = userEmail;
            Id contratante = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get('Contratante')
                .getRecordTypeId();
            con.RecordTypeId = contratante;
            uow2.registerNew(con);
            uow2.registerRelationship(con, Contact.AccountId, acc);
            Test.startTest();
            uow2.commitWork();
            Test.stopTest();
        }
    }

    public static void SetupPortalAccountOwner() {
        TestUtil.SetupPortalAccountOwner('frrm@gmail.com');
    }

    public static void SetupPortalAccountOwner(String email) {
        UserRole portalRole = TestUtil.getRoleByName('Especialista de TI');
        Profile profile = TestUtil.getProfileByName('Administrador do Sistema');
        if (profile == null) {
            profile = TestUtil.getProfileByName('System Administrator');
        }

        User portalAccountOwner1 = TestUtil.createUser(email);
        portalAccountOwner1.UserRoleId = portalRole.Id;
        portalAccountOwner1.ProfileId = profile.Id;

        Database.insert(portalAccountOwner1);
    }

    public static void SetupAccountContactVoo(
        String nome,
        String email,
        String statusVoo
    ) {
        Account acc = TestUtil.createAccount(nome);
        insert acc;
        Id recordTypeIdContact; 
        Map<String,Schema.RecordTypeInfo> recordTypeMapByName = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        if(recordTypeMapByName.get('Passageiro') != null){
            recordTypeIdContact = recordTypeMapByName.get('Passageiro').getRecordTypeId();
        } else{
            recordTypeIdContact = recordTypeMapByName.get('Passenger').getRecordTypeId();
        }
        Contact contact = TestUtil.createContact(acc, nome);
        contact.Email = email;
        contact.RecordTypeId = recordTypeIdContact;
        insert contact;
        acc = [SELECT Id, Name FROM Account LIMIT 1];
        contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = TestUtil.createVoo(acc.Id, statusVoo);
        insert voo;
    }

    public static void SetupAccountContactVooComTrecho(
        String nome,
        String email,
        String statusVoo,
        String statusTrecho
    ) {
        TestUtil.SetupAccountContactVoo(nome, email, statusVoo);
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];
        Trecho__c trecho = TestUtil.createTrecho(voo, 'Não Iniciado');
        insert trecho;
    }

    public static void SetupAccountContactVooComTrechoEPassageiro(
        String nome,
        String email,
        String statusVoo,
        String statusTrecho
    ) {
        TestUtil.SetupAccountContactVooComTrecho(
            nome,
            email,
            statusVoo,
            statusTrecho
        );
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Trecho__c trecho = [SELECT Id FROM Trecho__c LIMIT 1];
        Passageiro__c passageiro = TestUtil.createPassageiro(contact, trecho);
        insert passageiro;
    }

    public static void SetupAccountContactVooComTrechoEPassageiroECarga(
        String nome,
        String email,
        String statusVoo,
        String statusTrecho,
        String identificacao
    ) {
        TestUtil.SetupAccountContactVooComTrechoEPassageiro(
            nome,
            email,
            statusVoo,
            statusTrecho
        );
        Trecho__c trecho = [SELECT Id FROM Trecho__c LIMIT 1];
        Carga__c carga = TestUtil.createCarga(identificacao, trecho);
        insert carga;
    }

    /* ##################################################
     * # Métodos para Criação de Novos Objetos para Teste
     * ################################################## */

    public static void insereConstantesLead() {
        insert new ConstantesLead__c(
            TempoTrabalharLead__c = 40,
            AssuntoTarefaConversao__c = 'Trabalhar o Lead',
            PrazoNotificacaoTempoFila__c = 20
        );
    }

    public static void insereConfiguracoesPersonalizadas() {
        insert new ConfiguracoesTelaCustomizada__c(NumeroRotasRecentes__c = 10, DiferencaPesoDisponivel__c = 0);
        insert new ConfiguracaoTempo__c(
            TempoMinutos__c = 10,
            QtdDiasEnvioNovaPesquisaSatisfacao__c = 3,
            TempoPlanejamentoPos__c = 40,
            TempoPlanejamentoPre__c = 40,
            EntreVoosCharterPre__c = 40,
            EntreVoosCharterPos__c = 40,
            EntreVoosFullCabinPre__c = 40,
            EntreVoosFullCabinPos__c = 40,
            HoraFimSelecaoHorarioVoo__c = 12,
            HoraInicioSelecaoHorarioVoo__c = 8,
            MinutoFimSelecaoHorarioVoo__c = 0,
            MinutoInicioSelecaoHorarioVoo__c = 0,
            IntervaloMinutosSelecaoAeronaves__c = 30,
            MinutosBloqueioReservarVoo__c = 60,
            MinutosBloqueioSelecaoVoo__c = 30
        );
        Organization o = [SELECT isSandbox FROM Organization LIMIT 1];
        insert new ConfiguracoesGerais__c(
            IdPerfilComunidade__c = (o.isSandbox
                ? '00e3F000000HKVyQAO'
                : '00e3i000000uH06'),
            IdTemplateEmailPesquisaPassageiro__c = (o.isSandbox
                ? '00X3F000001MsxaUAC'
                : '00X3i000000hLVr'),
            IdRemetentePesquisaSatisfacao__c = (o.isSandbox
                ? '0D23F0000004JiFSAU'
                : '0D23i000000L02w'),
            IdTemplatePesquisaContratante__c = (o.isSandbox
                ? '00X3F000001MswmUAC'
                : '00X3i000000hLVm'),
            IdTipoRegistroContratante__c = (o.isSandbox
                ? '0123F000000tGYlQAM'
                : '0123i000000MaKPAA0')
        );
    }

    public static void insereConfiguracoesTelaCustomizada(
        Integer numTotalRotas
    ) {
        insert new ConfiguracoesTelaCustomizada__c(
            NumeroRotasRecentes__c = numTotalRotas,
            DiferencaPesoDisponivel__c = 0
        );
    }

    public static void insereConfiguracaoTempo() {
        insert new ConfiguracaoTempo__c(
            TempoMinutos__c = 10,
            QtdDiasEnvioNovaPesquisaSatisfacao__c = 3,
            TempoPlanejamentoPos__c = 40,
            TempoPlanejamentoPre__c = 40,
            HoraFimSelecaoHorarioVoo__c = 12,
            HoraInicioSelecaoHorarioVoo__c = 8,
            MinutoFimSelecaoHorarioVoo__c = 0,
            MinutoInicioSelecaoHorarioVoo__c = 0,
            IntervaloMinutosSelecaoAeronaves__c = 30
        );
    }

    public static void insereConfiguracoesGerais() {
        Organization o = [SELECT isSandbox FROM Organization LIMIT 1];
        insert new ConfiguracoesGerais__c(
            IdPerfilComunidade__c = '00e3i000000uH06',
            IdTemplateEmailPesquisaPassageiro__c = (o.isSandbox
                ? '00X3F000001MsxaUAC'
                : '00X3i000000hLVr'),
            IdRemetentePesquisaSatisfacao__c = (o.isSandbox
                ? '0D23F0000004JiFSAU'
                : '0D23i000000L02w'),
            IdTemplatePesquisaContratante__c = (o.isSandbox
                ? '00X3F000001MswmUAC'
                : '00X3i000000hLVm'),
            IdTipoRegistroContratante__c = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contratante').getRecordTypeId()
        );
    }

    public static List<Lead> carregaLeads(Integer numLeads) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < numLeads; i++) {
            Lead l = new Lead(
                LastName = 'LastName ' + i,
                Company = 'Company ' + i,
                Email = 'email@email.com' + i
            );
            leads.add(l);
        }
        return leads;
    }

    public static List<Account> carregaContas(Integer numContas) {
        List<Account> contas = new List<Account>();
        for (Integer i = 0; i < numContas; i++) {
            Account a = new Account(
                Name = 'Company' + i,
                RazaoSocial__c = 'Company Razão' + 1,
                Type = 'Cliente',
                CNPJCPF__c = '11.444.777/0001-61',
                Industry = 'Outros',
                Mercado__c = 'Nacional',
                Phone = '12345678',
                ContribuinteICMS__c = 'Não',
                ContribuinteIPI__c = 'Não',
                ContribuinteISS__c = 'Não',
                BeneficioFiscal__c = 'Não',
                AutarquiaMista__c = 'Não',
                OptantePeloSimples__c = 'Não',
                InscricaoEstadual__c = '72844165',
                EnderecoIgualEmpresa__c = 'Sim',
                ShippingState = 'RJ',
                ShippingCountry = 'Brasil',
                ShippingStreet = 'Av. Rio Branco',
                ShippingCity = 'Rio',
                ShippingPostalCode = '2222222',
                BillingCity = 'São Paulo',
                BillingState = 'SP',
                BillingPostalCode = '12345-678',
                BillingCountry = 'Brasil',
                BillingStreet = 'Rua Teste, 123',
                Email__c = 'teste@email.com'
            );
            contas.add(a);
        }
        return contas;
    }

    public static List<Voo__c> carregaVoos(
        Integer numVoos,
        List<Account> contas
    ) {
        List<Voo__c> voos = new List<Voo__c>();
        for (Account acc : contas) {
            for (Integer i = 0; i < numVoos; i++) {
                Voo__c v = new Voo__c(
                    Status__c = 'Rascunho',
                    Cliente__c = acc.Id
                );
                voos.add(v);
            }
        }
        return voos;
    }

    public static List<Local__c> carregaLocais(Integer numLocais) {
        List<Local__c> locais = new List<Local__c>();
        for (Integer i = 0; i < numLocais; i++) {
            Local__c lo = new Local__c();
            lo.Name = 'Local' + i;
            lo.Tipo__c = 'Onshore';
            lo.CodigoLocal__c = 'FP' + i;
            lo.Base__c = true;
            lo.RecordTypeId = Schema.SObjectType.Local__c.getRecordTypeInfosByDeveloperName().get('Padrao').getRecordTypeId();
            lo.CoordenadasLatitudeDirecao__c = '';
            lo.CoordenadasLongitudeDirecao__c = '';
            locais.add(lo);
        }
        return locais;
    }

    public static Local__c carregaLocal(
        String name,
        String codigoLocal,
        Decimal latitude,
        Decimal longitude,
        Id recordTypeId
    ) {
        return new Local__c(
            Name = name,
            CodigoLocal__c = codigoLocal,
            Coordenadas__Latitude__s = latitude,
            Coordenadas__Longitude__s = longitude,
            RecordTypeId = recordTypeId
        );
    }

    public static List<Trecho__c> carregaTrechos(
        List<Voo__c> voos,
        Local__c origem,
        Local__c destino
    ) {
        List<Trecho__c> trechos = new List<Trecho__c>();
        for (Voo__c voo : voos) {
            Trecho__c trecho = new Trecho__c();
            trecho.Voo__c = voo.Id;
            trecho.Origem__c = origem.Id;
            trecho.Destino__c = destino.Id;
            trechos.add(trecho);
        }
        return trechos;
    }

    public static List<Trecho__c> carregaDoisTrechosEmUmVoo(
        Voo__c voo,
        Local__c loc1,
        Local__c loc2
    ) {
        List<Trecho__c> trechos = new List<Trecho__c>();

        Trecho__c trecho1 = new Trecho__c();
        trecho1.Voo__c = voo.Id;
        trecho1.Origem__c = loc1.Id;
        trecho1.Destino__c = loc2.Id;
        trecho1.OrdemExecucao__c = 10;
        trechos.add(trecho1);

        Trecho__c trecho2 = new Trecho__c();
        trecho2.Voo__c = voo.Id;
        trecho2.Origem__c = loc2.Id;
        trecho2.Destino__c = loc1.Id;
        trecho2.OrdemExecucao__c = 20;
        trechos.add(trecho2);
        System.debug('trechos dentro do método: ' + trechos);
        return trechos;
    }

    public static List<Passageiro__c> carregaPassageiros(
        List<Trecho__c> trechos,
        List<Contact> contatos
    ) {
        List<Passageiro__c> passageiros = new List<Passageiro__c>();
        for (Trecho__c tre : trechos) {
            for (Contact ctt : contatos) {
                Passageiro__c ps = new Passageiro__c();
                ps.Trecho__c = tre.Id;
                ps.Contato__c = ctt.Id;
                passageiros.add(ps);
            }
        }
        return passageiros;
    }

    public static List<Contact> carregaContatos(
        Integer numContatos,
        List<Account> contas
    ) {
        List<Contact> contatos = new List<Contact>();
        for (Account c : contas) {
            for (Integer i = 0; i < numContatos; i++) {
                Contact ctt = new Contact();
                ctt.LastName = 'TestContato' + i;
                ctt.AccountId = c.Id;
                ctt.Nacionalidade__c = 'BR';
                ctt.Email =
                    'email.' +
                    i +
                    '@' +
                    c.Name.split(' ').get(0) +
                    '.com';
                ctt.NumeroDocumento__c = '390.533.447-05';
                ctt.TipoDocumento__c = 'RG';
                ctt.Reserva__c = true;
                ctt.EmissaoEmbarque__c = true;
                ctt.ConclusaoTrecho__c = true;
                ctt.ConclusaoVoo__c = true;
                ctt.Faturamento__c = true;
                contatos.add(ctt);
            }
        }
        return contatos;
    }

    public static List<Product2> carregarProdutos(Integer numProds) {
        List<Product2> prods = new List<Product2>();
        for (Integer i = 0; i < numProds; i++) {
            Product2 prod = new Product2();
            prod.Name = 'Product ' + i;
            prods.add(prod);
        }
        return prods;
    }

    //
    public static List<Pricebook2> carregarCatalogosPreco(Integer numPBs) {
        List<Pricebook2> catalogos = new List<Pricebook2>();
        Date dt = date.today();
        for (Integer i = 0; i < numPBs; i++) {
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'Pricebook ' + i;
            pb.IsActive = true;
            catalogos.add(pb);
        }
        return catalogos;
    }

    public static List<PriceBookEntry> carregaPBE(List<Product2> prods) {
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        for (Product2 prod : prods) {
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.UnitPrice = 3000;
            pbe.Pricebook2Id = Test.getStandardPricebookId();
            pbe.Product2Id = prod.Id;
            pbe.IsActive = true;
            pbes.add(pbe);
        }
        return pbes;
    }

    public static List<PricebookEntry> criarPBEs(
        List<Product2> produtos,
        Pricebook2 pricebook,
        fflib_ISObjectUnitOfWork uow
    ) {
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        for (Product2 prod : produtos) {
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.UnitPrice = 3000;
            pbe.IsActive = true;
            uow.registerRelationship(
                pbe,
                PricebookEntry.Pricebook2Id,
                pricebook
            );
            uow.registerRelationship(pbe, PricebookEntry.Product2Id, prod);
            pbes.add(pbe);
        }
        uow.registerNew(pbes);
        return pbes;
    }

    //Cria:
    // 1 Conta / 1 Voo / 2 Locais / 1 Trecho em cada Voo
    // Varia o número de Contato que depois se tornam passageiros
    public static void criaVooCompletoComPassageirosDaMesmaConta(
        Integer numPassageiros
    ) {
        //todo: quebrado por configurações de CEP na conta
        List<Account> contas = TestUtil.carregaContas(1);
        insert contas;
        //A quantidade de contatos na lista define a quantidade de passageiros por trecho criado
        List<Contact> contatos = TestUtil.carregaContatos(
            numPassageiros,
            contas
        );
        insert contatos;
        List<Voo__c> voos = TestUtil.carregaVoos(1, contas);
        insert voos;
        List<Local__c> locais = TestUtil.carregaLocais(2);
        insert locais;
        List<Trecho__c> trechos = TestUtil.carregaTrechos(
            voos,
            locais.get(0),
            locais.get(1)
        );
        insert trechos;
        List<Passageiro__c> passageiros = TestUtil.carregaPassageiros(
            trechos,
            contatos
        );
        insert passageiros;
    }

    public static List<Lead> criarLeads(
        fflib_ISObjectUnitOfWork uow,
        Integer numLeads
    ) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < numLeads; i++) {
            Lead l = new Lead(
                LastName = 'LeadLastName ' + i,
                Company = 'Company ' + i,
                Email = 'lead@email' + i + '.com',
                Status = 'Novo'
            );
            leads.add(l);
        }
        uow.registerNew(leads);
        return leads;
    }

    public static List<Account> criarContas(
        fflib_ISObjectUnitOfWork uow,
        Integer numContas
    ) {
        List<Account> contas = new List<Account>();
        for (Integer i = 0; i < numContas; i++) {
            Account a = new Account(
                Name = 'Company' + i,
                RazaoSocial__c = 'Company Razão' + 1,
                Type = 'Cliente',
                CNPJCPF__c = '11.444.777/0001-61',
                Industry = 'Outros',
                Mercado__c = 'Nacional',
                Phone = '12345678',
                ContribuinteICMS__c = 'Não',
                ContribuinteIPI__c = 'Não',
                ContribuinteISS__c = 'Não',
                BeneficioFiscal__c = 'Não',
                AutarquiaMista__c = 'Não',
                OptantePeloSimples__c = 'Não',
                InscricaoEstadual__c = '72844165',
                EnderecoIgualEmpresa__c = 'Sim',
                ShippingState = 'RJ',
                ShippingCountry = 'Brasil',
                ShippingStreet = 'Av. Rio Branco',
                ShippingCity = 'Rio',
                ShippingPostalCode = '2222222',
                BillingCity = 'São Paulo',
                BillingState = 'SP',
                BillingPostalCode = '12345-678',
                BillingCountry = 'Brasil',
                BillingStreet = 'Rua Teste, 123',
                Email__c = 'teste@email.com'
            );
            contas.add(a);
        }
        uow.registerNew(contas);
        return contas;
    }

    public static List<Contact> criarContatosPassageiros(
        fflib_ISObjectUnitOfWork uow,
        List<Account> contas,
        Integer numContatos
    ) {
        List<Contact> contatos = new List<Contact>();
        for (Account c : contas) {
            for (Integer i = 0; i < numContatos; i++) {
                Contact ctt = new Contact();
                ctt.LastName = 'TestContato' + i;
                ctt.Nacionalidade__c = 'BR';
                ctt.TipoDocumento__c = 'RG';
                ctt.NumeroDocumento__c = '1234567';
                ctt.Email =
                    'email.' +
                    i +
                    '@' +
                    c.Name.split(' ').get(0) +
                    '.com';
                ctt.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Passageiro').getRecordTypeId();
                uow.registerNew(ctt, Contact.AccountId, c);
                contatos.add(ctt);
            }
        }
        return contatos;
    }

    public static List<Contact> criarContatosContratantes(
        fflib_ISObjectUnitOfWork uow,
        List<Account> contas,
        Integer numContatos
    ) {
        List<Contact> contatos = new List<Contact>();
        for (Account c : contas) {
            for (Integer i = 0; i < numContatos; i++) {
                Contact ctt = new Contact();
                ctt.LastName = 'TestContato' + i;
                ctt.Nacionalidade__c = 'BR';
                ctt.TipoDocumento__c = 'RG';
                ctt.NumeroDocumento__c = '1234567';
                ctt.Email =
                    'email.' +
                    i +
                    '@' +
                    c.Name.split(' ').get(0) +
                    '.com';
                //ctt.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contratante').getRecordTypeId();
                uow.registerNew(ctt, Contact.AccountId, c);
                contatos.add(ctt);
            }
        }
        return contatos;
    }

    public static Contact criarUmContratante(Account conta, String lastname) {
        Contact ctt = new Contact();
        ctt.LastName = lastname;
        ctt.Nacionalidade__c = 'BR';
        ctt.TipoDocumento__c = 'RG';
        ctt.NumeroDocumento__c = '1234567';
        ctt.Email = lastname.replace(' ', '') + '@email.com';
        return ctt;
    }

    public static List<Voo__c> criarVoos(
        fflib_ISObjectUnitOfWork uow,
        Integer numVoos,
        List<Account> contas
    ) {
        List<Aeronave__c> aeronaves = createAeronaves(uow, 1);

        List<Voo__c> voos = new List<Voo__c>();
        for (Account conta : contas) {
            for (Integer i = 0; i < numVoos; i++) {
                Voo__c v = new Voo__c();
                v.Status__c = 'Rascunho';
                v.DataVoo__c = System.Now() + 1;
                //uow.registerRelationship(v, Voo__c.Cliente__c, conta);
                uow.registerNew(v, Voo__c.Cliente__c, conta);
                uow.registerRelationship(
                    v,
                    Voo__c.Prefixo__c,
                    aeronaves.get(0)
                );
                voos.add(v);
            }
        }
        return voos;
    }

    public static List<Local__c> criarLocais(
        fflib_ISObjectUnitOfWork uow,
        Integer numLocais
    ) {
        List<Local__c> locais = new List<Local__c>();
        for (Integer i = 0; i < numLocais; i++) {
            Local__c lo = new Local__c();
            lo.Name = 'Local' + i + DateTime.now().getTime();
            lo.Tipo__c = 'Onshore';
            lo.CodigoICAO__c = 'sbrj';
            //lo.Subtipo__c = 'Fixa';
            //lo.Coordenadas__Latitude__s = Math.random() * 90;
            //lo.Coordenadas__Longitude__s = Math.random() * 90;
            lo.CodigoLocal__c = 'FP' + i + +DateTime.now().getTime();
            lo.CoordenadasLatitudeDirecao__c = 'S';
            lo.CoordenadasLatitudeGraus__c = Math.random() * 90;
            lo.CoordenadasLatitudeMinutos__c = Math.random() * 59;
            lo.CoordenadasLatitudeSegundos__c = Math.random() * 59;
            lo.CoordenadasLongitudeDirecao__c = 'O';
            lo.CoordenadasLongitudeGraus__c = Math.random() * 90;
            lo.CoordenadasLongitudeMinutos__c = Math.random() * 59;
            lo.CoordenadasLongitudeSegundos__c = Math.random() * 59;
            lo.Status__c = 'Validado';
            locais.add(lo);
        }
        uow.registerNew(locais);
        return locais;
    }

    public static List<Local__c> criarLocaisComNomes(
        fflib_ISObjectUnitOfWork uow,
        Integer numLocais
    ) {
        List<Local__c> locais = new List<Local__c>();
        for (Integer i = 0; i < numLocais; i++) {
            Local__c lo = new Local__c();
            lo.Name = 'Local' + i;
            lo.Tipo__c = 'Onshore';
            //lo.Subtipo__c = 'Fixa';
            lo.CodigoLocal__c = 'FP' + i;
            lo.CoordenadasLatitudeGraus__c = 22;
            lo.CoordenadasLatitudeMinutos__c = 20;
            lo.CoordenadasLatitudeSegundos__c = 41;
            lo.CoordenadasLatitudeDirecao__c = 'S';
            lo.CoordenadasLongitudeGraus__c = 41;
            lo.CoordenadasLongitudeMinutos__c = 46;
            lo.CoordenadasLongitudeSegundos__c = 7;
            lo.CoordenadasLongitudeDirecao__c = 'O';
            locais.add(lo);
        }
        uow.registerNew(locais);
        return locais;
    }

    public static List<Trecho__c> criarTrechos(
        fflib_ISObjectUnitOfWork uow,
        List<Voo__c> voos,
        Local__c origem,
        Local__c destino,
        Integer numTrechos
    ) {
        List<Trecho__c> trechos = new List<Trecho__c>();
        for (Voo__c voo : voos) {
            for (Integer i = 0; i < numTrechos; i++) {
                Trecho__c trecho = new Trecho__c(
                    Status__c = 'Não Iniciado',
                    OrdemExecucao__c = i
                );
                uow.registerRelationship(trecho, Trecho__c.Origem__c, origem);
                uow.registerRelationship(trecho, Trecho__c.Destino__c, destino);
                uow.registerNew(trecho, Trecho__c.Voo__c, voo);
                trechos.add(trecho);
            }
        }
        return trechos;
    }

    public static List<Passageiro__c> criarPassageiros(
        fflib_ISObjectUnitOfWork uow,
        List<Trecho__c> trechos,
        List<Contact> contatos
    ) {
        List<Passageiro__c> passageiros = new List<Passageiro__c>();
        for (Trecho__c trecho : trechos) {
            for (Contact contato : contatos) {
                Passageiro__c passageiro = new Passageiro__c();
                uow.registerRelationship(
                    passageiro,
                    Passageiro__c.Trecho__c,
                    trecho
                );
                uow.registerNew(passageiro, Passageiro__c.Contato__c, contato);
                passageiros.add(passageiro);
            }
        }
        return passageiros;
    }

    public static void create1Voo2Locais2Trechos2Passageiros() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil.criarLocaisComNomes(uow, 2);
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Contact> contatos = TestUtil.criarContatosPassageiros(uow, contas, 2);
        List<Aeronave__c> aeronaves = TestUtil.createAeronaves(uow, 1);
        System.debug('aeronaves ' + aeronaves);
        Voo__c voo = new Voo__c(
            Status__c = 'Rascunho',
            DataVoo__c = Datetime.now().addMinutes(45)
        );
        uow.registerRelationship(voo, Voo__c.Cliente__c, contas.get(0));
        uow.registerRelationship(voo, Voo__c.Prefixo__c, aeronaves.get(0));
        uow.registerNew(voo);
        
        Trecho__c trecho1 = new Trecho__c(OrdemExecucao__c = 10);
        uow.registerNew(trecho1);
        uow.registerRelationship(trecho1, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho1, Trecho__c.Origem__c, locais.get(0));
        uow.registerRelationship(trecho1, Trecho__c.Destino__c, locais.get(1));
        
        Trecho__c trecho2 = new Trecho__c(OrdemExecucao__c = 20);
        uow.registerNew(trecho2);
        uow.registerRelationship(trecho2, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho2, Trecho__c.Origem__c, locais.get(1));
        uow.registerRelationship(trecho2, Trecho__c.Destino__c, locais.get(0));
        
        List<Passageiro__c> passageiros = TestUtil.criarPassageiros(
            uow,
            new List<Trecho__c>{ trecho1, trecho2 },
            contatos
        );
        System.debug('todos aeronaves ' + [SELECT Name FROM Aeronave__c]);
        uow.commitWork();
    }

    public static List<Carga__c> criarCargas(
        fflib_ISObjectUnitOfWork uow,
        List<Trecho__c> trechos,
        Integer numCargas
    ) {
        List<Carga__c> cargas = new List<Carga__c>();
        for (Trecho__c trecho : trechos) {
            for (Integer i = 0; i < numCargas; i++) {
                Carga__c carga = new Carga__c();
                uow.registerNew(carga, Carga__c.Trecho__c, trecho);
                cargas.add(carga);
            }
        }
        return cargas;
    }

    public static List<ContentVersion> criarContentVersions(
        Integer numContentDocuments
    ) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < numContentDocuments; i++) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'Arquivo'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Arquivo'; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode('txt'); // converting your binary string to Blog
            conVer.Origin = 'C';
            contentVersions.add(conVer);
        }
        return contentVersions;
    }

    ///https://andyinthecloud.com/2014/07/17/doing-more-work-with-the-unit-of-work/
    //provavelmente o método mais correto inclui esse DoWork
    public static List<ContentDocumentLink> criarContentDocumentLinks(
        fflib_ISObjectUnitOfWork uow,
        List<ContentVersion> contentVersions,
        List<SObject> objetos
    ) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for (SObject objeto : objetos) {
            for (ContentVersion version : contentVersions) {
                ContentDocumentLink cDe = new ContentDocumentLink();
                uow.registerRelationship(
                    cDe,
                    ContentDocumentLink.LinkedEntityId,
                    objeto
                );
                cDe.ContentDocumentId = version.ContentDocumentId;
                cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                cDe.Visibility = 'AllUsers';
                contentDocumentLinks.add(cDe);
            }
        }
        uow.registerNew(contentDocumentLinks);
        return contentDocumentLinks;
    }

    public static void criarVooComPassageirosECargas(
        fflib_ISObjectUnitOfWork uow,
        Integer numContas,
        Integer numVoos,
        Integer numTrechos,
        Integer numPassageiros,
        Integer numCargas
    ) {
        List<Account> contas = criarContas(uow, numContas);
        List<Contact> contatos = criarContatosPassageiros(
            uow,
            contas,
            numPassageiros
        );
        List<Voo__c> voos = criarVoos(uow, numVoos, contas);
        List<Local__c> locais = criarLocais(uow, 2);
        List<Trecho__c> trechos = criarTrechos(
            uow,
            voos,
            locais.get(0),
            locais.get(1),
            numTrechos
        );
        List<Passageiro__c> passageiros = criarPassageiros(
            uow,
            trechos,
            contatos
        );
        List<Carga__c> cargas = criarCargas(uow, trechos, numCargas);
        //pode ser adicionado um wrapper para retornar esses objetos caso seja necessário
    }

    public static void criarVooComContratanteECargas(
        fflib_ISObjectUnitOfWork uow,
        Integer numContas,
        Integer numVoos,
        Integer numTrechos,
        Integer numContratantes,
        Integer numCargas
    ) {
        List<Account> contas = criarContas(uow, numContas);
        List<Contact> contratantes = criarContatosContratantes(
            uow,
            contas,
            numContratantes
        );
        List<Voo__c> voos = criarVoos(uow, numVoos, contas);
        List<Local__c> locais = criarLocais(uow, 2);
        List<Trecho__c> trechos = criarTrechos(
            uow,
            voos,
            locais.get(0),
            locais.get(1),
            numTrechos
        );
        List<Passageiro__c> passageiros = criarPassageiros(
            uow,
            trechos,
            contratantes
        );
        List<Carga__c> cargas = criarCargas(uow, trechos, numCargas);
        //pode ser adicionado um wrapper para retornar esses objetos caso seja necessário
    }

    public static void criarVoosComTrechos(
        fflib_ISObjectUnitOfWork uow,
        Integer numContas,
        Integer numVoos,
        Integer numTrechos
    ) {
        List<Account> contas = criarContas(uow, numContas);
        Integer numLocais = numTrechos * 2 * numVoos;
        List<Local__c> locais = criarLocais(uow, numLocais);
        Integer posicaoLocal = 0;
        for (Integer i = 1; i <= numVoos; i++) {
            List<Voo__c> voos = criarVoos(uow, 1, contas);
            List<Trecho__c> trechos = new List<Trecho__c>();
            for (Integer j = 1; j <= numTrechos; j++) {
                criarTrechos(
                    uow,
                    voos,
                    locais.get(posicaoLocal),
                    locais.get(posicaoLocal + 1),
                    1
                );
                posicaoLocal++;
            }
        }
        //pode ser adicionado um wrapper para retornar esses objetos caso seja necessário
    }

    public static List<Event> criarEventos(
        Id calendarioId,
        String assuntoEvento,
        String recordTypeName,
        List<Datetime> inicios,
        Integer duracao,
        fflib_ISObjectUnitOfWork uow
    ) {
        Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
            .get(recordTypeName)
            .getRecordTypeId();
        List<Event> eventos = new List<Event>();
        for (Datetime inicio : inicios) {
            Event evento = new Event(
                Subject = assuntoEvento,
                OwnerId = calendarioId,
                RecordTypeId = recordTypeId,
                DurationInMinutes = duracao,
                ActivityDateTime = inicio,
                StartDateTime = inicio,
                EndDateTIme = inicio.addMinutes(duracao)
            );
            eventos.add(evento);
        }
        uow.registerNew(eventos);
        return eventos;
    }

    public static void criarDeContaAteAnexoCargas() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Integer numCargasTrecho = 2;

        List<Account> contas = criarContas(uow, 1);
        List<Voo__c> voos = criarVoos(uow, 1, contas);
        List<Local__c> locais = criarLocais(uow, 2);
        List<Trecho__c> trechos = criarTrechos(
            uow,
            voos,
            locais.get(0),
            locais.get(1),
            2
        );
        List<Carga__c> cargas = criarCargas(uow, trechos, numCargasTrecho);
        uow.commitWork();

        // Unit of Work não suporta contentVersion, e para pegar o ContentDocumentId para relacionar no contentDocumentLink precisa fazer uma query nele
        List<ContentVersion> contentVersions = criarContentVersions(2);
        insert contentVersions;
        contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion];

        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
        List<ContentDocumentLink> contentDocumentLinks = criarContentDocumentLinks(
            uow2,
            contentVersions,
            cargas
        );
        uow2.commitWork();
    }

    public static Account createAccount(
        String nome,
        Boolean byPassValidationRules
    ) {
        String cnpj = GeraCpfCnpj.cnpj(true);
        Account acc = new Account(
            Name = nome,
            RazaoSocial__c = 'Company' + nome,
            Type = 'Cliente',
            CNPJCPF__c = '11.444.777/0001-61',
            Industry = 'Outros',
            Mercado__c = 'Nacional',
            Phone = '12345678',
            ContribuinteICMS__c = 'Não',
            ContribuinteIPI__c = 'Não',
            ContribuinteISS__c = 'Não',
            BeneficioFiscal__c = 'Não',
            AutarquiaMista__c = 'Não',
            OptantePeloSimples__c = 'Não',
            InscricaoEstadual__c = '9116827578678',
            EnderecoIgualEmpresa__c = 'Sim',
            ShippingState = 'MG',
            ShippingCountry = 'Brasil',
            ShippingStreet = 'Rua Lourival Campos Réis',
            ShippingCity = 'Carmo da Cachoeira',
            ShippingPostalCode = '37225-000',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '12345-678',
            BillingCountry = 'Brasil',
            BillingStreet = 'Rua Teste, 123',
            Email__c = 'teste@email.com'
        );
        return acc;
    }

    public static Account createAccount(String nome) {
        return TestUtil.createAccount(nome, false);
    }

    public static FeedItem createFeedItem(
        Id contaId,
        String body,
        String title
    ) {
        FeedItem feedItem = new FeedItem();
        feedItem.Body = (body != null ? body : 'Hello there!');
        feedItem.ParentId = contaId;
        feedItem.Title = (title != null ? title : 'Title');
        return feedItem;
    }

    public static FeedComment createFeedComment(
        Id feedItemId,
        String comentario
    ) {
        FeedComment feedComment = new FeedComment();
        feedComment.CommentBody = (comentario != null
            ? comentario
            : 'Comentário');
        feedComment.FeedItemId = feedItemId;
        return feedComment;
    }

    public static Contact createContactPassageiro(Account conta, String nome) {
        Contact contato = createContact(conta, nome);
        contato.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Passageiro').getRecordTypeId();
        return contato;
    }

    public static Contact createContact(Account conta, String nome) {
        Contact contato = new Contact();
        contato.AccountId = conta?.Id;
        contato.LastName = nome;
        contato.Nacionalidade__c = 'BR';
        contato.Email = nome.replace(' ', '') + '@email.com';
        contato.NumeroDocumento__c = GeraCpfCnpj.cpf(true);
        contato.TipoDocumento__c = 'CPF';
        contato.Phone = '1133334444';
        contato.Reserva__c = true;
        contato.EmissaoEmbarque__c = true;
        contato.ConclusaoTrecho__c = true;
        contato.ConclusaoVoo__c = true;
        contato.Faturamento__c = true;
        contato.TakeoffReport__c = true;
        
        return contato;
    }

    public static User createUser(String email) {
        User user = new User(
            Username = email + System.now().millisecond(),
            Alias = 'sfdc',
            Email = email,
            ProfileId = Userinfo.getProfileId(),
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Dhanik',
            Lastname = 'Sahni',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );

        return user;
    }

    /* Método Busca Utilizando Like. Irá retornar apenas o Primeiro Papel encontrado
     * com nome de papel informado ou parte do nome informado */
    public static UserRole getRoleByName(String roleName) {
        UserRole portalRole = [
            SELECT Id
            FROM UserRole
            WHERE Name LIKE :roleName
            LIMIT 1
        ];
        return portalRole;
    }

    /* Método Busca Utilizando Like. Irá retornar apenas o Primeiro Perfil encontrado
     * com nome do perfil informado ou parte do nome informado */
    public static Profile getProfileByName(String profileName) {
        List<Profile> profiles = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE :profileName
            LIMIT 1
        ];
        if (profiles.size()>0) {
            return profiles[0];    
        }
        return null;
    }

    /* Integração do Firebase */
    public static Integracao__mdt getIntegracaoFirebase() {
        Integracao__mdt integracao = [
            SELECT AccessToken__c, Endpoint__c
            FROM Integracao__mdt
            WHERE DeveloperName = 'FirebaseCloudMessaging'
            LIMIT 1
        ];
        return integracao;
    }

    public static Voo__c createVoo(Id contaId, String status) {
        Voo__c voo = new Voo__c();
        Datetime agora = Datetime.now();
        voo.DataVoo__c = agora.addHours(2);
        voo.Cliente__c = contaId;
        voo.Status__c = status;
        return voo;
    }

    public static Trecho__c createTrecho(Voo__c voo, String status) {
        /*List<Local__c> locais = new List<Local__c>
        {
            new Local__c(Name='local1',CodigoLocal__c='cod1',Coordenadas__Latitude__s = 1,Coordenadas__Longitude__s = 2, Tipo__c='Offshore'),
                new Local__c(Name='local2',CodigoLocal__c='cod2',Coordenadas__Latitude__s = 2,Coordenadas__Longitude__s = 1, Tipo__c='Onshore')
                };*/

        List<Local__c> locais = TestUtil.carregaLocais(2);
        locais[0].Coordenadas__Latitude__s = 10.1010;
        locais[0].Coordenadas__Longitude__s = 10.1010;
        locais[0].CodigoLocal__c = 'cod1';
        locais[0].Name = 'local1';
        locais[0].Tipo__c = 'Offshore';
        locais[1].Coordenadas__Latitude__s = 40.1510;
        locais[1].Coordenadas__Longitude__s = 40.1510;
        locais[1].CodigoLocal__c = 'cod2';
        locais[1].Tipo__c = 'Onshore';
        locais[1].Name = 'local2';
        insert locais;
        Trecho__c trecho = new Trecho__c();
        trecho.Voo__c = voo.Id;
        trecho.Origem__c = locais.get(0).Id;
        trecho.Destino__c = locais.get(1).Id;
        trecho.Status__c = status;
        return trecho;
    }

    public static Passageiro__c createPassageiro(
        Contact contact,
        Trecho__c trecho
    ) {
        Passageiro__c passageiro = new Passageiro__c();
        passageiro.Contato__c = contact.Id;
        passageiro.Trecho__c = trecho.Id;
        return passageiro;
    }

    public static Carga__c createCarga(String identificacao, Trecho__c trecho) {
        Carga__c carga = new Carga__c();
        carga.Altura__c = 20; 
        carga.Largura__c = 20;
        carga.Peso__c = 20;
        carga.Profundidade__c = 20;
        carga.Trecho__c = trecho.Id;
        return carga;
    }

    public static Map<String, Schema.SObjectField> getSObjectSchema(
        String objectName
    ) {
        Map<String, Schema.SObjectField> schema = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields.getMap();
        return schema;
    }

    public static void create1Voo3Locais3Trechos() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil.criarLocaisComNomes(uow, 3);
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Aeronave__c> aeronaves = TestUtil.createAeronaves(uow, 1);
        Voo__c voo = new Voo__c(
            Status__c = 'Rascunho',
            DataVoo__c = Datetime.now().addMinutes(45)
        );
        uow.registerRelationship(voo, Voo__c.Cliente__c, contas.get(0));
        uow.registerRelationship(voo, Voo__c.Prefixo__c, aeronaves.get(0));
        uow.registerNew(voo);
        Trecho__c trecho1 = new Trecho__c(OrdemExecucao__c = 10);
        uow.registerNew(trecho1);
        uow.registerRelationship(trecho1, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho1, Trecho__c.Origem__c, locais.get(0));
        uow.registerRelationship(trecho1, Trecho__c.Destino__c, locais.get(1));
        Trecho__c trecho2 = new Trecho__c(OrdemExecucao__c = 20);
        uow.registerNew(trecho2);
        uow.registerRelationship(trecho2, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho2, Trecho__c.Origem__c, locais.get(1));
        uow.registerRelationship(trecho2, Trecho__c.Destino__c, locais.get(2));
        Trecho__c trecho3 = new Trecho__c(OrdemExecucao__c = 30);
        uow.registerNew(trecho3);
        uow.registerRelationship(trecho3, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho3, Trecho__c.Origem__c, locais.get(2));
        uow.registerRelationship(trecho3, Trecho__c.Destino__c, locais.get(0));
        uow.commitWork();
    }

    public static void create1Voo2Locais2Trechos() {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil.criarLocaisComNomes(uow, 2);
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Aeronave__c> aeronaves = TestUtil.createAeronaves(uow, 1);
        Voo__c voo = new Voo__c(
            Status__c = 'Rascunho',
            DataVoo__c = Date.today().addDays(1)
        );
        uow.registerRelationship(voo, Voo__c.Cliente__c, contas.get(0));
        uow.registerRelationship(voo, Voo__c.Prefixo__c, aeronaves.get(0));
        uow.registerNew(voo);
        Trecho__c trecho1 = new Trecho__c(
            OrdemExecucao__c = 10,
            Ligado__c = voo.DataVoo__c
        );
        uow.registerNew(trecho1);
        uow.registerRelationship(trecho1, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho1, Trecho__c.Origem__c, locais.get(0));
        uow.registerRelationship(trecho1, Trecho__c.Destino__c, locais.get(1));
        Trecho__c trecho2 = new Trecho__c(
            OrdemExecucao__c = 20,
            Ligado__c = voo.DataVoo__c
        );
        uow.registerNew(trecho2);
        uow.registerRelationship(trecho2, Trecho__c.Voo__c, voo);
        uow.registerRelationship(trecho2, Trecho__c.Origem__c, locais.get(1));
        uow.registerRelationship(trecho2, Trecho__c.Destino__c, locais.get(0));
        uow.commitWork();
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            StartDate = System.today().addDays(1),
            EndDate = System.today().addDays(10)
        );
        return contract;
    }

    public static List<Aeronave__c> createAeronaves(
        fflib_ISObjectUnitOfWork uow,
        Integer numAeronaves
    ) {
        List<Aeronave__C> aeronaves = new List<Aeronave__c>();
        List<Product2> products = new List<Product2>();
        Local__c baseMae = new Local__c();
        baseMae.CodigoLocal__c = 'test1';
        baseMae.Base__c = true;
        uow.registerNew(baseMae);
        for (Integer index = 0; index < numAeronaves; index++) {
            Product2 modelo = TestUtil.createProduct('Modelo ' + index);
            products.add(modelo);
            Aeronave__c aeronave = TestUtil.createAeronave(
                'Aeronave ' + index,
                modelo
            );
            uow.registerRelationship(aeronave, Aeronave__c.BaseMae__c, baseMae);
            aeronaves.add(aeronave);
            uow.registerNew(aeronave);
            uow.registerNew(modelo);
            uow.registerRelationship(
                aeronave,
                Aeronave__c.ModeloAeronave__c,
                modelo
            );
        }
        return aeronaves;
    }

    public static Aeronave__c carregaAeronave(String name) {
        return new Aeronave__c(Name = name);
    }

    public static Aeronave__c carregaAeronave2(String name) {
        Product2 modelo = TestUtil.createProduct('Modelo ' + 1);
        insert modelo;

        return TestUtil.createAeronave(name, modelo);
    }

    public static Event createEvent(
        String name,
        String calendarName,
        String eventRecordTypeName,
        Datetime startDateTime,
        Integer durationInMinutes
    ) {
        List<Calendar> calendarList = [
            SELECT Id, Name
            FROM Calendar
            WHERE Name = :calendarName
        ];
        Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
            .get(eventRecordTypeName)
            .getRecordTypeId();
        Event event = new Event(
            Subject = name,
            OwnerId = calendarList[0].Id,
            RecordTypeId = recordTypeId,
            DurationInMinutes = durationInMinutes,
            ActivityDateTime = startDateTime,
            StartDateTime = startDateTime,
            EndDateTIme = startDateTime.addMinutes(durationInMinutes)
        );

        return event;
    }

    public static List<IntervaloSol__c> criarIntervaloSol(
        fflib_ISObjectUnitOfWork uow,
        Set<String> ICAOCodes,
        Integer quantidadeDias
    ) {
        List<IntervaloSol__c> intervalos = new List<IntervaloSol__c>();
        for (Integer i = 0; i < quantidadeDias; i++) {
            IntervaloSol__c intervalo = new IntervaloSol__c();
            intervalo.Aero__c = 'sbrj';
            intervalo.CodigoICAO__c = intervalo.Aero__c;
            intervalo.Date__c = System.now().addDays(i).date();
            intervalo.Sunrise__c = Time.newInstance(6, 0, 0, 0);
            intervalo.Sunset__c = Time.newInstance(19, 0, 0, 0);
            intervalos.add(intervalo);

            if (i != 0) {
                intervalo = new IntervaloSol__c();
                intervalo.Aero__c = 'sbrj';
                intervalo.CodigoICAO__c = intervalo.Aero__c;
                intervalo.Date__c = System.now().addDays(-i).date();
                intervalo.Sunrise__c = Time.newInstance(6, 0, 0, 0);
                intervalo.Sunset__c = Time.newInstance(19, 0, 0, 0);
                intervalos.add(intervalo);
            }
        }
        return intervalos;
    }

    public static Product2 createProduct() {
        return createProduct('AW139', 'Médio');
    }

    public static Product2 createProduct(String name) {
        return createProduct(name, 'Médio');
    }

    public static Product2 createProduct(String name, String porte) {
        Product2 prod = new Product2(
            Name = name,
            Porte__c = porte,
            CapacidadePassageiros__c = 12,
            Autonomia__c = 500,
            Alcance__c = 2000,
            Velocidade__c = 140,
            IsActive = true
        );
        return prod;
    }

    public static Aeronave__c createAeronave(
        String name,
        Product2 modeloAeronave
    ) {
        return createAeronave(name, modeloAeronave, null);
    }

    public static Aeronave__c createAeronave(
        String name,
        Product2 modeloAeronave,
        Local__c baseMae
    ) {
        Aeronave__c aeronave = new Aeronave__c(
            Name = name,
            ModeloAeronave__c = modeloAeronave.Id,
            PesoBasicoOperacional__c = 3000,
            PesoMaximoDecolagem__c = 10000,
            BaseMae__c = (baseMae == null ? null : baseMae.Id),
            TipoOperacao__c = 'Spot',
            VelocidadeCruzeiro__c = 140,
            ConsumoHoraSolo__c = 360,
            ConsumoHoraVoo__c = 1,
            LarguraBagageiro__c = 1.5,
            AlturaBagageiro__c = 1,
            ProfundidadeBagageiro__c = 1.5,
            TipoCombustivel__c = 'QAV',
            Tamanho__c = 50,
            CapacidadeTotalCombustivel__c = 1670
        );
        return aeronave;
    }

    public static Local__c createLocal(
        String Name,
        String Tipo,
        String Categoria,
        Boolean Base,
        Double CapacidadeMaxima,
        String CodigoLocal,
        String CodigoICAO,
        Id Cliente,
        String Status,
        Double Tamanho,
        String Abastecimento,
        Double CoordenadasLatitudeGraus,
        Double CoordenadasLatitudeMinutos,
        Double CoordenadasLatitudeSegundos,
        String CoordenadasLatitudeDirecao,
        Double CoordenadasLongitudeGraus,
        Double CoordenadasLongitudeMinutos,
        Double CoordenadasLongitudeSegundos,
        String CoordenadasLongitudeDirecao
    ) {
        Local__c local = new Local__c(
            Name = Name,
            Tipo__c = Tipo,
            Categoria__c = Categoria,
            Base__c = Base,
            CapacidadeMaxima__c = CapacidadeMaxima,
            CodigoLocal__c = CodigoLocal,
            CodigoICAO__c = CodigoICAO,
            Cliente__c = Cliente,
            Status__c = Status,
            Tamanho__c = Tamanho,
            Abastecimento__c = Abastecimento,
            CoordenadasLatitudeGraus__c = CoordenadasLatitudeGraus,
            CoordenadasLatitudeMinutos__c = CoordenadasLatitudeMinutos,
            CoordenadasLatitudeSegundos__c = CoordenadasLatitudeSegundos,
            CoordenadasLatitudeDirecao__c = CoordenadasLatitudeDirecao,
            CoordenadasLongitudeGraus__c = CoordenadasLongitudeGraus,
            CoordenadasLongitudeMinutos__c = CoordenadasLongitudeMinutos,
            CoordenadasLongitudeSegundos__c = CoordenadasLongitudeSegundos,
            CoordenadasLongitudeDirecao__c = CoordenadasLongitudeDirecao
        );
        return local;
    }

    public static Voo__c createVooRascunho(
        Datetime DataVoo,
        Id Prefixo,
        Id Cliente
    ) {
        Voo__c rascunho = new Voo__c(
            DataVoo__c = DataVoo,
            Prefixo__c = Prefixo,
            Cliente__c = Cliente,
            Status__c = 'Rascunho'
        );
        return rascunho;
    }

    public static Trecho__c createTrecho(
        Id Voo,
        Id Origem,
        Id Destino,
        Double OrdemExecucao
    ) {
        Trecho__c trecho = new Trecho__c(
            Voo__c = Voo,
            Origem__c = Origem,
            Destino__c = Destino,
            OrdemExecucao__c = OrdemExecucao
        );

        return trecho;
    }

    public static List<Aeronave__c> create3Aeronaves(Product2 produto) {
        List<Aeronave__c> aeronaves = new List<Aeronave__c>();
        Aeronave__c a1 = createAeronave('PR-OHD', produto);
        aeronaves.add(a1);
        Aeronave__c a2 = createAeronave('PR-OHL', produto);
        aeronaves.add(a2);
        Aeronave__c a3 = createAeronave('PR-OHN', produto);
        aeronaves.add(a3);
        return aeronaves;
    }

    public static List<Local__c> create3Locais() {
        List<Local__c> locais = new List<Local__c>();
        locais.add(
            createLocal(
                'Aeroporto de Macaé',
                'Onshore',
                'Base',
                true,
                null,
                'SBME',
                'sbrj',
                null,
                'Validado',
                null,
                null,
                22,
                20,
                41,
                'S',
                41,
                46,
                7,
                'O'
            )
        );
        locais.add(
            createLocal(
                'Aeroporto de Jacarepaguá',
                'Onshore',
                'Base',
                true,
                null,
                'SBJR',
                'sbrj',
                null,
                'Validado',
                900,
                null,
                22,
                59,
                16,
                'S',
                43,
                22,
                13,
                'O'
            )
        );
        locais.add(
            createLocal(
                'Aeroporto Santos Dumont',
                'Onshore',
                'Base',
                false,
                9,
                'SBRJ',
                'sbrj',
                null,
                'Validado',
                null,
                null,
                22,
                54,
                35,
                'S',
                43,
                9,
                44,
                'O'
            )
        );
        return locais;
    }

    public static List<Trecho__c> criarTrajeto(
        Id Voo,
        Id localA,
        Id localb,
        Double DisponibilidadePeso
    ) {
        List<Trecho__c> trajeto = new List<Trecho__c>();
        trajeto.add(TestUtil.createTrecho(Voo, localA, localb, 10));
        trajeto.add(TestUtil.createTrecho(Voo, localb, localA, 20));
        return trajeto;
    }

    public static void CreateVooReservado(Datetime dataVoo) {
        insereConfiguracoesPersonalizadas();

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        // Conta
        Account Cliente = TestUtil.createAccount('Voe Omni');
        uow.registerNew(Cliente);
        // Contato
        Id recordTypeIdContact; 
        Map<String,Schema.RecordTypeInfo> recordTypeMapByName = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        if(recordTypeMapByName.get('Passageiro') != null){
            recordTypeIdContact = recordTypeMapByName.get('Passageiro').getRecordTypeId();
        } else{
            recordTypeIdContact = recordTypeMapByName.get('Passenger').getRecordTypeId();
        }
            
        Contact Contato = TestUtil.createContact(Cliente, 'Martins');
        Contato.Email = 'fernandorrmartins@gmail.com';
        Contato.RecordTypeId = recordTypeIdContact;
        uow.registerNew(Contato);
        uow.registerRelationship(Contato, Contact.AccountId, Cliente);
        // Modelo de Aeronave
        Product2 p = TestUtil.createProduct();
        uow.registerNew(p);
        /* 3 Locais
         * Indexs:
         * [0] Aeroporto de Macaé
         * [1] Aeroporto de Jacarepaguá
         * [2] Aeroporto Santos Dumont
         */
        List<Local__c> locais = TestUtil.create3Locais();
        uow.registerNew(locais);
        /* 3 Aeronaves
         * Indexs:
         * [0] PR-OHD
         * [1] PR-OHL
         * [2] PR-OHN
         */
        List<Aeronave__c> Aeronaves = TestUtil.create3Aeronaves(p);
        for (Aeronave__c a : Aeronaves) {
            uow.registerNew(a);
            uow.registerRelationship(a, Aeronave__c.ModeloAeronave__c, p);
            uow.registerRelationship(a, Aeronave__c.BaseMae__c, locais[0]);
        }
        // Voo
        Voo__c voo = TestUtil.createVooRascunho(
            dataVoo,
            Aeronaves[0].Id,
            Cliente.Id
        );
        uow.registerNew(voo);
        uow.registerRelationship(voo, Voo__c.Prefixo__c, Aeronaves[0]);
        uow.registerRelationship(voo, Voo__c.Cliente__c, Cliente);
        // Trecho
        Trecho__c t1 = TestUtil.createTrecho(
            voo.Id,
            locais[0].Id,
            locais[1].Id,
            10
        );
        uow.registerNew(t1);
        uow.registerRelationship(t1, Trecho__c.Voo__c, voo);
        uow.registerRelationship(t1, Trecho__c.Origem__c, locais[0]);
        uow.registerRelationship(t1, Trecho__c.Destino__c, locais[1]);
        Trecho__c t2 = TestUtil.createTrecho(
            voo.Id,
            locais[1].Id,
            locais[0].Id,
            20
        );
        uow.registerNew(t2);
        uow.registerRelationship(t2, Trecho__c.Voo__c, voo);
        uow.registerRelationship(t2, Trecho__c.Origem__c, locais[1]);
        uow.registerRelationship(t2, Trecho__c.Destino__c, locais[0]);
        uow.commitWork();

        voo.Status__c = 'Reservado';
        //update voo;
    }
    static Integer s_num = 1;

    public static String getFakeId(Schema.SObjectType sot) {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() +
            '0'.repeat(12 - result.length()) +
            result;
    }

    public static String getRandomCoordenadas() {
        Decimal lat = getRandomLatitude();
        Decimal lon = getRandomLongitude();
        return String.valueOf(lat) + ',' + String.valueOf(lon);
    }

    public static Decimal getRandomLatitude() {
        return Decimal.valueOf(Math.random() * 180 - 90).setScale(6);
    }
    public static Decimal getRandomLongitude() {
        return Decimal.valueOf(Math.random() * 360 - 180).setScale(6);
    }
}