@RestResource(urlMapping='/revosite/v1/fullcabin/search')
global without sharing class RevoSiteFullCabinSearch {

    @HttpPost
    global static void search(FullCabinSearch param) {
        try {
            
            UsuarioSite__c usuario = null;
            
            if (param.webSiteUserId != null) {
                usuario = UsuarioSiteSelector.newInstance().encontraPeloIdUsuarioSite(param.webSiteUserId);

                if (usuario == null) {
                    throw new RevoSiteApi.UsuarioNaoEncontradoException(true);
                } 
            }

            IOpportunityService service = OpportunityService.service();

            List<PesquisaFullCabin> fullcabins = service.pesquisaFullCabinCliente(
                param.webSiteUserId != null ? usuario.Conta__c : null, param.departurePointId, param.destinationPointId, 
                param.flightDate.date(), param.promotionalCode
            );

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(mapping(fullcabins))
            );
        } catch (Exception e) {
            System.debug('Erro ao buscar full cabin: ' + e);
            RevoSiteApi.standardBadResult(e);
        }
    }

    public static List<FullCabinResults> mapping(List<PesquisaFullCabin> fullcabins) {

        List<FullCabinResults> results = new List<FullCabinResults>();

        for (PesquisaFullCabin fullCabin : fullcabins) {

            FullCabinResults result = new FullCabinResults();
        
            result.productId = fullCabin.produto;
            result.departurePointId = fullCabin.origem;
            result.destinationPointId = fullCabin.destino;
            result.departurePointName = fullCabin.localOrigem;
            result.destinationPointName = fullCabin.localdestino;
            result.aircraftModel = fullCabin.modelo;
            result.aircraftModelId = fullCabin.modeloId;
            result.aircraftModelImageUrl = fullCabin.modeloImagemUrl;
            result.passengerCapacity = fullCabin.capacidadePassageiros;
            result.missionTime = fullCabin.tempoMissao;
            result.timeSlots = mapping(fullCabin.horarios);

            results.add(result);
        }        
        
        return results;
    }

    private static List<TimeSlot> mapping(List<BlocoFullCabin> blocos) {
        List<TimeSlot> results = new List<TimeSlot>();

        for (BlocoFullCabin bloco : blocos) {

            if (bloco.invalido) {
                continue;
            }

            TimeSlot timeSlot = new TimeSlot();
        
            timeSlot.flightDateTime = bloco.data;
            timeSlot.availableAircrafts = bloco.aeronavesDisponiveis;
            timeSlot.unitPrice = bloco.precoUnitario;
            timeSlot.percDiscount = bloco.descontoPerc;
            timeSlot.valueDiscount = bloco.descontoValor;
            timeSlot.totalPrice = bloco.precoFinal;
            timeSlot.promotionalCode = bloco.codigoPromocionalApurado;
            timeSlot.validPromotion = bloco.promocaoValida;
            timeSlot.services =  mapping(bloco.servicos);

            results.add(timeSlot);
        }
        
        return results;
    }

    private static List<PackageServices> mapping(List<ServicoDoPacote> servicos) {

        List<PackageServices> results = new List<PackageServices>();
        
        for (ServicoDoPacote servico : servicos) {

            if (servico.invalido) {
                continue;
            }

            PackageServices packageService = new PackageServices();

            packageService.productId = servico.produto;
            packageService.serviceName = servico.servico;
            packageService.required = servico.obrigatorio;
            packageService.Bundled = servico.empacotado;
            packageService.selected = servico.selecionado;
            packageService.passengerQty = servico.porPassageiro;
            packageService.position = servico.posicao;
            packageService.defaultQuantity = servico.quantidadePadrao;
            packageService.unitPrice = servico.precoUnitario;
            packageService.quantity = servico.quantidade;
            packageService.percDiscount = servico.descontoPerc;
            packageService.valueDiscount = servico.descontoValor;
            packageService.totalPrice = servico.precoFinal;
            packageService.promotionalCode = servico.codigoPromocionalApurado;
            packageService.validPromotion = servico.promocaoValida;

            results.add(packageService);
        }     
        
        return results;
    }    

    global class FullCabinSearch {

        public String webSiteUserId { get; set; }
        public String departurePointId { get; set; }
        public String destinationPointId { get; set; }
        public DateTime flightDate { get; set; }
        public String promotionalCode { get; set; }

    }

    global class FullCabinResults {

        public String productId {get; set;} 
        public String departurePointId {get; set;} 
        public String destinationPointId {get; set;} 
        public String departurePointName {get; set;}
        public String destinationPointName {get; set;}
        public String aircraftModel {get; set;}
        public String aircraftModelId {get; set;}
        public String aircraftModelImageUrl {get; set;}
        public Integer passengerCapacity {get; set;}
        public Decimal missionTime {get; set;}
        public List<TimeSlot> timeSlots {get; set;}
    }

    global class TimeSlot {

        public DateTime flightDateTime {get; set;}
        public String flightTimeZone {get { return 'GMT-03:00'; } set;}
        public Integer availableAircrafts {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}    
        public String promotionalCode {get; set;}
        public Boolean validPromotion {get; set;}
        public List<PackageServices> services {get; set;}

    }    

    global class PackageServices {
        public String productId {get; set;} 
        public String serviceName {get; set;} 
        public Boolean required {get; set;}
        public Boolean Bundled {get; set;}
        public Boolean selected {get; set;}
        public Boolean passengerQty {get; set;}
        public Integer position {get; set;}
        public Integer defaultQuantity {get; set;}
        public Decimal unitPrice {get; set;}
        public Integer quantity {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}    
        public String promotionalCode {get; set;}
        public Boolean validPromotion {get; set;}
    }        
}