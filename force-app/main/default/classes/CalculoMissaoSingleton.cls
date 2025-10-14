public class CalculoMissaoSingleton 
{
    private static CalculoMissaoSingleton instance =null;
    public static CalculoMissaoSingleton getInstance()
    {
        if(instance == null) instance = new CalculoMissaoSingleton();
        return instance;
    }
    
    public Map<id, local__c> locais
    {
        get
        {
            if(this.locais == null) locais = new Map<id, local__c> ([SELECT Id, Name, Tipo__c, Coordenadas__Latitude__s, Coordenadas__Longitude__s, Coordenadas__c, 
                                              CodigoLocal__c, Categoria__c, Base__c, Status__c, CodigoICAO__c, CapacidadeMaxima__c, Abastecimento__c, RecordType.Name FROM Local__c where Coordenadas__Latitude__s <> null and Coordenadas__Longitude__s <> null]);
            return locais;
        }
        private set;
        
    }
    
    public Map<id, local__c> locaisCoordenadasAlteradas
    {
        get
        {
            if (locaisCoordenadasAlteradas==null)
            {
                this.locaisCoordenadasAlteradas = new Map<id, local__c>();
                return locaisCoordenadasAlteradas;
            }
            else return locaisCoordenadasAlteradas;
        }
        private set;
        
    }
    
    public Map<id,Aeronave__c> aeronaves
    {
        get
        {
            if(this.aeronaves == null) aeronaves = new Map<id,Aeronave__c>([SELECT Name, TipoOperacao__c, ModeloAeronave__c, BaseMae__c, VelocidadeCruzeiro__c, ConsumoHoraSolo__c, ConsumoHoraVoo__c, Tamanho__c, 
                                                    TipoCombustivel__c, CapacidadeTotalCombustivel__c, PesoBasicoOperacional__c, TempoSoloAterrissagem__c, TempoSoloDecolagem__c,
                                                    NumeroAssentos__c, Id, UnidadeMedida__c, AnoFabricacao__c, ModeloAeronave__r.Porte__c, PesoMaximoDecolagem__c, ModeloAeronave__r.Name FROM Aeronave__c]);
            return aeronaves;
        }
        private set;
        
    }
        
    public Map<id,Aerovia__c> aerovias
    {
        get
        {
            if(this.aerovias == null) aerovias = new Map<id,Aerovia__c>([SELECT Id, Name, Origem__c, Destino__c, Tipo__c FROM Aerovia__c]);
            return aerovias;
        }
        private set;
        
    }
    
    public Map<date,Map<string, IntervaloSol__c>> horariosSol
    {
        get
        {
            if(this.horariosSol ==null)
            {
                horariosSol = new Map<date,Map<string, IntervaloSol__c>>();
                List<IntervaloSol__c> intervalos = IntervalosSolSelector.newInstance().selectAllFuture();
                for(IntervaloSol__c intervalo :intervalos)
                {
                    if(horariosSol.containsKey(intervalo.date__c))
                    {
                        horariosSol.get(intervalo.date__c).put(intervalo.CodigoICAO__c, intervalo);
                    }
                    else
                    {
                        horariosSol.put(intervalo.date__c, new Map<string, IntervaloSol__c>{intervalo.CodigoICAO__c => intervalo});
                    }
                }
            }
            return horariosSol;
        }
        private set;
    }
    
    public Map<string, FlightLeg> calculatedRoute = new Map<string, FlightLeg>();
    

}