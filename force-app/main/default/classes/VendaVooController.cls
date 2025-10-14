public without sharing class VendaVooController {

    @TestVisible
    private static IOpportunityService service = OpportunityService.service();

    @AuraEnabled
    public static List<PesquisaMalha> getMalhaVoo(Id conta, Id origem, Id destino,Integer quantidade, Date data, string codigoPromocional){

        User currentUser = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId()];

        if (currentUser.IsPartner) {
            return service.pesquisaMalhaVoosParceiro(conta, origem, destino, quantidade, data, 3, codigoPromocional);
        } else {
            return service.pesquisaMalhaVoosConcierge(conta, origem, destino, quantidade, data, 3, codigoPromocional);
        }
    }

    @AuraEnabled
    public static List<PesquisaCharter> getVooCharterClient(List<DestinoCharter> destino, DateTime data, Id conta, string codigoPromocional){
        List<Local__c> locais = new List<Local__c>();
        for (DestinoCharter dest : destino) {
            locais.add(new Local__c(id = dest.id, Coordenadas__Latitude__s = dest.latitude, Coordenadas__Longitude__s = dest.longitude));
        }

        User currentUser = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId()];

        if (currentUser.IsPartner) {
            return service.pesquisaChartParceiro(locais, data, conta, codigoPromocional);
        } else {
            return service.pesquisaChartConcierge(locais, data, conta, codigoPromocional);
        }
    }

    @AuraEnabled
    public static List<PesquisaFullCabin> getVooFullCabin(Id conta, Id origem, Id destino, Date data, string codigoPromocional){

        User currentUser = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId()];

        if (currentUser.IsPartner) {
            return service.pesquisaFullCabinParceiro(conta, origem, destino, data, codigoPromocional);
        } else {
            return service.pesquisaFullCabinConcierge(conta, origem, destino, data, codigoPromocional);
        }        
    }

    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItems(String opportunityId){
        //TODO: Mover para DAO
        return [
            SELECT Id, Quantity, UnitPrice, TotalPrice, Obrigatorio__c, DescontoPercentual__c, DescontoValor__c,
                   Product2.Name, Description, Pacote__c, PrevisaoEmbarque__c, PrecoUnitario__c
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opportunityId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isInCommunity() {
        Id siteId = Site.getSiteId();
        return siteId != null;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> criarLinhasOportunidade(String flightTipe, String selectedFlight){

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<ServicoDoPacote> servicos;
        Opportunity oportunidade = new Opportunity();

        switch on flightTipe {
            when 'Shuttle' {
                VooShuttleWrapper wrapper = (VooShuttleWrapper)JSON.deserialize(selectedFlight, VooShuttleWrapper.class);
                opportunityLineItems.add(
                    Opportunities.criaLinhaShuttleSeat(
                        uow,
                        wrapper.produto,
                        wrapper.modeloId,
                        wrapper.voo.tempoMissao, 
                        wrapper.voo.quantidade, 
                        wrapper.voo.promocaoValida,
                        wrapper.voo.dataHora,
                        wrapper.voo.precoUnitario,
                        wrapper.voo.precoRevoSeats,
                        oportunidade,
                        wrapper.voo.origem,
                        wrapper.voo.destino,
                        wrapper.voo.malhaId,
                        wrapper.voo.precoFinal,
                        wrapper.voo.precoFinalRevoSeats,
                        wrapper.voo.descontoValor,
                        wrapper.voo.descontoPerc
                    )
                );
                servicos = wrapper.voo.servicos;
            }
            when 'Charter' {
                VooCharterWrapper wrapper = (VooCharterWrapper)JSON.deserialize(selectedFlight, VooCharterWrapper.class);

                Map<Id, Local__c> trajetos = new Map<Id, Local__c> (LocaisSelector.newInstance().selectById(new Set<Id> { wrapper.voo.origemInicial, wrapper.voo.destinoFinal }));

                opportunityLineItems.add(
                    Opportunities.criaLinhaCharter(
                        uow,
                        wrapper.produto,
                        wrapper.voo.modeloId,
                        wrapper.voo.tempoMissao, 
                        wrapper.voo.promocaoValida,
                        wrapper.dataHora,
                        wrapper.voo.precoUnitario,
                        wrapper.voo.precoRevoSeats,
                        oportunidade,
                        trajetos.containsKey(wrapper.voo.origemInicial) ? wrapper.voo.origemInicial : null,
                        trajetos.containsKey(wrapper.voo.destinoFinal) ? wrapper.voo.destinoFinal : null,
                        wrapper.voo.precoFinal,
                        wrapper.voo.precoFinalRevoSeats,
                        wrapper.voo.descontoValor,
                        wrapper.voo.descontoPerc
                    )
                );
                servicos = wrapper.voo.servicos;
            }
            when else {
                VooFullCabinWrapper wrapper = (VooFullCabinWrapper)JSON.deserialize(selectedFlight, VooFullCabinWrapper.class);
                opportunityLineItems.add(
                    Opportunities.criaLinhaFullCabin(
                        uow,
                        wrapper.produto,
                        wrapper.voo.modeloId,
                        wrapper.voo.tempoMissao,  
                        wrapper.voo.promocaoValida,
                        wrapper.dataHora,
                        wrapper.voo.precoUnitario,
                        wrapper.voo.precoRevoSeats,
                        oportunidade,
                        wrapper.origem,
                        wrapper.destino,
                        wrapper.voo.precoFinal,
                        wrapper.voo.precoFinalRevoSeats,
                        wrapper.voo.descontoValor,
                        wrapper.voo.descontoPerc
                    )
                );
                servicos = wrapper.voo.servicos;
            }
        }

        for(ServicoDoPacote servicoPacote : servicos){
            opportunityLineItems.add(
                Opportunities.criaLinhaServico(
                    uow,
                    oportunidade,
                    opportunityLineItems.get(0),
                    servicoPacote.produto,
                    servicoPacote.quantidade,
                    servicoPacote.obrigatorio,
                    servicoPacote.empacotado,
                    servicoPacote.porPassageiro,
                    servicoPacote.promocaoValida,
                    null,
                    servicoPacote.precoUnitario,
                    servicoPacote.precoRevoSeats,
                    servicoPacote.precoFinal,
                    servicoPacote.precoFinalRevoSeats,
                    servicoPacote.descontoValor,
                    servicoPacote.descontoPerc
                )
            );
        }

        return opportunityLineItems;
    }

    @AuraEnabled
    public static FlightRecalculateResumeWrapper flightRecalculate(FlightRecalculateWrapper param, string conta){
        return resumeResult(param);
    }

    @TestVisible
    private static FlightRecalculateResumeWrapper resumeResult(FlightRecalculateWrapper param) {

        FlightRecalculateResumeWrapper resumo = new FlightRecalculateResumeWrapper();

        if (param.oppotunityType == 'ShuttleSeat') {
            resumo.shuttleSeats = new List<PesquisaMalha>();

            for (ShuttleSeatWrapper  shuttleSeat : param.shuttleSeats) {
                resumo.shuttleSeats.add(resumeShuttleSeat(param.account, shuttleSeat, param.promotionalCode));
            }
        }

        if (param.oppotunityType == 'FullCabin') {

            resumo.fullCabins = new List<PesquisaFullCabin>();

            for (FullCabinWrapper  fullCabin : param.fullCabins) {
                resumo.fullCabins.add(resumeFullCabin(param.account, fullCabin, param.promotionalCode));
            }                
        }

        if (param.oppotunityType == 'Charter') {

            resumo.charters = new List<PesquisaCharter>();

            for (CharterWrapper  chart : param.charters) {
                resumo.charters.add(resumeCharter(param.account, chart, param.promotionalCode));
            }                   
        }

        return resumo;
    }

    @TestVisible
    private static PesquisaMalha resumeShuttleSeat(String account, ShuttleSeatWrapper param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServicesWrapper service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaMalha malha = service.resumoMalhaVoosConcierge(
            account, param.departurePointId, param.destinationPointId, 
            param.quantity, param.flightDateTime, mapServicos, promotionalCode
        );
        
        return malha;
    }

    @TestVisible
    private static PesquisaFullCabin resumeFullCabin(String account, FullCabinWrapper param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServicesWrapper service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaFullCabin fullcabin = service.resumoFullCabinConcierge(
            account, param.departurePointId, param.destinationPointId, 
            param.flightDateTime, param.modeloId, mapServicos, promotionalCode
        );

        return fullcabin;
    }    

    @TestVisible
    private static PesquisaCharter resumeCharter(String account, CharterWrapper param, String promotionalCode) {

        if (param == null) {
            return null;
        }

        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

        for (PackageServicesWrapper service : param.services) {
            mapServicos.put(service.productId, service.quantity);
        }
        
        List<Local__c> locais = new List<Local__c>();
        for (DestinoCharter dest : param.route) {
            locais.add(new Local__c(id = dest.id, Coordenadas__Latitude__s = dest.latitude, Coordenadas__Longitude__s = dest.longitude));
        }

        IOpportunityService service = (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);

        PesquisaCharter charter = service.resumoChartConcierge( 
            locais, param.flightDateTime,
            account,param.modeloId, mapServicos, promotionalCode
        );

        return charter;
    }     
    
    public class FlightRecalculateResumeWrapper {
        public DateTime priceBlockUntil { get; set; }
        @AuraEnabled public List<PesquisaMalha> shuttleSeats { get; set; }
        @AuraEnabled public List<PesquisaFullCabin> fullCabins { get; set; }
        @AuraEnabled public List<PesquisaCharter> charters { get; set; }
    }

    public class FlightRecalculateWrapper {
        @AuraEnabled public String account {get; set;}
        @AuraEnabled public String oppotunityType { get; set; }
        @AuraEnabled public String promotionalCode {get; set;}
        @AuraEnabled public List<ShuttleSeatWrapper> shuttleSeats { get; set; }
        @AuraEnabled public List<FullCabinWrapper> fullCabins { get; set; }
        @AuraEnabled public List<CharterWrapper> charters { get; set; }
    }    

    public class ShuttleSeatWrapper {
        @AuraEnabled public String productId {get; set;} 
        @AuraEnabled public String routeId {get; set;} 
        @AuraEnabled public String departurePointId {get; set;} 
        @AuraEnabled public String destinationPointId {get; set;} 
        @AuraEnabled public DateTime flightDateTime {get; set;} 
        @AuraEnabled public Integer quantity {get; set;}
        @AuraEnabled public List<PackageServicesWrapper> services {get; set;}
    }    

    public class FullCabinWrapper {
        @AuraEnabled public String productId {get; set;} 
        @AuraEnabled public String modeloId {get; set;} 
        @AuraEnabled public String departurePointId {get; set;} 
        @AuraEnabled public String destinationPointId {get; set;} 
        @AuraEnabled public DateTime flightDateTime {get; set;} 
        @AuraEnabled public List<PackageServicesWrapper> services {get; set;}
    }

    public class CharterWrapper {    
        @AuraEnabled public String productId {get; set;} 
        @AuraEnabled public String modeloId {get; set;} 
        @AuraEnabled public List<DestinoCharter> route { get; set; }
        @AuraEnabled public String aircraftModel {get; set;}
        @AuraEnabled public DateTime flightDateTime { get; set; }
        @AuraEnabled public List<PackageServicesWrapper> services {get; set;}
    }

    public class PackageServicesWrapper {
        @AuraEnabled public String productId {get; set;} 
        @AuraEnabled public Integer quantity {get; set;}
    }

    public class VooShuttleWrapper{
        @AuraEnabled 
        public DateTime dataVoo {get; set;}
        
        @AuraEnabled 
        public string produto {get; set;}
        
        @AuraEnabled 
        public string modeloId {get; set;}

        @AuraEnabled 
        public PesquisaMalha voo {get; set;}
    }

    public class VooCharterWrapper{
        @AuraEnabled 
        public DateTime dataHora {get; set;}
        
        @AuraEnabled 
        public string produto {get; set;}

        @AuraEnabled 
        public BlocoCharter voo {get; set;}
    }

    public class VooFullCabinWrapper{
        @AuraEnabled 
        public DateTime dataHora {get; set;}
        
        @AuraEnabled 
        public string produto {get; set;}
        
        @AuraEnabled 
        public string origem {get; set;}
        
        @AuraEnabled 
        public string destino {get; set;}

        @AuraEnabled 
        public BlocoFullCabin voo {get; set;}
    }
    
    public class DestinoCharter{
        @AuraEnabled
        public Integer sequencia {get; set;}

        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public Decimal latitude {get; set;}

        @AuraEnabled
        public Decimal longitude {get; set;}
    }
}