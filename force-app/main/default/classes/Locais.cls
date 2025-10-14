public without sharing class Locais extends fflib_SObjectDomain implements ILocais
{    
    private static FINAL String VALIDADO = 'Validado';
    public static FINAL Double DIVISOR = 1.852; //Converte para Milhas Náuticas
    public static FINAL Double RAIOCONSIDERADO = ConfiguracoesIntegracaoSkyTrac__c.getOrgDefaults().RaioConsiderado__c; //EM MILHAS NÁUTICAS
    
    public Locais(List<Local__c> sObjectList)
    {
        super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Locais(sObjectList);
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        Set<Id> locaisIds = Trigger.newMap.keySet();          
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        for(Local__c local : (List<Local__c>)records)
        {
            Local__c localAnt = (Local__c)existingRecords.get(local.Id);
            if (local.Coordenadas__Latitude__s  != localAnt.Coordenadas__Latitude__s ||
                local.Coordenadas__Longitude__s != localAnt.Coordenadas__Longitude__s )
            {
                ConversorGeolocation.LocalGraus localGrau = new ConversorGeolocation.LocalGraus();
                localGrau = ConversorGeolocation.convertLocalDecimalParaGrau(local.Coordenadas__Latitude__s, local.Coordenadas__Longitude__s);
                if (localGrau.latitude != null && localGrau.longitude != null)
                {
                    local.CoordenadasLatitudeDirecao__c = localGrau.latitude.direcao;
                    local.CoordenadasLatitudeGraus__c = localGrau.latitude.grau;
                    local.CoordenadasLatitudeMinutos__c = localGrau.latitude.minuto;
                    local.CoordenadasLatitudeSegundos__c = localGrau.latitude.segundo;
                    local.CoordenadasLongitudeDirecao__c = localGrau.longitude.direcao;
                    local.CoordenadasLongitudeGraus__c = localGrau.longitude.grau;
                    local.CoordenadasLongitudeMinutos__c = localGrau.longitude.minuto;
                    local.CoordenadasLongitudeSegundos__c = localGrau.longitude.segundo;
                }
            }
            else
            {
                ConversorGeolocation.LocalDecimais localdec = new ConversorGeolocation.LocalDecimais();
                localdec = ConversorGeolocation.convertLocalGrauParaDecimal(
                    new ConversorGeolocation.CoordenadaGraus( 
                    	(Integer)local.CoordenadasLatitudeGraus__c,
                    	(Integer)local.CoordenadasLatitudeMinutos__c,
                    	local.CoordenadasLatitudeSegundos__c,
                    	local.CoordenadasLatitudeDirecao__c), 
                    new ConversorGeolocation.CoordenadaGraus(
                    	(Integer)local.CoordenadasLongitudeGraus__c,
                    	(Integer)local.CoordenadasLongitudeMinutos__c,
                    	local.CoordenadasLongitudeSegundos__c,
                    	local.CoordenadasLongitudeDirecao__c));
                if(localdec.latitude != null && localdec.longitude != null)
                {
                    local.Coordenadas__Latitude__s = localdec.latitude;
                    local.Coordenadas__Longitude__s = localdec.longitude;
                }
            }
        }
    }
    
    public override void onBeforeInsert()
    {
        for(Local__c local : (List<Local__c>)records)
        {
            addError(inserindoCoordenadasDeAmbosTipos(local), local, System.Label.AmbosTiposCoordenada);          
            
            //Atualizando as coordenadas em branco com as preenchidas
            if (local.Coordenadas__Latitude__s  != null &&
                local.Coordenadas__Longitude__s != null)
            {
                ConversorGeolocation.LocalGraus localGrau = new ConversorGeolocation.LocalGraus();
                localGrau = ConversorGeolocation.convertLocalDecimalParaGrau(local.Coordenadas__Latitude__s, local.Coordenadas__Longitude__s);
                local.CoordenadasLatitudeDirecao__c = localGrau.latitude.direcao;
                local.CoordenadasLatitudeGraus__c = localGrau.latitude.grau;
                local.CoordenadasLatitudeMinutos__c = localGrau.latitude.minuto;
                local.CoordenadasLatitudeSegundos__c = localGrau.latitude.segundo;
                local.CoordenadasLongitudeDirecao__c = localGrau.longitude.direcao;
                local.CoordenadasLongitudeGraus__c = localGrau.longitude.grau;
                local.CoordenadasLongitudeMinutos__c = localGrau.longitude.minuto;
                local.CoordenadasLongitudeSegundos__c = localGrau.longitude.segundo;
            }
            else
            {
                ConversorGeolocation.LocalDecimais localdec = new ConversorGeolocation.LocalDecimais();
                localdec = ConversorGeolocation.convertLocalGrauParaDecimal(
                    new ConversorGeolocation.CoordenadaGraus( 
                        (Integer)local.CoordenadasLatitudeGraus__c,
                        (Integer)local.CoordenadasLatitudeMinutos__c,
                        local.CoordenadasLatitudeSegundos__c,
                        local.CoordenadasLatitudeDirecao__c), 
                    new ConversorGeolocation.CoordenadaGraus(
                        (Integer)local.CoordenadasLongitudeGraus__c,
                        (Integer)local.CoordenadasLongitudeMinutos__c,
                        local.CoordenadasLongitudeSegundos__c,
                        local.CoordenadasLongitudeDirecao__c));
                if(localdec.latitude != null && localdec.longitude != null)
                {
                    local.Coordenadas__Latitude__s = localdec.latitude;
                    local.Coordenadas__Longitude__s = localdec.longitude;
                }
        	}
        }
    }
    
    private Boolean inserindoCoordenadasDeAmbosTipos(Local__c local)
    {
        if ((local.Coordenadas__Latitude__s != null || local.Coordenadas__Longitude__s != null) &&
            (local.CoordenadasLatitudeDirecao__c != null ||
            local.CoordenadasLatitudeGraus__c != null ||
            local.CoordenadasLatitudeMinutos__c != null ||
            local.CoordenadasLatitudeSegundos__c != null ||
            local.CoordenadasLongitudeDirecao__c != null ||
            local.CoordenadasLongitudeGraus__c != null ||
            local.CoordenadasLongitudeMinutos__c != null ||
            local.CoordenadasLongitudeSegundos__c != null))
        {
            return true;
        }
        return false;
    }
    
    private void addError(Boolean errorCondition, Local__c local, String msgErro)
    {
        if (errorCondition) local.addError(msgErro);
    }
}