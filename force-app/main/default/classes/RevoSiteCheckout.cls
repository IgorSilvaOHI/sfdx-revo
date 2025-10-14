@RestResource(urlMapping='/revosite/v1/checkout')
global without sharing class RevoSiteCheckout {

    // #region Váriaveis Privadas

    private static Set<String> tipoOportunidades = new Set<String> { 'ShuttleSeat', 'FullCabin', 'Charter' };

    // #endregion

    // #region Métodos Públicos

    @HttpPost
    global static void checkout(OpportunityCheckout param) {
        try {
                
            UsuarioSite__c usuario = UsuarioSiteSelector.newInstance().encontraPeloIdUsuarioSite(param.webSiteUserId);
            
            if (usuario == null) {
                throw new RevoSiteApi.UsuarioNaoEncontradoException(true);
            } 

            if (!tipoOportunidades.contains(param.oppotunityType)) {
                throw new TipoOportunidadeInvalidaException(true);
            }

            if (!param.confirmCheckout) {
                CheckoutResume resumo = resumeResult(usuario, param);

                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(resumo)
                );
            } else {

                if (param.priceBlockUntil == null || param.priceBlockUntil < Datetime.now()) {
                    throw new PrecoExpiradoException(true);
                }

                Savepoint sp = Database.setSavepoint();

                CheckoutResult result = null;

                try {
                    result = doCheckout(usuario, param);
                } catch (Exception e) {
                    Database.rollback(sp);
                    Database.releaseSavepoint(sp);
                    System.debug('error: ' + e);
                    throw e;
                }

                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(
                    JSON.serialize(result)
                );                
            }

        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }    

    // #endregion

    // #region Métodos  Checkout

    private static CheckoutResult doCheckout(UsuarioSite__c usuario, OpportunityCheckout param) {

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        fflib_ISObjectUnitOfWork uow1 = Application.UnitOfWork.newInstance();
        
        System.debug(usuario.Conta__c);

        Account contaUsuarioSite = processaContaSite(usuario);

        String codigoReserva = '';
        
        do{
            codigoReserva = TextUtils.generateBookingCode(6);
        }while (OpportunitySelector.newInstance().codigoReservaUtilizado(codigoReserva));

        Opportunity oportunidade = Opportunities.criaOportunidade(
            uow, 
            contaUsuarioSite.Id,
            contaUsuarioSite.Id,
            usuario.Name,
            param.oppotunityType, 
            param.promotionalId,
            codigoReserva,
            param.source
        );

        oportunidade.ValidadeUltimoCalculo__c = param.priceBlockUntil;

        Map<String, PassageiroOportunidade__c> contatos = processaContatos(uow, oportunidade, param);

        if (param.oppotunityType == 'ShuttleSeat') {
            if (param.shuttleSeats == null || param.shuttleSeats.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.shuttleSeats.size() > 4) {
                throw new MaximoException(true);
            }

            for (ShuttleSeat seat : param.shuttleSeats) {
                OpportunityLineItem line = criaLinhaOportunidadeShuttle(uow, uow1, oportunidade, seat, contatos);
            }
        } 

        if (param.oppotunityType == 'FullCabin') {

            if (param.fullCabins == null || param.fullCabins.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.fullCabins.size() > 4) {
                throw new MaximoException(true);
            }

            for (FullCabin full : param.fullCabins) {
                criaLinhaOportunidadeFullCabin(uow, uow1, oportunidade, full, contatos);
            }
        }

        if (param.oppotunityType == 'Charter') {

            if (param.charters == null || param.charters.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.charters.size() > 4) {
                throw new MaximoException(true);
            }

            for (Charter chart : param.charters) {
                criaLinhaOportunidadeCharter(uow, uow1, oportunidade, chart, contatos);
            }
        }        

        uow.commitWork();
        uow1.commitWork();

        if (param.oppotunityType == 'Charter') {
            /* 
            * Não faz checkout de Charter pelo Site...
            */

            CheckoutResult result = new CheckoutResult();
            result.opportunityId = oportunidade.Id;
            result.opportunityStatus = oportunidade.StageName;

            return result;
        }     

        /* Processo de Checkout */

        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

        // Busca todos os dados atualizados
        oportunidade = OpportunitySelector.newInstance().encontraParaFechamento(oportunidade.Id);

        CheckoutOportunidadeVoo checkout = new CheckoutOportunidadeVoo(oportunidade);

        if (oportunidade.Type == 'ShuttleSeat') {
            for (Id key : checkout.voosOportunidade.keyset()) {
                Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                OpportunityLineItem line = checkout.voosOportunidade.get(key);

                if (checkout.servicosTaxas.containsKey(line.Id)) {
                    for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                        mapServicos.put(service.Product2Id, service.Quantity.intValue());
                    }
                }
        
                IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);
        
                PesquisaMalha malha = service.resumoMalhaVoosCliente(
                    oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                    line.Quantity.intValue(), line.PrevisaoEmbarque__c, mapServicos, param.promotionalCode
                );

                checkout.carregaCalculo(line.Id, malha);
            }
        } 

        if (oportunidade.Type == 'FullCabin') {
            for (Id key : checkout.voosOportunidade.keyset()) {
                Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                OpportunityLineItem line = checkout.voosOportunidade.get(key);

                if (checkout.servicosTaxas.containsKey(line.Id)) {
                    for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                        mapServicos.put(service.Product2Id, service.Quantity.intValue());
                    }
                }
        
                IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);
        
                PesquisaFullCabin fullcabin = service.resumoFullCabinCliente(
                    oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                    line.PrevisaoEmbarque__c, line.ModeloSelecionado__c, mapServicos, param.promotionalCode
                );

                checkout.carregaCalculo(line.Id, fullcabin);
            }
        }

        checkout.validaOportunidade();

        checkout.validaOsProdutos();

        checkout.confirmaCheckout(uow2);

        uow2.commitWork();

        fflib_ISObjectUnitOfWork uow3 = Application.UnitOfWork.newInstance();

        checkout.preReservaVoos(uow3);

        checkout.bloqueiaAlteracoesFase(uow3);

        uow3.commitWork();

        IPagamentosService service = PagamentosService.service();

        Pagamento__c payment = service.criaPagamentoOportunidade(oportunidade.Id);        

        CheckoutResult result = new CheckoutResult();
        result.opportunityId = oportunidade.Id;
        result.paymentId = payment.Id;
        result.opportunityStatus = oportunidade.StageName;

        return result;
    }

    private static Account processaContaSite(UsuarioSite__c usuario) {

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        List<Account> contasSf = null;        
        Account contaUsuario = null;

        if (usuario.conta__c != null) {
            contasSf = AccountsSelector.newInstance().selectById(
                new Set<Id> { usuario.conta__c }
            );

            return contasSf[0];
        }

        List<Lead> leadsUsuario = LeadsSelector.newInstance().selectById(
            new Set<Id> { usuario.Lead__c }
        );

        Lead leadUsuario = leadsUsuario[0];

        if(String.isBlank(leadUsuario.TipoDocumento__c)) {
            throw new TipoDocumentoNaoInformadoException(true);
        }

        if(String.isBlank(leadUsuario.NumeroDocumento__c)) {
            throw new DocumentoNaoInformadoException(true);
        }

        if (leadUsuario.TipoDocumento__c == 'CNPJ') {
            contasSf = AccountsSelector.newInstance().selectAccountsByCNPJ(
                new Set<String> { leadUsuario.NumeroDocumento__c }
            );
        } else {
            contasSf = AccountsSelector.newInstance().selectPersonsByDocuments(
                new Set<String> { leadUsuario.TipoDocumento__c },
                new Set<String> { leadUsuario.NumeroDocumento__c } 
            );
        }

        contaUsuario = contasSf.isEmpty() ? null : contasSf[0];

        if (contaUsuario != null) {
            uow.registerDirty(usuario, UsuarioSite__c.Conta__c, contaUsuario);        
            Leads.qualificaLeadSite(uow, usuario.Lead__c);

            return contaUsuario;
        }

        contaUsuario = Accounts.atualizaContaUsuarioSite
        (
            uow, null, leadUsuario.Name, leadUsuario.GenderIdentity, leadUsuario.DataNascimento__c,
            leadUsuario.TipoDocumento__c, leadUsuario.NumeroDocumento__c, leadUsuario.CNPJCPF__c, leadUsuario.ContatoEmergencia__c, 
            leadUsuario.TelefoneEmergencia__c, leadUsuario.PossuiNecessidadesEspeciais__c, leadUsuario.NecessidadesEspeciais__c, 
            leadUsuario.Street, leadUsuario.City, leadUsuario.State, leadUsuario.PostalCode, leadUsuario.Country, 
            leadUsuario.Complemento__c, leadUsuario.Nacionalidade__c, leadUsuario.Idioma__c,
            leadUsuario.Email, leadUsuario.Phone, leadUsuario.Salutation
        );

        uow.registerDirty(usuario, UsuarioSite__c.Conta__c, contaUsuario);
        Leads.qualificaLeadSite(uow, usuario.Lead__c);

        uow.commitWork();

        return contaUsuario;
    }

    private static Map<String, PassageiroOportunidade__c> processaContatos(fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityCheckout param) {

        Set<String> tipos = new Set<String>();
        Set<String> documentos = new Set<String>();

        for (Passenger contato : param.passengers) {
            tipos.add(contato.documentType);
            documentos.add(contato.document);
        }

        List<Contact> contatosSalvos = ContatosSelector.newInstance().selectContactsByDocuments(
            tipos, documentos
        );

        Map<String, Contact> existente = new Map<String, Contact>();

        for (Contact contato : contatosSalvos) {
            existente.put(contato.TipoDocumento__c + contato.NumeroDocumento__c, contato);
        }

        Map<String, PassageiroOportunidade__c> mapContatos = new Map<String, PassageiroOportunidade__c>();

        for (Passenger passageiro : param.passengers) {
            Contact contato = null;

            if (existente.containsKey(passageiro.documentType + passageiro.document)) {
                contato = existente.get(passageiro.documentType + passageiro.document);
            } else {
                contato = Contacts.criaContatoPassageiro(uow, passageiro.nationality, passageiro.documentType, passageiro.document, passageiro.fullName, 
                passageiro.birthDate, passageiro.email, passageiro.phone, passageiro.emergencyContactName, passageiro.emergencyContactPhone, 
                passageiro.hasSpecialNeeds, passageiro.specialNeeds);
            }

            PassageiroOportunidade__c passOpp = Opportunities.criaPassageiroOportunidade(
                uow, oportunidade, contato
            );

            mapContatos.put(passageiro.key, passOpp);
        }

        return mapContatos;
    }

    // #endregion

    // #region Métodos Checkout Opportunity Itens

    private static OpportunityLineItem criaLinhaOportunidadeShuttle(
        fflib_ISObjectUnitOfWork uow, fflib_ISObjectUnitOfWork uow1, Opportunity oportunidade, ShuttleSeat item, Map<String, PassageiroOportunidade__c> contatos
    ) 
    {

        OpportunityLineItem line = Opportunities.criaLinhaShuttleSeat(
            uow,
            item.productId,
            item.aircraftModelId,
            item.missionTime, 
            item.quantity, 
            item.appliedPromotion,
            item.flightDateTime,
            item.unitPrice,
            0,
            oportunidade,
            item.departurePointId,
            item.destinationPointId,
            item.routeId,
            item.totalPrice,
            0,
            item.valueDiscount,
            item.percDiscount
        );
        
        List<LocalOportunidade__c> locais = Opportunities.criaLocaisOrigemDestino(uow1, oportunidade, line, item.departurePointId, item.destinationPointId);

        criaProdutosDosPassageiros(uow1, oportunidade, line, item.passengerServices, contatos);

        criaLinhasOportunidadeServico(uow1, oportunidade, line, item.flightDateTime, item.services, contatos);
        
        return line;
    }

    private static OpportunityLineItem criaLinhaOportunidadeFullCabin(
        fflib_ISObjectUnitOfWork uow, fflib_ISObjectUnitOfWork uow1, Opportunity oportunidade, FullCabin item, Map<String, PassageiroOportunidade__c> contatos
    ) 
    {
        OpportunityLineItem line = Opportunities.criaLinhaFullCabin(
            uow,
            item.productId,
            item.aircraftModelId,
            item.missionTime,  
            item.appliedPromotion,
            item.flightDateTime,
            item.unitPrice,
            0,
            oportunidade,
            item.departurePointId,
            item.destinationPointId,
            item.totalPrice,
            0,
            item.valueDiscount,
            item.percDiscount
        );
        
        List<LocalOportunidade__c> locais = Opportunities.criaLocaisOrigemDestino(uow1, oportunidade, line, item.departurePointId, item.destinationPointId);

        criaProdutosDosPassageiros(uow1, oportunidade, line, item.passengerServices, contatos);

        criaLinhasOportunidadeServico(uow1, oportunidade, line, item.flightDateTime, item.services, contatos);

        return line;
    }

    private static OpportunityLineItem criaLinhaOportunidadeCharter(
        fflib_ISObjectUnitOfWork uow, fflib_ISObjectUnitOfWork uow1, Opportunity oportunidade, Charter item, Map<String, PassageiroOportunidade__c> contatos
    ) 
    {
        OpportunityLineItem line = Opportunities.criaLinhaCharter(
            uow,
            item.productId,
            item.aircraftModelId,
            item.missionTime,  
            item.appliedPromotion,
            item.flightDateTime,
            item.unitPrice,
            0,
            oportunidade,
            null, 
            null, 
            item.totalPrice,
            0,
            item.valueDiscount,
            item.percDiscount
        );

        for (LocalCharter chart : item.route) {
            LocalOportunidade__c local = Opportunities.criaLocal(uow1, oportunidade, line, chart.sequence, chart.wayPointId, chart.latitude, chart.longitude);
        }

        criaProdutosDosPassageiros(uow1, oportunidade, line, item.passengerServices, contatos);

        criaLinhasOportunidadeServico(uow1, oportunidade, line, item.flightDateTime, item.services, contatos);

        return line;
    }            

    private static void criaLinhasOportunidadeServico(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem line, 
        Datetime flightDateTime, List<PackageServices> servicos, Map<String, PassageiroOportunidade__c> contatos
    ) 
    {

        for (PackageServices servicoPacote : servicos) {

            OpportunityLineItem servico = Opportunities.criaLinhaServico(
                uow,
                oportunidade,
                line,
                servicoPacote.productId,
                servicoPacote.quantity,
                servicoPacote.required,
                servicoPacote.Bundled,
                servicoPacote.passengerQty,
                servicoPacote.appliedPromotion,
                flightDateTime,
                servicoPacote.unitPrice,
                0,
                servicoPacote.totalPrice,
                0,
                servicoPacote.valueDiscount,
                servicoPacote.percDiscount
            );         

            criaProdutosDosPassageiros(uow, oportunidade, servico, servicoPacote.passengerServices, contatos);
        }
    }

    private static void criaProdutosDosPassageiros(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem line, List<PassengerService> passengerServices,
        Map<String, PassageiroOportunidade__c> contatos
    ) 
    {
        for (PassengerService passServ : passengerServices) {

            PassageiroOportunidade__c passageiro = contatos.get(passServ.keyPassenger);

            ProdutoPassageiro__c servicoPass = Opportunities.criaProdutoDoPassageiro(
                uow, passageiro, line, passServ.serviceAddress, passServ.servicecity, 
                passServ.servicestate, passServ.servicezipcode, passServ.servicecountry, 
                passServ.serviceaddressLine2, passServ.smallBags, passServ.mediumBags, 
                passServ.bigBags, 'Configurado', passServ.serviceAirline, passServ.serviceFlightNumber
            );
        }
    }

    // #endregion

    // #region Métodos Resumo

    private static CheckoutResume resumeResult(UsuarioSite__c usuario, OpportunityCheckout param) {

        CheckoutResume resumo = new CheckoutResume();

        if (param.oppotunityType == 'ShuttleSeat') {

            if (param.shuttleSeats == null || param.shuttleSeats.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.shuttleSeats.size() > 4) {
                throw new MaximoException(true);
            }

            resumo.shuttleSeats = new List<ShuttleSeatResume>();

            for (ShuttleSeat  shuttleSeat : param.shuttleSeats) {
                resumo.shuttleSeats.add(resumeShuttleSeat(usuario, shuttleSeat, param.promotionalCode));
            }

        }

        if (param.oppotunityType == 'FullCabin') {

            if (param.fullCabins == null || param.fullCabins.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.fullCabins.size() > 4) {
                throw new MaximoException(true);
            }

            resumo.fullCabins = new List<FullCabinResume>();

            for (FullCabin  fullCabin : param.fullCabins) {
                resumo.fullCabins.add(resumeFullCabin(usuario, fullCabin, param.promotionalCode));
            }                
        }

        if (param.oppotunityType == 'Charter') {

            if (param.charters == null || param.charters.isEmpty()) {
                throw new ProdutosNaoInformadosException(true);
            }

            if (param.charters.size() > 4) {
                throw new MaximoException(true);
            }

            resumo.charters = new List<CharterResume>();

            for (Charter  chart : param.charters) {
                resumo.charters.add(resumeCharter(usuario, chart, param.promotionalCode));
            }                   
        }

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioSelecaoVoo__c;

        resumo.priceBlockUntil = System.now();
        resumo.priceBlockUntil = resumo.priceBlockUntil.addMinutes(Integer.valueOf(tempoParaResetar));

        return resumo;
    }

    private static ShuttleSeatResume resumeShuttleSeat(UsuarioSite__c usuario, ShuttleSeat param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServices service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaMalha malha = service.resumoMalhaVoosCliente(
            usuario.Conta__c, param.departurePointId, param.destinationPointId, 
            param.quantity, param.flightDateTime, mapServicos, promotionalCode
        );

        ShuttleSeatResume resume = new ShuttleSeatResume();

        resume.key = param.key;
        resume.shuttleSeat = RevoSiteShuttleSearch.mapping(new List<PesquisaMalha> { malha })[0];
        
        return resume;
    }

    private static FullCabinResume resumeFullCabin(UsuarioSite__c usuario, FullCabin param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServices service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaFullCabin fullcabin = service.resumoFullCabinCliente(
            usuario.Conta__c, param.departurePointId, param.destinationPointId, 
            param.flightDateTime, param.aircraftModelId, mapServicos, promotionalCode
        );

        FullCabinResume resume = new FullCabinResume();

        resume.key = param.key;
        resume.fullCabin = RevoSiteFullCabinSearch.mapping(new List<PesquisaFullCabin> { fullcabin })[0];

        return resume;
    }    

    private static CharterResume resumeCharter(UsuarioSite__c usuario, Charter param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServices service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }

        List<Local__c> locais = RevoSiteCharterSearch.parse(mapping(param.route));

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaCharter charter = service.resumoChartCliente( 
            locais, param.flightDateTime,
            usuario.Conta__c, param.aircraftModelId, mapServicos, promotionalCode
        );

        CharterResume resume = new CharterResume();
        
        resume.key = param.key;
        resume.charter = RevoSiteCharterSearch.mapping(new List<PesquisaCharter> { charter })[0];

        return resume;
    }        

    private static List<RevoSiteCharterSearch.LocalCharter> mapping(List<LocalCharter> route) {
        List<RevoSiteCharterSearch.LocalCharter> results = new List<RevoSiteCharterSearch.LocalCharter>();

        for (LocalCharter local : route) {

            RevoSiteCharterSearch.LocalCharter novoLocal = new RevoSiteCharterSearch.LocalCharter();
        
            novoLocal.sequence = local.sequence;
            novoLocal.wayPointId = local.wayPointId;
            novoLocal.latitude = local.latitude;
            novoLocal.longitude = local.longitude;

            results.add(novoLocal);
        }
        
        return results;
    }     

    // #endregion

    // #region Service Classes

    global class CheckoutResume {
        public DateTime priceBlockUntil { get; set; }
        public List<ShuttleSeatResume> shuttleSeats { get; set; }
        public List<FullCabinResume> fullCabins { get; set; }
        public List<CharterResume> charters { get; set; }
    }

    global class CheckoutResult {
        public String opportunityId { get; set; }
        public String paymentId { get; set; }
        public String opportunityStatus { get; set; }
    }

    global class ShuttleSeatResume {
        public String key { get; set; }
        public RevoSiteShuttleSearch.ShuttleSeatResults shuttleSeat { get; set; }
    }

    global class FullCabinResume {
        public String key { get; set; }
        public RevoSiteFullCabinSearch.FullCabinResults fullCabin { get; set; }
    }

    global class CharterResume {
        public String key { get; set; }
        public RevoSiteCharterSearch.CharterResults charter { get; set; }
    }

    global class OpportunityCheckout {
        public String webSiteUserId { get; set; }
        public Boolean confirmCheckout { get; set; }
        public String oppotunityType { get; set; }
        public String source { get; set; }
        public String promotionalCode {get; set;}
        public String promotionalId {get; set;}

        public Datetime priceBlockUntil { get; set; }
        
        public List<Passenger> passengers {get; set;}

        public List<ShuttleSeat> shuttleSeats { get; set; }
        public List<FullCabin> fullCabins { get; set; }
        public List<Charter> charters { get; set; }
    }

    global class ShuttleSeat {
        public String key { get; set; }
        public String productId {get; set;}
        public String aircraftModelId {get; set;}
        public String routeId {get; set;} 
        public String departurePointId {get; set;} 
        public String destinationPointId {get; set;} 
        public DateTime flightDateTime {get; set;} 
        public Decimal missionTime {get; set;}
        public Decimal unitPrice {get; set;}
        public Integer quantity {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}   
        public Boolean appliedPromotion {get; set;}
        public List<PackageServices> services {get; set;}
        public List<PassengerService> passengerServices { get; set; }
    }    

    global class FullCabin {
        public String key { get; set; }
        public String productId {get; set;} 
        public String aircraftModelId {get; set;}
        public String departurePointId {get; set;} 
        public String destinationPointId {get; set;} 
        public Decimal missionTime {get; set;}
        public DateTime flightDateTime {get; set;} 
        public Decimal unitPrice {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}
        public Boolean appliedPromotion {get; set;}
        public List<PackageServices> services {get; set;}
        public List<PassengerService> passengerServices { get; set; }
    }

    global class Charter {    
        public String key { get; set; }
        public String productId {get; set;} 
        public List<LocalCharter> route { get; set; }
        public String aircraftModelId {get; set;}
        public DateTime flightDateTime { get; set; }
        public Decimal missionTime {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}    
        public Boolean appliedPromotion {get; set;}
        public List<PackageServices> services {get; set;}
        public List<PassengerService> passengerServices { get; set; }
    }

    global class LocalCharter {

        public Integer sequence { get; set; } 
        public String wayPointId { get; set; }
        public Double latitude { get; set; }
        public Double longitude { get; set; }

    }

    global class PackageServices {
        public String productId {get; set;} 
        public Boolean required {get; set;}
        public Boolean Bundled {get; set;}
        public Boolean selected {get; set;}
        public Boolean passengerQty {get; set;}
        public Integer position {get; set;}
        public Decimal unitPrice {get; set;}
        public Integer quantity {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}
        public Boolean appliedPromotion {get; set;}
        public List<PassengerService> passengerServices { get; set; }
    }

    global class Passenger {
        public String key { get; set; }

        public String fullName { get; set; }
        public Date birthDate { get; set; }
        public String nationality { get; set; }
        public String documentType { get; set; }
        public String document { get; set; }

        public String email { get; set; }
        public String phone { get; set; }        

        public String emergencyContactName { get; set; }
        public String emergencyContactPhone { get; set; }
        public Boolean hasSpecialNeeds { get; set; }
        public String specialNeeds { get; set; }        

        public Integer smallBags { get; set; }
        public Integer mediumBags { get; set; }
        public Integer bigBags { get; set; }

        public String company { get; set; }
        public String flightNumber { get; set; }
    }

    global class PassengerService {
        public String keyPassenger { get; set; }

        public String serviceAddress { get; set; }
        public String servicecity { get; set; }
        public String servicestate { get; set; }
        public String servicezipcode { get; set; }
        public String servicecountry { get; set; }
        public String serviceaddressLine2 { get; set; } 
        public String serviceAirline { get; set; } 
        public String serviceFlightNumber { get; set; } 
        public Integer smallBags { get; set; }
        public Integer mediumBags { get; set; }
        public Integer bigBags { get; set; }
    }

    // #endregion

    // #region Excepitions

    public class TipoOportunidadeInvalidaException extends RevoSiteApi.RevoSiteApiException {
        public TipoOportunidadeInvalidaException(Boolean voidParam) {
            super('API-0003','Tipo de Oportunidade não encontrada!');
        }
    }

    public class ProdutosNaoInformadosException extends RevoSiteApi.RevoSiteApiException {
        public ProdutosNaoInformadosException(Boolean voidParam) {
            super('API-0004','Produtos não informados!');
        }
    }

    public class MaximoException extends RevoSiteApi.RevoSiteApiException {
        public MaximoException(Boolean voidParam) {
            super('API-0005','Máximo 4 produtos por oportunidade!');
        }
    }

    public class PrecoExpiradoException extends RevoSiteApi.RevoSiteApiException {
        public PrecoExpiradoException(Boolean voidParam) {
            super('API-0006','Preço expirado necessário recalcular!');
        }
    }

    public class TipoDocumentoNaoInformadoException extends RevoSiteApi.RevoSiteApiException {
        public TipoDocumentoNaoInformadoException(Boolean voidParam) {
            super('API-0007','Campo Tipo de Documento do Usuário Obrigatório!');
        }
    }

    public class DocumentoNaoInformadoException extends RevoSiteApi.RevoSiteApiException {
        public DocumentoNaoInformadoException(Boolean voidParam) {
            super('API-0008','Campo Documento do Usuário Obrigatório!');
        }
    }

    // #endregion 
}