@RestResource(urlMapping='/revosite/v1/charter/search')
global without sharing class RevoSiteCharterSearch {

    @HttpPost
    global static void search(CharterSearch param) {
        try {
            
            UsuarioSite__c usuario = null;
            
            if (param.webSiteUserId != null) {
                usuario = UsuarioSiteSelector.newInstance().encontraPeloIdUsuarioSite(param.webSiteUserId);

                if (usuario == null) {
                    throw new RevoSiteApi.UsuarioNaoEncontradoException(true);
                } 
            }
            
            List<Local__c> locais = parse(param.route);

            IOpportunityService service = OpportunityService.service();

            List<PesquisaCharter> charters = service.pesquisaChartCliente( 
                locais, param.flightDate.date(),
                param.webSiteUserId != null ? usuario.Conta__c : null, param.promotionalCode
            );

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(mapping(charters))
            );
        } catch (Exception e) {
            System.debug('Erro ao buscar charter: ' + e);
            RevoSiteApi.standardBadResult(e);
        }
    }

    public static List<Local__c> parse(List<LocalOportunidade__c> route) {
        List<LocalCharter> newRoute = new List<LocalCharter>();

        for (LocalOportunidade__c chart : route) {
            LocalCharter local = new LocalCharter();
            local.sequence = chart.Sequencia__c.intValue();
            local.wayPointId = chart.Local__c;
            local.latitude = chart.Coordenadas__Latitude__s;
            local.longitude = chart.Coordenadas__Longitude__s;

            newRoute.add(local);
        }

        return parse(newRoute);
    }

    public static List<Local__c> parse(List<LocalCharter> route) {
        Set<Id> locaisId = new Set<Id>();

        for (LocalCharter chart : route) {
            
            if (chart.wayPointId == null) {
                continue;
            }

            locaisId.add(chart.wayPointId);
        }

        Map<Id, Local__c> trajetos = new Map<Id, Local__c> (LocaisSelector.newInstance().selectById(locaisId));

        List<Local__c> locais = new List<Local__c>();

        route.sort();

        RecordType recordTypeLocal = LocalRecordType();

        for (LocalCharter chart : route) {

            Local__c novoLocal = new Local__c();

            if (chart.wayPointId != null) {

                if (trajetos.containsKey(chart.wayPointId)) {
                    novoLocal = trajetos.get(chart.wayPointId);
                } else {
                    throw new LocalNaoEncontradoException(true);
                }
            } else {
                novoLocal.Id = getFakeId(Local__c.SObjectType);
                novoLocal.Coordenadas__Latitude__s = chart.latitude;
                novoLocal.Coordenadas__Longitude__s = chart.longitude;
                novoLocal.CodigoLocal__c = 'ZZZ' + String.valueOf(s_num);
                novoLocal.Name = novoLocal.CodigoLocal__c;
                novoLocal.Base__c = false;
                novoLocal.Tipo__c = 'Onshore';
                novoLocal.RecordType = recordTypeLocal;
                novoLocal.RecordTypeId = novoLocal.RecordType.Id;
                novoLocal.Status__c = 'Pendente';
            }

            locais.add(novoLocal);
        }    
        
        return locais;
    }

    private static Integer s_num = 9999999;

    private static String getFakeId(Schema.SObjectType sot)
    {
        String result = String.valueOf(s_num++);
        return sot.getDescribe().getKeyPrefix() +
            '0'.repeat(12-result.length()) + result;
    }

    private static RecordType LocalRecordType() {
        return [Select Id, Name, DeveloperName From RecordType Where SobjectType = 'Local__c' And DeveloperName = 'Padrao' LIMIT 1];
    }      

    public static List<CharterResults> mapping(List<PesquisaCharter> charters) {

        List<CharterResults> results = new List<CharterResults>();

        for (PesquisaCharter charter : charters) {

            CharterResults result = new CharterResults();
        
            result.productId = charter.produto;
            result.departurePointId = charter.origem;
            result.departurePointName = charter.localOrigem;
            result.aircraftModel = charter.modelo;
            result.aircraftModelId = charter.modeloId;
            result.aircraftModelImageUrl = charter.modeloImagemUrl;
            result.passengerCapacity = charter.capacidadePassageiros;
            result.missionTime = charter.tempoMissao;
            result.timeSlots = mapping(charter.horarios);

            results.add(result);
        }        
        
        return results;
    }

    private static List<TimeSlot> mapping(List<BlocoCharter> blocos) {
        List<TimeSlot> results = new List<TimeSlot>();

        for (BlocoCharter bloco : blocos) {

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

    global class CharterSearch {

        public String webSiteUserId { get; set; }
        public List<LocalCharter> route { get; set; }
        public DateTime flightDate { get; set; }
        public String promotionalCode { get; set; }
        
    }

    global class LocalCharter implements Comparable {

        public Integer sequence { get; set; } 
        public String wayPointId { get; set; }
        public Double latitude { get; set; }
        public Double longitude { get; set; }

        public Integer compareTo(Object other) {
            LocalCharter outro = (LocalCharter)other;
            if (this.sequence == outro.sequence) {
                return 0; 
            }
            return this.sequence > outro.sequence ? 1 : -1;
        }
    }

    global class CharterResults {

        public String productId {get; set;} 
        public String departurePointId {get; set;} 
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

    public class LocalNaoEncontradoException extends RevoSiteApi.RevoSiteApiException {
        public LocalNaoEncontradoException(Boolean voidParam) {
            super('API-0002','Local Não Encontrado!');
        }
    }    
}