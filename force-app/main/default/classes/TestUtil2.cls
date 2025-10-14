@isTest
public class TestUtil2 {

    public static void insereConfiguracoesPersonalizadas()
    {
        insert new ConfiguracoesTelaCustomizada__c(
            NumeroRotasRecentes__c = 10,
            DescontoMinimo__c = 10,
            DiferencaPesoDisponivel__c = 0
        );
        insert new ConfiguracoesPrecos__c(
            ValorAdicionalVooSanitario__c = 1000
        );
        insert new ConfiguracaoTempo__c(
            TempoMinutos__c = 10,
            QtdDiasEnvioNovaPesquisaSatisfacao__c = 3,
            TempoPlanejamentoPos__c = 40,
            TempoPlanejamentoPre__c = 40,
            EntreVoosRetroativo__c = 15,
            HoraFimSelecaoHorarioVoo__c = 12,
            HoraInicioSelecaoHorarioVoo__c = 8,
            MinutoFimSelecaoHorarioVoo__c = 00,
            MinutoInicioSelecaoHorarioVoo__c = 00,
            IntervaloMinutosSelecaoAeronaves__c = 30,
            TempoIntegracaoSkytrac__c = 15,
            DiasParaExpirarPesquisaPassageiro__c = 2,
            MinutosBloqueioReservarVoo__c = 0,
            MinutosBloqueioSelecaoVoo__c = 0,
            QtdDiasEnvioPesquisaSatisfacaoContrato__c = 15
        );
        insert new ConfiguracoesIntegracaoSkyTrac__c(
            Ligado__c = 177,
            CodigoVoo__c = 211,
            Cut__c = 178,
            Decolagem__c = 217,
            FimMissao__c = 179,
            Pouso__c = 216,
            RaioConsiderado__c = 2
        );
        
        Organization o = [Select isSandbox From Organization LIMIT 1];
        insert new ConfiguracoesGerais__c(
            IdPerfilComunidade__c = (o.isSandbox ? '00e3F000000HKVyQAO' : '00e3i000000uH06'),
            IdTemplateEmailPesquisaPassageiro__c = (o.isSandbox ? '00X3F000001MsxaUAC' : '00X3i000000hLVr'),
            IdRemetentePesquisaSatisfacao__c = (o.isSandbox ? '0D23i000000L02wCAC' : '0D23i000000L02wCAC'),
            IdTemplatePesquisaContratante__c = (o.isSandbox ? '00X88000001zrMzEAI' : '00X3i000000hLVm'),
            IdTipoRegistroContratante__c = (o.isSandbox ? '0123F000000tGYlQAM' : '0123i000000MaKPAA0'),
            IdTipoRegistroLocalPadrao__c = Schema.SObjectType.Local__c.getRecordTypeInfosByDeveloperName().get('Padrao').getRecordTypeId(),
            IdItemContratoTipoAeronave__c = Schema.SObjectType.ItemContrato__c.getRecordTypeInfosByDeveloperName().get('Aeronave').getRecordTypeId(),
            IdItemContratoTipoProduto__c = Schema.SObjectType.ItemContrato__c.getRecordTypeInfosByDeveloperName().get('Produto').getRecordTypeId(),
            IdGrupoOperacoesMacae__c = (o.isSandbox ? '00G3i000000ed32EAA' : '00G3i000000ed32EAA'),
            IdGrupoCoordenacaoMacae__c = (o.isSandbox ? '00G3i000000ed2wEAA' : '00G3i000000ed2wEAA'),
            IdNotificacaoPersonalizada__c = (o.isSandbox ? '0ML3i000000KzBtGAK' : '0ML3i000000KzBtGAK'),
            DeveloperNamePesquisaPassageiro__c = (o.isSandbox ? 'pesquisa_voe_omni' : 'pesquisa_voe_omni_passageiro'),
            IdComunidade__c = '0DB3i000000PCvFGAW',
            IdPesquisaPassageiro__c = '0Kd3i000000983KCAQ',
            DeveloperNamePesquisaContratante__c = (o.isSandbox ? 'pesquisa_cliente_omni' : 'voe_omni_pesquisa_de_satisfa_o'),
            IdPesquisaContratante__c = (o.isSandbox ? '0Kd3i000000983PCAQ' : '0Kd3i000000983PCAQ')
        );
    }
    
    public static List<IntervaloSol__c> criarIntervaloSol(fflib_ISObjectUnitOfWork uow, Set<String> ICAOCodes, Integer quantidadeDias)
    {
        List<IntervaloSol__c> intervalos = new List<IntervaloSol__c>();
        for(Integer i=0;i<quantidadeDias;i++)
        {
            for(String ICAOCode : ICAOCodes)
            {
                IntervaloSol__c intervalo = new IntervaloSol__c();
                intervalo.Aero__c = ICAOCode;
                intervalo.CodigoICAO__c = intervalo.Aero__c;
                intervalo.Date__c = System.now().addDays(i).date();
                intervalo.Sunrise__c = Time.newInstance(6, 0, 0, 0);
                intervalo.Sunset__c = Time.newInstance(19, 0, 0, 0);
                intervalos.add(intervalo);
                
                if(i != 0) {
                    intervalo = new IntervaloSol__c();
                    intervalo.Aero__c = ICAOCode;
                    intervalo.CodigoICAO__c = intervalo.Aero__c;
                    intervalo.Date__c = System.now().addDays(-i).date();
                    intervalo.Sunrise__c = Time.newInstance(6, 0, 0, 0);
                    intervalo.Sunset__c = Time.newInstance(19, 0, 0, 0);
                    intervalos.add(intervalo);
                }
            }
        }
        uow.registerNew(intervalos);
        return intervalos;
    }
    
    public static Account createAccount(String nome, Boolean byPassValidationRules, fflib_ISObjectUnitOfWork uow) {
        Account acc = new Account(
            Name = nome,
            RazaoSocial__c = 'Company ' + nome,
            Type = 'Cliente',
            CNPJCPF__c =  GeraCpfCnpj.cnpj(true),
            Email__c = nome.replace(' ', '') + '@teste.com',
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
            InscricaoMunicipal__c = '65445555',
            EnderecoIgualEmpresa__c = 'Sim',
            ShippingState = 'MG',
            ShippingCountry = 'Brasil',
            ShippingStreet = 'Rua Lourival Campos Réis',
            ShippingCity = 'Carmo da Cachoeira',
            ShippingPostalCode = '37225-000'
        );
        uow.registerNew(acc);
        return acc;
    }
    
    public static Contact createContact(Account conta, String nome,fflib_ISObjectUnitOfWork uow) {
        Contact contato = new Contact();
        contato.LastName = nome;
        contato.Nacionalidade__c = 'BR';
        contato.Email = nome.replace(' ', '') + '@email.com';
        contato.NumeroDocumento__c = GeraCpfCnpj.cpf(true);
        contato.TipoDocumento__c = 'CPF';
        contato.Reserva__c = true;
        contato.EmissaoEmbarque__c = true;
        contato.TakeoffReport__c = true;
        contato.ConclusaoTrecho__c = true;
        contato.ConclusaoVoo__c = true;
        contato.Faturamento__c = true;
        uow.registerRelationship(contato, Contact.AccountId, conta);
        uow.registerNew(contato);
        return contato;
    }
    
    public static Product2 createProduct(String name, String porte, fflib_ISObjectUnitOfWork uow)
    {
        Product2 prod = new Product2(Name=name,
                                     Porte__c=porte,
                                     CapacidadePassageiros__c=12,
                                     Autonomia__c=500,
                                     Alcance__c=2000,
                                     Velocidade__c=140,
                                     //PesoBasicoOperacional__c=4604,
                                     //PesoMaximoDecolagem__c=6800,
                                     //PesoMaximoRampa__c=6800,
                                     //PesoMaximoPouso__c=6800,
                                     IsActive=true);
        uow.registerNew(prod);
        return prod;
    }
    
    public static Aeronave__c createAeronave(String name, Product2 modeloAeronave, Local__c baseMae, fflib_ISObjectUnitOfWork uow)
    {
        Aeronave__c aeronave = new Aeronave__c(Name=name,
                                               unitName__c='OMNI_T200R0110072',
                                               PesoBasicoOperacional__c=3000,
                                               PesoMaximoDecolagem__c=10000,
                                               TipoOperacao__c='Spot',
                                               VelocidadeCruzeiro__c=140,
                                               ConsumoHoraSolo__c=360,
                                               ConsumoHoraVoo__c=410,
                                               LarguraBagageiro__c=1.5,
                                               AlturaBagageiro__c=1,
                                               ProfundidadeBagageiro__c=1.5,
                                               TipoCombustivel__c='QAV',
                                               Tamanho__c=50,
                                               CapacidadeTotalCombustivel__c=1670);
        uow.registerRelationship(aeronave, Aeronave__c.ModeloAeronave__c, modeloAeronave);
        uow.registerRelationship(aeronave, Aeronave__c.BaseMae__c, baseMae);
        uow.registerNew(aeronave);
        return aeronave;
    }
    
    public static Local__c createLocal(fflib_ISObjectUnitOfWork uow, String Name, String Tipo, String Categoria, Boolean Base, Double CapacidadeMaxima,
                                       String CodigoLocal, String CodigoICAO, Id Cliente, String Status, Double Tamanho, String Abastecimento,
                                       Double CoordenadasLatitudeGraus, Double CoordenadasLatitudeMinutos, Double CoordenadasLatitudeSegundos,
                                       String CoordenadasLatitudeDirecao, Double CoordenadasLongitudeGraus, Double CoordenadasLongitudeMinutos,
                                       Double CoordenadasLongitudeSegundos, String CoordenadasLongitudeDirecao, String municipio, String Cep, String IdExternoOOS)
    {
        Local__c local = new Local__c(
            Name=Name,
            Tipo__c=Tipo,
            Categoria__c=Categoria,
            Base__c=Base,
            CapacidadeMaxima__c=CapacidadeMaxima,
            CodigoLocal__c=CodigoLocal,
            CodigoICAO__c=CodigoICAO,
            Cliente__c=Cliente,
            Status__c=Status,
            Tamanho__c=Tamanho,
            Abastecimento__c=Abastecimento,
            CoordenadasLatitudeGraus__c=CoordenadasLatitudeGraus,
            CoordenadasLatitudeMinutos__c=CoordenadasLatitudeMinutos,
            CoordenadasLatitudeSegundos__c=CoordenadasLatitudeSegundos,
            CoordenadasLatitudeDirecao__c=CoordenadasLatitudeDirecao,
            CoordenadasLongitudeGraus__c=CoordenadasLongitudeGraus,
            CoordenadasLongitudeMinutos__c=CoordenadasLongitudeMinutos,
            CoordenadasLongitudeSegundos__c=CoordenadasLongitudeSegundos,
            CoordenadasLongitudeDirecao__c=CoordenadasLongitudeDirecao

       );
        uow.registerNew(local);
        return local;
    }
    
    
    public static Local__c createLocal(fflib_ISObjectUnitOfWork uow, String Name, String Tipo, String Categoria, Boolean Base, Double CapacidadeMaxima,
                                       String CodigoLocal, String CodigoICAO, Id Cliente, String Status, Double Tamanho, String Abastecimento,
                                       Double CoordenadasLatitudeGraus, Double CoordenadasLatitudeMinutos, Double CoordenadasLatitudeSegundos,
                                       String CoordenadasLatitudeDirecao, Double CoordenadasLongitudeGraus, Double CoordenadasLongitudeMinutos,
                                       Double CoordenadasLongitudeSegundos, String CoordenadasLongitudeDirecao, String municipio, String Cep)
    {
        Local__c local = new Local__c(
            Name=Name,
            Tipo__c=Tipo,
            Categoria__c=Categoria,
            Base__c=Base,
            CapacidadeMaxima__c=CapacidadeMaxima,
            CodigoLocal__c=CodigoLocal,
            CodigoICAO__c=CodigoICAO,
            Cliente__c=Cliente,
            Status__c=Status,
            Tamanho__c=Tamanho,
            Abastecimento__c=Abastecimento,
            CoordenadasLatitudeGraus__c=CoordenadasLatitudeGraus,
            CoordenadasLatitudeMinutos__c=CoordenadasLatitudeMinutos,
            CoordenadasLatitudeSegundos__c=CoordenadasLatitudeSegundos,
            CoordenadasLatitudeDirecao__c=CoordenadasLatitudeDirecao,
            CoordenadasLongitudeGraus__c=CoordenadasLongitudeGraus,
            CoordenadasLongitudeMinutos__c=CoordenadasLongitudeMinutos,
            CoordenadasLongitudeSegundos__c=CoordenadasLongitudeSegundos,
            CoordenadasLongitudeDirecao__c=CoordenadasLongitudeDirecao
       );
        uow.registerNew(local);
        return local;
    }
    
    public static Local__c createLocal(fflib_ISObjectUnitOfWork uow, String Name, String Tipo, String Categoria, Boolean Base, Double CapacidadeMaxima,
                                       String CodigoLocal, String CodigoICAO, Id Cliente, String Status, Double Tamanho, String Abastecimento,
                                       Double CoordenadasLatitudeGraus, Double CoordenadasLatitudeMinutos, Double CoordenadasLatitudeSegundos,
                                       String CoordenadasLatitudeDirecao, Double CoordenadasLongitudeGraus, Double CoordenadasLongitudeMinutos,
                                       Double CoordenadasLongitudeSegundos, String CoordenadasLongitudeDirecao)
    {
        Local__c local = new Local__c(
            Name=Name,
            Tipo__c=Tipo,
            Categoria__c=Categoria,
            Base__c=Base,
            CapacidadeMaxima__c=CapacidadeMaxima,
            CodigoLocal__c=CodigoLocal,
            CodigoICAO__c=CodigoICAO,
            Cliente__c=Cliente,
            Status__c=Status,
            Tamanho__c=Tamanho,
            Abastecimento__c=Abastecimento,
            CoordenadasLatitudeGraus__c=CoordenadasLatitudeGraus,
            CoordenadasLatitudeMinutos__c=CoordenadasLatitudeMinutos,
            CoordenadasLatitudeSegundos__c=CoordenadasLatitudeSegundos,
            CoordenadasLatitudeDirecao__c=CoordenadasLatitudeDirecao,
            CoordenadasLongitudeGraus__c=CoordenadasLongitudeGraus,
            CoordenadasLongitudeMinutos__c=CoordenadasLongitudeMinutos,
            CoordenadasLongitudeSegundos__c=CoordenadasLongitudeSegundos,
            CoordenadasLongitudeDirecao__c=CoordenadasLongitudeDirecao
        );
        uow.registerNew(local);
        return local;
    }
    
    public static List<Local__c> criarOrigemDestino(fflib_ISObjectUnitOfWork uow) {
        List<Local__c> locais = new List<Local__c>();
        locais.add(createLocal(uow, 'Aeroporto de Macaé', 'Onshore', 'Base', true, null, 'SBMETeste', 'sbrj', null, 'Validado', null, 'QAV',
                               22, 20, 41, 'S', 41, 46, 7, 'O', 'Rio de Janeiro', '20000-000'));
        locais.add(createLocal(uow, 'Aeroporto de Jacarepaguá', 'Onshore', 'Base', true, null, 'SBJRTeste', 'sbrj', null, 'Validado', 900, null,
                               22, 59, 16, 'S', 43, 22, 13, 'O', 'Campos dos Goytacazes', '28010-970'));
        return locais;
    }
    
    public static List<Local__c> criarOrigemDestinoGuiana(fflib_ISObjectUnitOfWork uow) {
        List<Local__c> locais = new List<Local__c>();
        locais.add(createLocal(uow, 'Aeroporto Internacional Eugene F Correia', 'Onshore', 'Base', true, null, 'SYEC', 'SBJR', null, 'Validado', null, 'QAV',
                               6, 48, 21, 'N', 58, 6, 27, 'O', 'Rio de Janeiro', '20000-000'));
        locais.add(createLocal(uow, 'Island Performer', 'Offshore', 'null', false, null, 'ISPE', 'SBJR', null, 'Validado', null, null,
                                8, 12, 13, 'N', 56, 56, 16, 'O', null, null));
        return locais;
    }
    
    public static Aerovia__c criarAerovia(Local__c origem, Local__c destino, String tipo, fflib_ISObjectUnitOfWork uow) {
        Aerovia__c aerovia = new Aerovia__c(
        	Tipo__c = tipo
        );
        uow.registerRelationship(aerovia, Aerovia__c.Destino__c, destino);
        uow.registerNew(aerovia, Aerovia__c.Origem__c, origem);
        return aerovia;
    }
    
    public static Voo__c createVooRascunho(Datetime DataVoo, Aeronave__c prefixo, Account cliente, fflib_ISOBjectUnitOfWork uow) {
        Voo__c rascunho = new Voo__c(
            DataVoo__c=DataVoo,
            Status__c='Rascunho'
        );
        uow.registerRelationship(rascunho, Voo__c.Prefixo__c, prefixo);
        uow.registerRelationship(rascunho, Voo__c.Cliente__c, cliente);
        uow.registerNew(rascunho);
        return rascunho;
    }
    
    public static Trecho__c createTrecho(Voo__c voo, Local__c origem, Local__c destino, Double OrdemExecucao, fflib_ISObjectUnitOfWork uow) {
        Trecho__c trecho = new Trecho__c(
            OrdemExecucao__c=OrdemExecucao
        );
        uow.registerRelationship(trecho, Trecho__c.Origem__c, origem);
        uow.registerRelationship(trecho, Trecho__c.Destino__c, destino);
        uow.registerNew(trecho, Trecho__c.Voo__c, voo);
        return trecho;
    }
    
    public static List<Trecho__c> criarIdaVolta(Voo__c voo, Local__c origem, Local__c destino, fflib_ISObjectUnitOfWork uow) {
        List<Trecho__c> trechos = new List<Trecho__c>();
        trechos.add(createTrecho(voo, origem, destino, 10, uow));
        trechos.add(createTrecho(voo, destino, origem, 20, uow));
        return trechos;
    }
    
    public static Pricebook2 criarPricebook(Date dt, fflib_ISObjectUnitOfWork uow) {
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Pricebook O';
        pb.IsActive = true;
        uow.registerNew(pb);
        return pb;
    }
    
    public static List<PricebookEntry> criarPBEs(List<Product2> produtos, Pricebook2 pricebook, fflib_ISObjectUnitOfWork uow) {
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        for(Product2 prod : produtos)
        {
            PriceBookEntry pbe = new PriceBookEntry();
            pbe.UnitPrice = 1000;
            pbe.IsActive = true;
            uow.registerRelationship(pbe, PricebookEntry.Pricebook2Id, pricebook);
            uow.registerRelationship(pbe, PricebookEntry.Product2Id, prod);           
            pbes.add(pbe);
        }
        uow.registerNew(pbes);
        return pbes;
    }
    
    public static Voo__c criarVooRascunho(Datetime dataVoo, Boolean insereConf, fflib_ISObjectUnitOfWork uow) {
        if(insereConf)
        {
            insereConfiguracoesPersonalizadas();
        }
        Account cliente = createAccount('Voe Omni', true, uow);
        Product2 prod = createProduct('AW139', 'Médio', uow);
        List<Local__c> locais = criarOrigemDestino(uow);
        List<IntervaloSol__c> intervalos = criarIntervaloSol(uow, Utils.getSetOfField((List<SObject>) locais, 'CodigoICAO__c'), 15);
        Aerovia__c aerovia = criarAerovia(locais[0], locais[1], 'Bidirecional', uow);
        Aeronave__c aeronave2 = createAeronave('PR-CHQ', prod, locais[0], uow);
        Aeronave__c aeronave = createAeronave('PR-OHD', prod, locais[0], uow);
        Voo__c voo = createVooRascunho(dataVoo, aeronave, cliente, uow);
        List<Trecho__c> trechos = criarIdaVolta(voo, locais[0], locais[1], uow);
        return voo;
    }
    
    public static List<Voo__c> criar2VooRascunho(Datetime dataVoo, Boolean insereConf, fflib_ISObjectUnitOfWork uow) {
        if(insereConf)
        {
            insereConfiguracoesPersonalizadas();
        }
        Account cliente = createAccount('Voe Omni', true, uow);
        Product2 prod = createProduct('AW139', 'Médio', uow);
        List<Local__c> locais = criarOrigemDestino(uow);
        List<IntervaloSol__c> intervalos = criarIntervaloSol(uow, Utils.getSetOfField((List<SObject>) locais, 'CodigoICAO__c'), 15);
        Aerovia__c aerovia = criarAerovia(locais[0], locais[1], 'Bidirecional', uow);
        Aeronave__c aeronave = createAeronave('PR-OHD', prod, locais[0], uow);
        Voo__c voo = createVooRascunho(dataVoo, aeronave, cliente, uow);
        Voo__c voo2 = createVooRascunho(dataVoo+1, aeronave, cliente, uow);
        List<Trecho__c> trechos = criarIdaVolta(voo, locais[0], locais[1], uow);
        List<Trecho__c> trechos2 = criarIdaVolta(voo2, locais[0], locais[1], uow);

        return new List<Voo__c>{voo,voo2};
    }
    
    public static void criarPlanejamentoVoo(){
                
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil.carregaLocais(2);
        locais[0].Abastecimento__c = 'QAV';
        locais[1].Abastecimento__c = 'QAV';
        locais[0].Coordenadas__Latitude__s = -22.918055555556;
        locais[1].Coordenadas__Latitude__s = -21.918055555556;
        locais[0].Coordenadas__Longitude__s = -43.828888888889;
        locais[1].Coordenadas__Longitude__s = -42.828888888889;
        locais[0].CategoriaDecolagem__c = 'RWY';
        locais[1].CategoriaDecolagem__c = 'HDK';
        locais[0].CodigoIcao__c = 'SBJR';
        locais[1].CodigoIcao__c = 'SBJR';
        uow.registerNew(locais);
       
        
        List<Product2> modelos = new List<Product2>{TestUtil.createProduct('Modelo'), TestUtil.createProduct('Modelo2')};
        insert modelos;
        List<Calendar> calendars = [SELECT Id, Name FROM Calendar WHERE Name like'PR%' LIMIT :modelos.size()];
        for(Integer i = 1; i < calendars.size(); i++)
        {
           Aeronave__c aeronave = TestUtil.carregaAeronave(calendars[i].Name);
           aeronave.TipoCombustivel__c = 'QAV';
           uow.registerRelationship(aeronave, Aeronave__c.BaseMae__c, locais[0]);
           uow.registerNew(aeronave, Aeronave__c.ModeloAeronave__c, modelos[0]);
           
        } 
        
        Id standardPricebookId = TestUtil.SetupStandardPricebook();

        criarPBEs(modelos, new Pricebook2(Id = standardPricebookId), uow);
        uow.commitWork();
        User usuario = new User(id = UserInfo.getUserId());
        update usuario;
        List<Aeronave__c> aeronaves = [SELECT Id, Prefixo__c FROM Aeronave__c];       
        for (Aeronave__c aeronave : aeronaves) {
            aeronave.VelocidadeCruzeiro__c = 10;
            aeronave.ConsumoHoraSolo__c = 10;
            aeronave.ConsumoHoraVoo__c = 10;
            aeronave.PesoBasicoOperacional__c = 2000;
            aeronave.PesoMaximoDecolagem__c = 4000;
            aeronave.CapacidadeTotalCombustivel__c = 400;
        }                
        update aeronaves;

        Aeronave__c aeronave = [SELECT Id, ModeloAeronave__c FROM Aeronave__c LIMIT 1];
    
        Perfomance__c performanceHDK = new Perfomance__c();
        performanceHDK.Name = 'performance 1';
        performanceHDK.ModeloAeronave__c = aeronave.ModeloAeronave__c;
        performanceHDK.categoriaDecolagem__c = 'HDK';
        performanceHDK.Ativo__c = true;
        insert performanceHDK;
    
        ItemPerfomance__c itemHDK = new ItemPerfomance__c();
        itemHDK.Perfomance__c = performanceHDK.Id;
        itemHDK.TemperaturaDe__c = -5000;
        itemHDK.TemperaturaAte__c = 5000;
        itemHDK.VelocidadeVentoDe__c = -5000;
        itemHDK.VelocidadeventoAte__c = 5000;
        itemHDK.AltitudeDe__c = -5000;
        itemHDK.AltitudeAte__c = 5000;
        insert itemHDK;
    
        Perfomance__c performanceRWY = new Perfomance__c();
        performanceRWY.Name = 'performance RWY';
        performanceRWY.ModeloAeronave__c = aeronave.ModeloAeronave__c;
        performanceRWY.categoriaDecolagem__c = 'RWY';
        performanceRWY.Ativo__c = true;
        insert performanceRWY;
    
        ItemPerfomance__c itemRWY = new ItemPerfomance__c();
        itemRWY.Perfomance__c = performanceRWY.Id;
        itemRWY.TemperaturaDe__c = -5000;
        itemRWY.TemperaturaAte__c = 5000;
        itemRWY.VelocidadeVentoDe__c = -5000;
        itemRWY.VelocidadeventoAte__c = 5000;
        itemRWY.AltitudeDe__c = -5000;
        itemRWY.AltitudeAte__c = 5000;
        insert itemRWY;
    
        Datetime data = Datetime.newInstanceGmt(System.now().date().addDays(1), Time.newInstance(15, 0, 0, 0));
        uow = Application.UnitOfWork.newInstance();
        locais = [SELECT ID, recordType.DeveloperName, Coordenadas__Latitude__s, Coordenadas__Longitude__s FROM local__c];
    
        Funcionario__c piloto = new Funcionario__c(Name='teste', Apelido__c='teste',Matricula__c = '123', idExternoSigTrip__c = 123, Cargo__c = '22', Email__c = 'teste@teste.com');
        insert piloto;
        
        Funcionario__c copiloto = new Funcionario__c(Name='copiloto', Apelido__c='copiloto',Matricula__c = '1233', idExternoSigTrip__c = 1233, Cargo__c = '	454', Email__c = 'teste2@teste.com');
        insert copiloto;
            
        Account acct = new Account();
        acct.Name = 'MODEC - MATRIZ';
        acct.RazaoSocial__c ='MODEC Serviços de Petróleo do Brasil Ltda';
        acct.CNPJCPF__c='05.217.376/0001-76';
        acct.InscricaoEstadual__c='11601006';
        acct.InscricaoMunicipal__c='0000';
        acct.Mercado__c='Nacional';
        acct.ShippingCity = 'Rio de Janeiro'; 
        acct.ShippingStreet = 'Avenida José Silva de Azevedo Neto';
        acct.ShippingState = 'RJ'; 
        acct.ShippingPostalCode = '27932-050';        
        acct.ShippingCountry = 'Brasil';                         
        insert acct;
      
                  
        IntervaloSol__c sol = new IntervaloSol__c();
        sol.CodigoICAO__c = 'SBJR';
        sol.Sunrise__c = Time.newInstance(6, 0, 0, 0);
        sol.Sunset__c = Time.newInstance(18, 0, 0, 0);
        insert sol;
            
        Contract contrato = new Contract();
        contrato.AccountId = acct.Id;
        contrato.StartDate = Date.today().addYears(-10);
        contrato.EndDate = Date.today().addYears(10);
        insert contrato;
    
        Time tempo = Time.newInstance(0, 15, 0, 0);
        ItemContrato__c item = new ItemContrato__c();
        item.Contrato__c = contrato.Id;
        item.Aeronave__c = aeronave.Id;
        item.ValorHora__c = 1000;
        item.TempoAjustePadrao__c = tempo;
        item.TempoReservaPadrao__c = tempo;
        insert item;   
    }
}