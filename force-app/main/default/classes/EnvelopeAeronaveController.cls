public with sharing class EnvelopeAeronaveController 
{
    ApexPages.StandardController sc;
    public List<GoogleChartData> envelopes {get;set;}
    public Map<object,object> fuelWeights {get;set;}
    public String braco
    {
        get {
            return System.Label.Braco;
        }
        set;
    }
    public String peso
    {
        get {
            return System.Label.PesoEnvelope;
        }
        set;
    }
    public String envelope
    {
        get {
            return System.Label.EnvelopeCG;
        }
        set;
    }
    public String passeio
    {
        get {
            return System.Label.PasseioCG;
        }
        set;
    }
    public String cgAtual
    {
        get {
            return System.Label.CGAtual;
        }
        set;
    }
    public String cgZeroComb
    {
        get {
            return System.Label.CGZeroComb;
        }
        set;
    }
    public EnvelopeAeronaveController() {}
    public EnvelopeAeronaveController(ApexPages.StandardController sc)
    { 
        this.sc = sc;
        String atualValue1Str = ApexPages.currentPage().getParameters().get('atualValue1');
        String atualValue2Str = ApexPages.currentPage().getParameters().get('atualValue2');
        String zeroValue1Str = ApexPages.currentPage().getParameters().get('zeroValue1');
        String zeroValue2Str = ApexPages.currentPage().getParameters().get('zeroValue2');
        
        Decimal atualValue1 = atualValue1Str == null || atualValue1Str == 'null' || atualValue1Str == 'undefined' ? null : Decimal.valueOf(atualValue1Str);
        Decimal atualValue2 = atualValue2Str == null || atualValue2Str == 'null' || atualValue2Str == 'undefined' ? null : Decimal.valueOf(atualValue2Str);
        Decimal zeroValue1 = zeroValue1Str == null || zeroValue1Str == 'null' || zeroValue1Str == 'undefined' ? null : Decimal.valueOf(zeroValue1Str);
        Decimal zeroValue2 = zeroValue2Str == null || zeroValue2Str == 'null' || zeroValue2Str == 'undefined' ? null : Decimal.valueOf(zeroValue2Str);
        
        this.envelopes = getEnvelopes(sc.getId());
        this.fuelWeights = getFuelWeights(atualValue1, atualValue2, zeroValue1, zeroValue2);
    }
    public List<GoogleChartData> getEnvelopes(Id aircraftId)
    {
        List<GoogleChartData> envelopesLst = new List<GoogleChartData>();
        List<EnvelopeAeronave__c> envelopes = EnvelopeDAO.getEnvelopeByAircraftId(aircraftId);
        for(EnvelopeAeronave__c envelope : envelopes)
        {
            envelopesLst.add(new GoogleChartData(envelope.balanceamento__c,envelope.Peso__c));
        }
        return envelopesLst;
    }
    public Map<Object,Object> getFuelWeights( Decimal atualValue1, Decimal atualValue2, Decimal zeroValue1, Decimal zeroValue2)
    {
        return (atualValue1 == null && atualValue2 == null && zeroValue1 == null && zeroValue2 == null) ? new Map<Object, Object>() : new Map<Object, Object>{
        'atual' => new GoogleChartData(atualValue2, atualValue1),
        'zero' => new GoogleChartData(zeroValue2, zeroValue1)
    };
    }
}