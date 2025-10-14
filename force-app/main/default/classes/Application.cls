public class Application {
    // ******* Ao inserir um objectType pensar na ordem de criação. Ex. Contato precisa de conta, logo conta antes de contato ******* //
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
        new List<SObjectType>{
            User.SObjectType ,
            TaxaMoeda__c.SObjectType,
            Account.SObjectType,
            CodigoPromocional__c.SObjectType,
            ItemPromocao__c.SObjectType,
            Local__c.SObjectType,
            Aerovia__c.SObjectType,
            Product2.SObjectType,
            PricebookEntry.SObjectType,
            Aeronave__c.SObjectType,
            Missao__c.SObjectType,
            Lead.SObjectType,
            UsuarioSite__c.SObjectType,
            Contact.SObjectType,
            Voo__c.SObjectType,
            Trecho__c.SObjectType,
            Passageiro__c.SObjectType,
            Opportunity.SObjectType,
            OpportunityLineItem.SObjectType,
            PromocaoOportunidade__c.SObjectType,
            Pagamento__c.SObjectType,
            TransacaoGateway__c.SObjectType,
            Empenho__c.SObjectType,
            PassageiroOportunidade__c.SObjectType,
            LocalOportunidade__c.SObjectType,
            ProdutoPassageiro__c.SObjectType,
            LogVoo__c.SObjectType,
            LogIntegracao__c.SObjectType,
            ContentVersion.SObjectType,
            ContentDocument.SObjectType,
            ContentDocumentLink.SObjectType,
            Integracao__mdt.SObjectType,
            Calendar.SObjectType,
            Event.SObjectType,
            PoliticaDesconto__c.SObjectType,
            RegraDesconto__c.SObjectType,
            Interessado__c.SObjectType,
            IntervaloSol__c.SObjectType,
            PassageiroVoo__c.SObjectType,
            Tarifas__c.SObjectType,
            EmailMessage.SObjectType,
            Task.sObjectType,
            Servico__c.sObjectType,
            Carga__c.SObjectType,
            RegraPreco__c.SObjectType,
            RegraProduto__c.SObjectType,
            ConfiguracaoPacote__c.SObjectType,
            MalhaVoo__c.SObjectType,
            Horarioextradamalha__c.SObjectType,
            PrioridadeMalha__c.SObjectType,
            AeronaveDisponivel__c.SObjectType
        }
    );

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(
        new Map<Type, Type>{
            IMissoesService.class => MissoesServiceImpl.class,
            IPassageirosService.class => PassageirosServiceImpl.class,
            IEventsService.class => EventsServiceImpl.class,
            IOpportunityService.class => OpportunityServiceImpl.class,
            IPagamentosService.class => PagamentosServiceImpl.class,
            IVoosService.class => VoosServiceImpl.class,
            IPassageirosVooService.class => PassageirosVooServiceImpl.class,
            IContatosService.class => ContatosServiceImpl.class,
            IInteressadosService.class => InteressadosServiceImpl.class
        }
    );

    // ******* Ao inserir um objectType pensar na ordem de criação. Ex. Contato precisa de conta, logo conta antes de contato ******* //
    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type>{
            Account.SObjectType => AccountsSelector.class,
            IntervaloSol__c.SObjectType => IntervalosSolSelector.class,
            Aeronave__c.SObjectType => AeronavesSelector.class,
            Product2.SObjectType => Product2Selector.class,
            Trecho__c.SObjectType => TrechosSelector.class,
            Voo__c.SObjectType => VoosSelector.class,
            Local__c.SObjectType => LocaisSelector.class,
            Aerovia__c.SObjectType => AeroviasSelector.class,
            Missao__c.SObjectType => MissoesSelector.class,
            Calendar.SObjectType => CalendarsSelector.class,
            Lead.SObjectType => LeadsSelector.class,
            UsuarioSite__c.SObjectType => UsuarioSiteSelector.class,
            Contact.SObjectType => ContatosSelector.class,
            Passageiro__c.SObjectType => PassageirosSelector.class,
            ContentDocumentLink.SObjectType => ContentDocumentLinksSelector.class,
            Event.SObjectType => EventsSelector.class,
            StatusBloqueioDelecaoVoo__mdt.SObjectType => StatusBloqueioDelecaoVooSelector.class,
            Carga__c.SObjectType => CargasSelector.class,
            ConfiguracaoPacote__c.SObjectType => ConfiguracaoPacoteSelector.class,
            RegraProduto__c.SObjectType => RegraProdutoSelector.class,
            RegraPreco__c.SObjectType => RegraPrecoSelector.class,
            RegraDesconto__c.SObjectType => RegraDescontoSelector.class,
            CodigoPromocional__c.SObjectType => CodigoPromocionalSelector.class,
            Opportunity.SObjectType => OpportunitySelector.class,
            MalhaVoo__c.SObjectType => MalhaVooSelector.class,
            PrioridadeMalha__c.SObjectType => PrioridadeMalhaSelector.class,
            AeronaveDisponivel__c.SObjectType => AeronaveDisponivelSelector.class,
            Servico__c.SObjectType => ServicosSelector.class,
            Pagamento__c.SObjectType => PagamentosSelector.class,
            Interessado__c.SObjectType => InteressadosSelector.class,
            TemplateEmail__mdt.SObjectType => TemplateEmailSelector.class,
            PassageiroVoo__c.SObjectType => PassageirosVooSelector.class,
            EmailMessage.SObjectType => EmailMessageSelector.class
        }
    );

    //Due to limitations within Apex,
    //we cannot pass into the constructor of the domain layer a list of accounts directly,
    //so we have to pass them into the constructor via a different approach.
    //This is done via an inner class within the domain layer which implements fflib_SObjectDomain.IConstructable.
    //Our inner class must then implement a method called “construct” and accepts a list of sObjects.
    //Our inner class can now instantiate an instance of our domain layer (the outer class) and
    //pass along the generic list of sObjects to a list of concrete sObject types.
    //
    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        Application.Selector,
        new Map<SObjectType, Type>{
            Account.SObjectType => Accounts.Constructor.class,
            Voo__c.SObjectType => Voos.Constructor.class,
            Local__c.SObjectType => Locais.Constructor.class,
            Aerovia__c.SObjectType => Aerovias.Constructor.class,
            Aeronave__c.SObjectType => Aeronaves.Constructor.class,
            Missao__c.SObjectType => Missoes.Constructor.class,
            Lead.SObjectType => Leads.Constructor.class,
            UsuarioSite__c.SObjectType => UsuarioSite.Constructor.class,
            Trecho__c.SObjectType => Trechos.Constructor.class,
            Passageiro__c.SObjectType => Passageiros.Constructor.class,
            Event.SObjectType => Events.Constructor.class,
            Servico__c.SObjectType => Servicos.Constructor.class,
            Pagamento__c.SObjectType => Pagamentos.Constructor.class,
            PassageiroOportunidade__c.SObjectType => PassageiroOportunidades.Constructor.class,
            ProdutoPassageiro__c.SObjectType => ProdutoPassageiros.Constructor.class,
            Interessado__c.SObjectType => Interessados.Constructor.class
        }
    );
}