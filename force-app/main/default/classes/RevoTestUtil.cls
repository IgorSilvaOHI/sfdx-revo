@IsTest
public class RevoTestUtil {

    private static Id recordTypeModelo = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Modelo').getRecordTypeId();
    private static Id recordTypeShuttleSeat = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ShuttleSeat').getRecordTypeId();
    private static Id recordTypeFullCabin = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('FullCabin').getRecordTypeId();
    private static Id recordTypeServicosTaxas = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ServicosTaxas').getRecordTypeId();
    private static Id recordTypeCharterFlight = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CharterFlight').getRecordTypeId();
    private static Id recordCodigoPromocional = Schema.SObjectType.CodigoPromocional__c.getRecordTypeInfosByDeveloperName().get('CodigoPromocional').getRecordTypeId();
    
    private static Id recordTypeClientePF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ClientePF').getRecordTypeId();
    private static Id crecordTypeContactPassanger = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Passageiro').getRecordTypeId();

    public static void setupSiteUser(String idSite){
        Lead lead = createLead();
        insert lead;

        UsuarioSite__c usuarioSite = createUsuarioSite(idSite);
        usuarioSite.Lead__c = lead.Id;
        insert usuarioSite;
    }

    public static void ConfigurarProdutosEServicos(){
        TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        //COMPANY ACCOUNT
        Account revoAccount = TestFactory.createBusinessAccount('REVO');
        Account customerAccount = TestFactory.createPersonAccount('Caio', 'Bernardi');

        uow.registerNew(new List<Account>{revoAccount, customerAccount});

        Contact contact = TestUtil.createContactPassageiro(null, 'Caio Bernardi');
        uow.registerNew(new List<Contact>{contact});

        //CRIA CODIGO PROMOCIONAL

        criarCodigoPromocional(uow, 'PROMO10');

        //CONFIGURA AERONAVES
        Product2 modelo1 = createModelo('H-135');
        Product2 modelo2 = createModelo('H-155');
        uow.registerNew(new List<Product2>{modelo1, modelo2});
        
        Local__c baseMae = createLocalBase('Carapicuíba: Helipark', 'FP001');   
        uow.registerNew(baseMae);

        Aeronave__c aeronave1 = TestUtil.CreateAeronave('PR-OMH', modelo1);
        Aeronave__c aeronave2 = TestUtil.CreateAeronave('PR-OOE', modelo2);

        uow.registerRelationship(aeronave1, Aeronave__c.ModeloAeronave__c, modelo1);
        uow.registerRelationship(aeronave2, Aeronave__c.ModeloAeronave__c, modelo2);
        uow.registerRelationship(aeronave1, Aeronave__c.BaseMae__c, baseMae);
        uow.registerRelationship(aeronave2, Aeronave__c.BaseMae__c, baseMae);

        uow.registerNew(new List<Aeronave__c>{aeronave1, aeronave2});

        Local__c localOrigem = createLocal('Aeroporto Internacional de São Paulo - Guarulhos', 'SBGR');
        Local__c localDestino = createLocal('São Paulo - Vl. Olímpia: Condomínio Edifício Paladio', 'SDOF');
        
        uow.registerNew(new List<Local__c>{localOrigem, localDestino});

        //INSERE SERVIÇOS
        List<Product2> servicos = parametrizarServicos(uow);

        //PARAMETRIZAR TIPO DE PRODUTOS
        parametrizarShuttleSeat(uow, revoAccount, localOrigem, localDestino, servicos, new List<Aeronave__c>{aeronave1, aeronave2});
        parametrizarFullCabin(uow, revoAccount, localOrigem, localDestino, servicos, new List<Aeronave__c>{aeronave1, aeronave2});
        parametrizarCharter(uow, revoAccount, servicos, new List<Aeronave__c>{aeronave1, aeronave2});

        uow.commitWork();
    }

    public static void ConfigurarOportunidadeShuttleSeat(){
        RevoTestUtil.ConfigurarProdutosEServicos();

        Account customerAccount = [SELECT Id, Name FROM Account WHERE RecordTypeId = :recordTypeClientePF LIMIT 1];
        Contact customerContact = [SELECT Id, FirstName, LastName FROM Contact WHERE RecordTypeId = :crecordTypeContactPassanger LIMIT 1];
        Product2 shuttleSeatProduct = [SELECT Id, Name, LocalOrigem__c, LocalDestino__c, RecordTypeId FROM Product2 WHERE RecordTypeId = :recordTypeShuttleSeat LIMIT 1];
        List<ConfiguracaoPacote__c> servicos = [SELECT Id, Empacotado__c, Obrigatorio__c, Posicao__c, ProdutoPacote__r.Id, ProdutoPacote__r.Name,
                                                ProdutoPacote__c, ProdutoPai__c, QuantidadePadrao__c, QuantidadeRelativa__c, Selecionado__c
                                                FROM ConfiguracaoPacote__c WHERE ProdutoPai__c = :shuttleSeatProduct.Id];
        
        List<Product2> servicosProduct = new List<Product2>();
        
        for(ConfiguracaoPacote__c servico : servicos){
            servicosProduct.add(servico.ProdutoPacote__r);
        }

        CodigoPromocional__c codigoPromocional = [SELECT Id, Name FROM CodigoPromocional__c WHERE Ativo__c = true LIMIT 1];

        RevoTestUtil.criarOportunidade(customerAccount, customerContact, codigoPromocional, shuttleSeatProduct, servicosProduct);
    }

    public static void criarOportunidade(Account customerAccount, Contact customerContact, CodigoPromocional__c codigoPromocional, Product2 product, List<Product2> services){

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        OpportunityLineItem line;
        Opportunity oportunidade = Opportunities.criaOportunidade(uow, customerAccount.Id,customerAccount.Id, customerAccount.Name, '', codigoPromocional?.Id, TextUtils.generateBookingCode(6), 'Salesforce');
        oportunidade.ValidadeUltimoCalculo__c = System.now().addDays(1);
        
        if(product.RecordTypeId == recordTypeShuttleSeat){
            oportunidade.Type = 'ShuttleSeat';
            MalhaVoo__c malhaVoo = [SELECT Id, Origem__c, Destino__c, SegundaFeira__c, (SELECT Aeronave__r.ModeloAeronave__c FROM PrioridadesMalha__r)  FROM MalhaVoo__c WHERE Produto__c = :product.Id LIMIT 1];
            Id modeloId = malhaVoo.PrioridadesMalha__r[0].Aeronave__r.ModeloAeronave__c;
            line = Opportunities.criaLinhaShuttleSeat(uow, product.Id, modeloId, 120, 1, false, System.now().addDays(1), 1000, 0, oportunidade, product.LocalOrigem__c, product.LocalDestino__c, malhaVoo.Id, 1000, 0, 0, 0);
            
            String horaVoo = malhaVoo.SegundaFeira__c.split(';')[3];
            line.PrevisaoEmbarque__c  = DateTime.newInstance(System.today().addDays(1), Time.newInstance(Integer.valueOf(horaVoo.split(':')[0]), 
            Integer.valueOf(horaVoo.split(':')[1]), 0, 0));
        }else if(product.RecordTypeId == recordTypeFullCabin){
            oportunidade.Type = 'FullCabin';
        }else if(product.RecordTypeId == recordTypeCharterFlight){
            oportunidade.Type = 'Charter';
        }

        List<LocalOportunidade__c> locais = Opportunities.criaLocaisOrigemDestino(uow, oportunidade, line, product.LocalOrigem__c, product.LocalDestino__c);

        PassageiroOportunidade__c passageiroOportunidade = Opportunities.criaPassageiroOportunidade(uow, oportunidade, customerContact);

        Opportunities.criaProdutoDoPassageiro(
                uow, passageiroOportunidade, line, '','', 
                '', '', '', '', 0, 0, 0, 'Configurado', '1234', '1234');

        uow.commitWork();
        
        fflib_ISObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();

        for(Product2 service : services){
            OpportunityLineItem serviceLine = Opportunities.criaLinhaServico(uow1, oportunidade, line, service.Id, 1, false,
            true, false, false, System.now().addDays(1), 100, 0, 100, 0, 0,0);

            Opportunities.criaProdutoDoPassageiro(
                uow1, passageiroOportunidade, serviceLine, '','', 
                '', '', '', '', 0, 0, 0, 'Configurado', '1234', '1234');
        }

        uow1.commitWork();
    }

    private static Lead createLead(){
        Lead lead = new Lead();
        lead.Email = 'ws-user-exists-001@revosite.com';
        lead.FirstName = 'ws-user-exists-001';
        lead.LastName = 'ws-user-exists-001';
        lead.Phone = '1199996536';
        lead.Nacionalidade__c = 'BR';
        lead.TipoDocumento__c = 'CPF';
        lead.NumeroDocumento__c = GeraCpfCnpj.cpf(true);
        lead.Salutation = 'Mr.';
        return lead;
    }

    private static UsuarioSite__c createUsuarioSite(String idSite){
        UsuarioSite__c usuarioSite = new UsuarioSite__c();
        usuarioSite.IdSite__c = idSite;
        return usuarioSite;
    }

    private static void parametrizarCharter(fflib_ISObjectUnitOfWork uow, Account revoAccount, List<Product2> servicos, List<Aeronave__c> aeronaves){
        Product2 charter = createCharterFlight('Charter Standard');
        uow.registerNew(charter);

        RegraPreco__c regraPreco = createRegraPreco(20000);
        uow.registerRelationship(regraPreco, RegraPreco__c.Produto__c, charter);
        uow.registerNew(regraPreco);

        for(Aeronave__c aeronave : aeronaves){
            createAeronaveDisponivel(uow, aeronave, charter);
        }
        
        Boolean empacotado = false;

        for(Integer i = 0; i < servicos.size(); i++){
            criarProdutoPacote(uow, charter, servicos[i], empacotado, false, i + 1, true);
            empacotado = !empacotado;
        }
    }

    private static void parametrizarShuttleSeat(fflib_ISObjectUnitOfWork uow, Account revoAccount, Local__c localOrigem, Local__c localDestino, List<Product2> servicos, List<Aeronave__c> aeronaves){
        Product2 shuttleSeat = createShuttleSeat('Shuttle Seat SBGR > SBGR');

        uow.registerRelationship(shuttleSeat, Product2.LocalOrigem__c, localOrigem);
        uow.registerRelationship(shuttleSeat, Product2.LocalDestino__c, localDestino);
        Boolean empacotado = false;

        uow.registerNew(shuttleSeat);

        RegraPreco__c regraPreco = createRegraPreco(3000);
        uow.registerRelationship(regraPreco, RegraPreco__c.Produto__c, shuttleSeat);
        uow.registerNew(regraPreco);

        criarNovaMalhaVoo(uow, shuttleSeat, aeronaves, revoAccount);

        for(Integer i = 0; i < servicos.size(); i++){
            criarProdutoPacote(uow, shuttleSeat, servicos[i], empacotado, false, i + 1, true);
            empacotado = !empacotado;
        }
    }

    private static void parametrizarFullCabin(fflib_ISObjectUnitOfWork uow, Account revoAccount, Local__c localOrigem, Local__c localDestino, List<Product2> servicos, List<Aeronave__c> aeronaves){
        Product2 fullCabin = createFullCabin('Full Cabin SBGR > SBGR');

        uow.registerRelationship(fullCabin, Product2.LocalOrigem__c, localOrigem);
        uow.registerRelationship(fullCabin, Product2.LocalDestino__c, localDestino);
        Boolean empacotado = false;

        uow.registerNew(fullCabin);

        RegraPreco__c regraPreco = createRegraPreco(20000);
        uow.registerRelationship(regraPreco, RegraPreco__c.Produto__c, fullCabin);
        uow.registerNew(regraPreco);

        for(Aeronave__c aeronave : aeronaves){
            createAeronaveDisponivel(uow, aeronave, fullCabin);
        }

        for(Integer i = 0; i < servicos.size(); i++){
            criarProdutoPacote(uow, fullCabin, servicos[i], empacotado, false, i + 1, true);
            empacotado = !empacotado;
        }
    }

    private static void createAeronaveDisponivel(fflib_ISObjectUnitOfWork uow, Aeronave__c aeronave, Product2 produto){
        AeronaveDisponivel__c aeronaveDisponivel = new AeronaveDisponivel__c();
        
        uow.registerRelationship(aeronaveDisponivel, AeronaveDisponivel__c.Aeronave__c, aeronave);
        uow.registerRelationship(aeronaveDisponivel, AeronaveDisponivel__c.Produto__c, produto);
        uow.registerNew(aeronaveDisponivel);
    }

    private static MalhaVoo__c criarNovaMalhaVoo(fflib_ISObjectUnitOfWork uow, Product2 shuttleSeat, List<Aeronave__c> aeronaves, Account revoAccount){
        MalhaVoo__c malhaVoo = new MalhaVoo__c();
        malhaVoo.Ativa__c = true;
        malhaVoo.DataInicio__c = Date.today();
        malhaVoo.DataFim__c = Date.today().addDays(365);
        malhaVoo.SegundaFeira__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.TercaFeira__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.QuartaFeira__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.QuintaFeira__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.SextaFeira__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.Sabado__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.Domingo__c = '05:00;08:00;10:00;12:00;14:00;16:00;18:00;20:00;22:00';
        malhaVoo.NumeroAssentos__c = 10;
        malhaVoo.Duracao__c = 120;
        
        uow.registerNew(malhaVoo);

        uow.registerRelationship(malhaVoo, MalhaVoo__c.Produto__c, shuttleSeat);
        uow.registerRelationship(malhaVoo, MalhaVoo__c.OperadorMalha__c, revoAccount);

        Integer contador = 0;
        for(Aeronave__c aeronave : aeronaves){
            criarPrioridadeMalhaVoo(uow, malhaVoo, aeronave, contador);
            contador++;
        }
        return malhaVoo;
    }

    private static PrioridadeMalha__c criarPrioridadeMalhaVoo(fflib_ISObjectUnitOfWork uow, MalhaVoo__c malhaVoo, Aeronave__c aeronave, Integer prioridade){
        PrioridadeMalha__c prioridadeMalhaVoo = new PrioridadeMalha__c();
        prioridadeMalhaVoo.Prioridade__c = prioridade;
        
        uow.registerRelationship(prioridadeMalhaVoo, PrioridadeMalha__c.MalhaVoo__c, malhaVoo);
        uow.registerRelationship(prioridadeMalhaVoo, PrioridadeMalha__c.Aeronave__c, aeronave);
        
        uow.registerNew(prioridadeMalhaVoo);

        return prioridadeMalhaVoo;
    }

    private static void criarProdutoPacote(fflib_ISObjectUnitOfWork uow, Product2 produto, Product2 produtoPacote, Boolean obrigatorio, Boolean empacotado, Integer posicao, Boolean selecioado){
        ConfiguracaoPacote__c configuracaoPacote = new ConfiguracaoPacote__c();
        configuracaoPacote.Empacotado__c = empacotado;
        configuracaoPacote.Obrigatorio__c = obrigatorio;
        configuracaoPacote.Posicao__c = posicao;
        configuracaoPacote.Selecionado__c = selecioado;
        configuracaoPacote.QuantidadePadrao__c = 1;
        configuracaoPacote.QuantidadeRelativa__c = empacotado ? 'Pelo Padrão' : 'Por Passageiros';
        
        uow.registerRelationship(configuracaoPacote, ConfiguracaoPacote__c.ProdutoPacote__c, produtoPacote);
        uow.registerRelationship(configuracaoPacote, ConfiguracaoPacote__c.ProdutoPai__c, produto);

        uow.registerNew(configuracaoPacote);
    }

    private static List<Product2> parametrizarServicos(fflib_ISObjectUnitOfWork uow){
        Product2 transferBagagem = createServicosTaxas('Transfer de Bagagem');
        Product2 taxaPouso = createServicosTaxas('Taxa de Pouso');

        uow.registerNew(new List<Product2>{transferBagagem, taxaPouso});

        RegraPreco__c regraPrecoTransferBagagem = createRegraPreco(150);
        uow.registerRelationship(regraPrecoTransferBagagem, RegraPreco__c.Produto__c, transferBagagem);
        
        RegraPreco__c regraPrecoTaxaPouso = createRegraPreco(100);
        uow.registerRelationship(regraPrecoTaxaPouso, RegraPreco__c.Produto__c, taxaPouso);
        
        uow.registerNew(new List<RegraPreco__c>{regraPrecoTransferBagagem, regraPrecoTaxaPouso});

        RegraProduto__c regraProdutoPermitirTransferBagagem = createRegraProdutoPermitir();
        uow.registerRelationship(regraProdutoPermitirTransferBagagem, RegraProduto__c.Produto__c, transferBagagem);

        RegraProduto__c regraProdutoPermitirTaxaPouso = createRegraProdutoPermitir();
        uow.registerRelationship(regraProdutoPermitirTaxaPouso, RegraProduto__c.Produto__c, taxaPouso);

        RegraProduto__c regraProdutoRestringirTransferBagagem = createRegraProdutoRestringir();
        uow.registerRelationship(regraProdutoRestringirTransferBagagem, RegraProduto__c.Produto__c, transferBagagem);

        RegraProduto__c regraProdutoRestringirTaxaPouso = createRegraProdutoRestringir();
        uow.registerRelationship(regraProdutoRestringirTaxaPouso, RegraProduto__c.Produto__c, taxaPouso);


        uow.registerNew(new List<RegraProduto__c>{regraProdutoPermitirTransferBagagem, 
                                                  regraProdutoPermitirTaxaPouso,
                                                  regraProdutoRestringirTransferBagagem, 
                                                  regraProdutoRestringirTaxaPouso});
        
        return new List<Product2>{transferBagagem, taxaPouso};
    }

    private static Local__c createLocal(String name, String codigoLocal){
        Local__c local = new Local__c();
        local.Name = name;
        local.Tipo__c = 'Onshore';
        local.CodigoLocal__c = codigoLocal;
        local.Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        local.Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        return local;
    }

    private static Local__c createLocalBase(String name, String codigoLocal){
        
        Local__c local = createLocal(name, codigoLocal);
        local.Base__c = true;
        return local;
    }

    private static Product2 createModelo(String name){
        Product2 modelo = TestUtil.createProduct(name);   
        modelo.RecordTypeId = recordTypeModelo;
        modelo.ProductCode = name;
        return modelo;
    }

    private static Product2 createShuttleSeat(String name){
        Product2 shuttleSeat = TestUtil.createProduct(name);   
        shuttleSeat.RecordTypeId = recordTypeShuttleSeat;
        shuttleSeat.ProductCode = name;
        return shuttleSeat;
    }
    
    private static Product2 createFullCabin(String name){
        Product2 fullCabin = TestUtil.createProduct(name);   
        fullCabin.RecordTypeId = recordTypeFullCabin;
        fullCabin.ProductCode = name;
        return fullCabin;
    }
    
    private static Product2 createServicosTaxas(String name){
        Product2 servicosTaxas = TestUtil.createProduct(name);   
        servicosTaxas.RecordTypeId = recordTypeServicosTaxas;
        servicosTaxas.ProductCode = name;
        return servicosTaxas;
    }
    
    private static Product2 createCharterFlight(String name){
        Product2 charterFlight = TestUtil.createProduct(name);   
        charterFlight.RecordTypeId = recordTypeCharterFlight;
        charterFlight.ProductCode = name;
        return charterFlight;
    }

    private static RegraPreco__c createRegraPreco(Decimal precoUnitario){
        RegraPreco__c regraPreco = new RegraPreco__c();
        regraPreco.Ativo__c = true;
        regraPreco.DataInicial__c = System.today();
        regraPreco.DataFinal__c = System.today().addDays(360);
        regraPreco.DiaSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado';
        regraPreco.HorarioInicial__c = Time.newInstance(0, 0, 0, 0);
        regraPreco.HorarioFinal__c = Time.newInstance(23, 59, 0, 0);
        regraPreco.MinutosAntecedencia__c = 0;
        regraPreco.PrecoUnitario__c = precoUnitario;

        return regraPreco;
    }

    private static RegraProduto__c createRegraProdutoPermitir(){

        RegraProduto__c permitir = createRegraProduto('Permitir');
        return permitir;
    }

    
    private static RegraProduto__c createRegraProdutoRestringir(){
        RegraProduto__c restringir = createRegraProduto('Restringir');
        restringir.HorarioInicial__c = Time.newInstance(0, 0, 0, 0);
        restringir.HorarioFinal__c = Time.newInstance(6, 0, 0, 0);
        return restringir;
    }

    private static RegraProduto__c createRegraProdutoRestringirAssentos(){
        RegraProduto__c restringir = createRegraProduto('RestringirNumeroAssentos');
        restringir.HorarioInicial__c = Time.newInstance(6, 0, 0, 0);
        restringir.HorarioFinal__c = Time.newInstance(23, 59, 0, 0);
        restringir.NumeroAssentos__c = 6;
        return restringir;
    }

    private static RegraProduto__c createRegraProduto(String acao){
        RegraProduto__c regraProduto = new RegraProduto__c();
        regraProduto.Ativo__c = true;
        regraProduto.Acao__c = acao;
        regraProduto.DisponivelPara__c = 'Cliente;Parceiro;Concierge';
        regraProduto.HorarioInicial__c = Time.newInstance(0, 0, 0, 0);
        regraProduto.HorarioFinal__c = Time.newInstance(23, 59, 0, 0);
        regraProduto.MinutosAntecedencia__c = 0;
        return regraProduto;
    }
    
    public static void setupRestContext(String uri, String method) {
        RestRequest req = new RestRequest();
        req.requestUri = String.isBlank(uri) ? '/services/apexrest/revosite/v1/siteuser/' : uri;
        req.httpMethod = String.isBlank(method) ? 'POST' : method;
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }

    private static void criarCodigoPromocional(fflib_ISObjectUnitOfWork uow, String codigo){
        CodigoPromocional__c codigoPromocional = new CodigoPromocional__c();
        codigoPromocional.Name = codigo;
        codigoPromocional.Ativo__c = true;
        codigoPromocional.DataInicial__c = Date.today();
        codigoPromocional.DataFinal__c = Date.today().addDays(360);
        codigoPromocional.UsoUnico__c = false;
        codigoPromocional.Desconto__c = 10;
        codigoPromocional.QuantidadeDisponivel__c = 100;
        codigoPromocional.RecordTypeId = recordCodigoPromocional;

        uow.registerNew(codigoPromocional);
    }
}