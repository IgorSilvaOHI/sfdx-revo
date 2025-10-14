@RestResource(urlMapping='/revosite/v1/shuttle/search')
global without sharing class RevoSiteShuttleSearch {

    @HttpPost
    global static void search(ShuttleSeatSearch param) {
        try {
            
            UsuarioSite__c usuario = null;
            
            if (param.webSiteUserId != null) {
                usuario = UsuarioSiteSelector.newInstance().encontraPeloIdUsuarioSite(param.webSiteUserId);

                if (usuario == null) {
                    throw new RevoSiteApi.UsuarioNaoEncontradoException(true);
                } 
            }

            IOpportunityService service = OpportunityService.service();

            List<PesquisaMalha> malhas = service.pesquisaMalhaVoosCliente(
                param.webSiteUserId != null ? usuario.Conta__c : null, param.departurePointId, param.destinationPointId, 
                param.quantity, param.flightDate, param.dateOffSet, param.promotionalCode
            );

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(mapping(malhas))
            );
        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    public static List<ShuttleSeatResults> mapping(List<PesquisaMalha> malhas) {

        List<ShuttleSeatResults> results = new List<ShuttleSeatResults>();

        for (PesquisaMalha malha : malhas) {

            if (malha.invalido) {
                continue;
            }

            ShuttleSeatResults result = new ShuttleSeatResults();

            result.departurePointId = malha.origem;
            result.destinationPointId = malha.destino;
            result.productId = malha.produto;
            result.routeId = malha.malhaId;
            result.departurePointName = malha.localOrigem;
            result.destinationPointName = malha.localdestino;
            result.aircraftModel = malha.modelo;
            result.aircraftModelId = malha.modeloId;
            result.aircraftModelImageUrl = malha.modeloImagemUrl;
            result.passengerCapacity = malha.capacidadePassageiros;
            result.missionTime = malha.tempoMissao;
            result.flightDateTime = malha.dataHora;
            result.availableSeats = malha.assentosDisponiveis;
            result.unitPrice = malha.precoUnitario;
            result.quantity = malha.quantidade;
            result.percDiscount = malha.descontoPerc;
            result.valueDiscount = malha.descontoValor;
            result.totalPrice = malha.precoFinal;
            result.promotionalCode = malha.codigoPromocionalApurado;
            result.validPromotion = malha.promocaoValida;
            result.promotionalId = malha.idPromocional;
            result.services = mapping(malha.servicos);

            results.add(result);
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

    global class ShuttleSeatSearch {

        public String webSiteUserId { get; set; }
        public String departurePointId { get; set; }
        public String destinationPointId { get; set; }
        public Integer quantity { get; set; }
        public Date flightDate { get; set; }
        public Integer dateOffSet { get; set; }
        public String promotionalCode { get; set; }

    }

    global class ShuttleSeatResults {
        public String productId {get; set;} 
        public String routeId {get; set;} 
        public String departurePointId {get; set;} 
        public String destinationPointId {get; set;} 
        public String departurePointName {get; set;}
        public String destinationPointName {get; set;}
        public String aircraftModelId {get; set;}
        public String aircraftModel {get; set;}
        public String aircraftModelImageUrl {get; set;}
        public Integer passengerCapacity {get; set;}
        public Decimal missionTime {get; set;}
        public DateTime flightDateTime {get; set;} 
        public String flightTimeZone {get { return 'GMT-03:00'; } set;}
        public Integer availableSeats {get; set;}
        public Decimal unitPrice {get; set;}
        public Integer quantity {get; set;}
        public Decimal percDiscount {get; set;}
        public Decimal valueDiscount {get; set;}
        public Decimal totalPrice {get; set;}    
        public String promotionalCode {get; set;}
        public Boolean validPromotion {get; set;}
        public String promotionalId {get; set;}
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