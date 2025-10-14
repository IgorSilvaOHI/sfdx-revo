public with sharing class Trechos extends fflib_SObjectDomain
implements ITrechos
{
    List<Trecho__c> trechos = new List<Trecho__c>();
    
    public static FINAL String OFFSHORE = 'Offshore';
    public static FINAL String NAOINICIADO = 'Não Iniciado';
    public static FINAL String CHECKINFECHADO = 'Check In Fechado';
    public static FINAL String EMROTA = 'Em Rota';
    public static FINAL String FINALIZADO = 'Finalizado';
    public static FINAL String TRANSLADO = 'Translado';
    Boolean primeiroTrechoRegistered = false;
    
    public static FINAL Set<Schema.SObjectField> FIELDS_IGNORE = new Set<Schema.SObjectField>{
        Trecho__c.AgendarAtraso__c,
        Trecho__c.SystemModstamp,
        Trecho__c.LastModifiedDate,
        Trecho__c.TempoSolo__c,
        Trecho__c.TempoCruzeiro__c,
        Trecho__c.TempoMissao__c,
        Trecho__c.TempoDecorrido__c,
        Trecho__c.PrevisaoDecolagem__c,
        Trecho__c.DisponibilidadePeso__c,
        Trecho__c.DataAtualizacaoAtraso__c,
        Trecho__c.DataAtrasoDecolagem__c,
        Trecho__c.TrechoAnterior__c,
        Trecho__c.PousoTrechoAnterior__c,
        Trecho__c.TipoHoraFaturamento__c,
        Trecho__c.PrimeiroTrechoFixo__c
    };
    
    public Trechos(List<Trecho__c> sObjectList)
    {
        super(sObjectList);

        Configuration.disableTriggerCRUDSecurity();
    }
    
    public static ITrechos newInstance(List<Trecho__c> sObjectList)
    {
        return (ITrechos) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Trechos(sObjectList);
        }
    }
    
    public List<Local__c> getTrajeto()
    {
        List<Local__c> trajeto = new List<Local__c>();
        List<Trecho__c> trechos = (List<Trecho__c>)records;
        
        if(trechos != null && trechos.size() > 0){
            Integer i = 0;
            Local__c local = new Local__c(Id=trechos.get(i).Origem__c);
            if (trechos.get(i).CoordenadasOrigemAlteracao__c)
            {
                local.Coordenadas__Latitude__s = trechos.get(i).CoordenadasLatitudeOrigemDecimal__c;
                local.Coordenadas__Longitude__s = trechos.get(i).CoordenadasLongitudeOrigemDecimal__c;
            }
            trajeto.add(local);
            do
            { 
                local = new Local__c(Id=trechos.get(i).Destino__c);
                if (trechos.get(i).CoordenadasDestinoAlteracao__c)
                {
                    local.Coordenadas__Latitude__s = trechos.get(i).CoordenadasLatitudeDestinoDecimal__c;
                    local.Coordenadas__Longitude__s = trechos.get(i).CoordenadasLongitudeDestinoDecimal__c;
                }
                trajeto.add(local);            
                i++;
            }
            while (i < trechos.size());
        }
        
        return trajeto;        
    } 
    
    public override void onAfterInsert()
    {       
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Voo__c> voos = VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(records, 'Voo__c'));
        
        Map<Id, Voo__c> voosMap = new Map<Id, Voo__c>(voos);
        Map<Id, Voo__c> voosEditados = new Map<Id, Voo__c>();
        Set<Id> voosId = new Set<Id>();
        
        for (Voo__c voo : voos)
        {
            voosId.add(voo.Id);
        }
        if(!System.isBatch() && !System.isFuture())
        {
            atualizaTempoVoado(voosId);
        }
        //geraRotaEmVoo(uow, new Map<Id,SObject>(), voosMap, voosEditados);
        //uow.registerDirty(voosEditados.values());
        //uow.commitWork();
        //integraStar();
    }
    
    
    public override void onAfterDelete()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Voo__c> voos = VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(records, 'Voo__c'));
        Map<Id, Voo__c> voosMap = new Map<Id, Voo__c>(voos);
        Map<Id, Voo__c> voosEditados = new Map<Id, Voo__c>();
        Set<Id> voosId = new Set<Id>();

        for (Voo__c voo : voos)
        {
            voosId.add(voo.Id);
        }
        if(!System.isBatch() && !System.isFuture())
        {
            atualizaTempoVoado(voosId);
       }
    }
    
    public Boolean ignorarTriggerUpdate()
    {
        SObjectType accountType = Schema.getGlobalDescribe().get('Trecho__c');
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            Trecho__c novoTrecho = (Trecho__c)Trigger.new[i];
            Trecho__c oldTrecho = (Trecho__c)Trigger.old[i];
            for(String key : mfields.keyset())
            {
                Schema.SObjectField field = mfields.get(key);
                if(novoTrecho.get(field) != oldTrecho.get(Field) && !FIELDS_IGNORE.contains(field))
                {
                    return false;
                }
            }
        }
        return true;
    }
    @future
    public static void atualizaTempoVoado (Set<Id> voosId){
        Try{    
            Map<Id, Voo__c> vooToUpdate = new Map<Id, Voo__c>();
                                 
            for (AggregateResult result : [SELECT Voo__c, SUM(TempoVoado__c) total 
                                            FROM Trecho__c 
                                            WHERE Voo__c = :voosId 
                                            GROUP BY Voo__c]) {                  
                    Id vooId = (Id)result.get('Voo__c');
                    Decimal totalHorasVoadas = (Decimal)result.get('total');                    
                    if(vooToUpdate.containsKey(vooId)) {
                        vooToUpdate.get(vooId).TotalHorasVoadas__c = totalHorasVoadas; 
                    }else{
                        vooToUpdate.put(vooId, new Voo__c(Id=vooId, TotalHorasVoadas__c=totalHorasVoadas));
                    }
                }                
                if (!vooToUpdate.isEmpty()) {
                    update vooToUpdate.values();
                }            
            }
        Catch (Exception e){
            System.debug('Erro inesperado' + e.getMessage());
            throw new TrechosException('Erro inesperado' + e.getMessage());
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        integrarSigTripEOOS(existingRecords, records);
        if(!ignorarTriggerUpdate())
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();        
            List<Voo__c> voos = VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(existingRecords.values(), 'Voo__c'));
            Map<Id, Voo__c> voosMap = new Map<Id, Voo__c>(voos);
            Map<Id, Voo__c> voosEditados = new Map<Id, Voo__c>();
                     
            Set<Id> voosId = Utils.getSetIds(existingRecords.values(), 'Voo__c');
            if(!System.isBatch() && !System.isFuture())
            {
                atualizaTempoVoado(voosId);
            }
            
            //geraRotaEmVoo(uow, existingRecords, voosMap, voosEditados);
            //uow.registerDirty(voosEditados.values());
            //uow.commitWork();
            
        }
    }
    
    private Trecho__c updateTrecho(Trecho__c trecho, LogVoo__c log, Schema.SObjectField field)
    {
        Object value = getValueByField(field, log, trecho);
        //Caso retorne valor, passou nas validações e seta no trecho
        if (value != null)
        {
            trecho.put(field, value);
            return trecho;
        }  
        return null;
    }
    
    @testVisible
    private Boolean existsFieldAndValueIsBlankOrNull(Trecho__c trecho, Schema.SObjectField field)
    {
        //se existe regra para esse tipo de log e o valor nesse campo do trecho está vazio
        return field != null && trecho.get(field) == null;
    }
    

    //TODO: Renato, dá pra criar uma factory aqui e fazer algo do tipo
    //Factory.newInstance(field).checkCoordenadas
    //Sem tempo de fazer isso agora... vai ficar assim mesmo
    @testVisible
    private Object getValueByField(Schema.SObjectField field, LogVoo__c log, Trecho__c trecho)
    {
        Decimal latitude;
        Decimal longitude;
        //Se for decolagem
        if (field == Trecho__c.Decolagem__c 
            || field == Trecho__c.Ligado__c)
        {
            //Utiliza coordenadas de origem pra saber se bate
            latitude = trecho.CoordenadasLatitudeOrigemDecimal__c;
            longitude = trecho.CoordenadasLongitudeOrigemDecimal__c;
        }        
        //Se for pouso
        else if (field == Trecho__c.Pouso__c 
                 || field == Trecho__c.Cut__c)
        {
            //Utiliza coordenadas de destino pra saber se bate
            latitude = trecho.CoordenadasLatitudeDestinoDecimal__c;
            longitude = trecho.CoordenadasLongitudeDestinoDecimal__c;
        }
        
        return 
            checkCoordenadas(log.Latitude__c, log.Longitude__c, latitude, longitude) ?
            log.PosnTimeDatetime__c : null;
    } 
    

    //Função que verifica se o raio entre o local analisado e o ponto do log é próximo o suficiente para ser considerado
    @testVisible
    private Boolean checkCoordenadas(Decimal latitude, Decimal longitude, Decimal latitude2, Decimal longitude2)
    {
        Location loc = Location.newInstance(latitude, longitude);
        Location loc2 = Location.newInstance(latitude2, longitude2);
        
        return raioConsiderado(loc, loc2);
    } 

    @testVisible
    private Boolean raioConsiderado(Location loc, Location loc2)
    {
        if (loc.latitude == null || loc.longitude == null || loc2.latitude == null || loc2.longitude == null)
        {
            return false;
        }
        
        Double raioLogTrecho = Location.getDistance(loc, loc2, 'km') / Locais.DIVISOR;
        return raioLogTrecho <= Locais.RAIOCONSIDERADO;
    }
    
    
    public override void onBeforeInsert()
    {
        Map<Id, Local__c> mapOrigens = new Map<Id, Local__c>(LocaisSelector.newInstance().selectById(Utils.getSetIds(records, 'Origem__c')));
        handleOnBeforeInsert(mapOrigens);
    }
    
    public override void onBeforeUpdate(Map<Id, sObject> existingRecords)
    {
        SObjectType trechoType = Schema.getGlobalDescribe().get('Trecho__c');
        Map<String,Schema.SObjectField> mfields = trechoType.getDescribe().fields.getMap();        
        List<Voo__c> voosList = VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(existingRecords.values(), 'Voo__c'));
        for(Voo__c voo: voosList)
        {
            for(Integer i = 0; i < voo.Trechos__r.size(); i++)    
            {
                Trecho__c trechoSelect = voo.Trechos__r[i];
                system.debug('entrou update');
                if(Trigger.newMap.containsKey(trechoSelect.Id))
                {
                    Trecho__c trechoUpdate = (Trecho__c)Trigger.newMap.get(trechoSelect.Id);
                    Trecho__c trechoAntigo = (Trecho__c)Trigger.oldMap.get(trechoSelect.Id);
                    if((trechoUpdate.Cut__c != null && trechoUpdate.Pouso__c == null  && trechoUpdate.Decolagem__c != null) || trechoUpdate.Pouso__c > trechoUpdate.Cut__c)
                    {
                        trechoUpdate.Cut__c = null;
                    }
                    if(i > 0 && trechoUpdate.Ligado__c != null && trechoUpdate.Ligado__c != trechoAntigo.Ligado__c)
                    {
                        Trecho__c trechoAnterior = voo.Trechos__r[i-1];
                        if(Trigger.newMap.containsKey(trechoAnterior.Id))
                        {
                            trechoAnterior = (Trecho__c) Trigger.newMap.get(trechoAnterior.Id);
                        }
                        if(trechoAnterior.Cut__c == null || trechoAnterior.Cut__c > trechoUpdate.Ligado__c)
                        {
                            trechoUpdate.Ligado__c = null;
                        }
                    }
                }                
            }
        }
        
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            Trecho__c novoTrecho = (Trecho__c)Trigger.new[i];
            Trecho__c trechoAntigo = (Trecho__c)Trigger.old[i];
            for(String key : mfields.keyset())
            {
                Schema.SObjectField field = mfields.get(key);
                if(field == Trecho__c.PrevisaoDecolagem__c && novoTrecho.get(field) != trechoAntigo.get(Field)){
                    novoTrecho.AgendarAtraso__c = !novoTrecho.AgendarAtraso__c;
                }
                if(field == Trecho__c.Origem__c && novoTrecho.get(field) != trechoAntigo.get(Field))
                {
                    Map<Id, Local__c> mapOrigens = new Map<Id, Local__c>(LocaisSelector.newInstance().selectById(Utils.getSetIds(records, 'Origem__c')));
                    handleOnBeforeUpdate(mapOrigens, existingRecords);
                }
                if(field == Trecho__c.Status__c && novoTrecho.get(field) != trechoAntigo.get(Field) && deveVoltarStatus(novoTrecho, trechoAntigo))
                {
                    novoTrecho.Status__c = trechoAntigo.Status__c;
                }                
            }
            //Solicitação de não gravar segundos em trecho
            novoTrecho.Ligado__c = novoTrecho.Ligado__c != null? novoTrecho.Ligado__c.addSeconds(-1*novoTrecho.Ligado__c.second()) : null;
            novoTrecho.Decolagem__c = novoTrecho.Decolagem__c != null? novoTrecho.Decolagem__c.addSeconds(-1*novoTrecho.Decolagem__c.second()) : null;
            novoTrecho.Pouso__c = novoTrecho.Pouso__c != null? novoTrecho.Pouso__c.addSeconds(-1*novoTrecho.Pouso__c.second()) : null;
            novoTrecho.Cut__c = novoTrecho.Cut__c != null? novoTrecho.Cut__c.addSeconds(-1*novoTrecho.Cut__c.second()) : null;
            
        }
       
    }
    
    
    private Boolean deveVoltarStatus(Trecho__c novoTrecho, Trecho__c trechoAntigo)
    {
        Boolean finalizadoParaEmRota = novoTrecho.Status__c == EMROTA && trechoAntigo.Status__c == FINALIZADO;
        Boolean finalizadoParaCheckIn = novoTrecho.Status__c == CHECKINFECHADO && trechoAntigo.Status__c == FINALIZADO;
        Boolean emRotaParaCheckIn = novoTrecho.Status__c == CHECKINFECHADO && trechoAntigo.Status__c == EMROTA;
        return finalizadoParaEmRota || finalizadoParaCheckIn || emRotaParaCheckIn;
    }
    
    private void handleOnBeforeUpdate(Map<Id, Local__c> mapOrigens, Map<Id, sObject> existingRecords)
    {
        for (Trecho__c trecho : (List<Trecho__c>)records)
        {
            Trecho__c oldTrecho = (Trecho__c)existingRecords.get(trecho.Id);
            if (!trecho.Origem__c.equals(oldTrecho.Origem__c))
            {
                trecho.Offshore__c = isOffshore(mapOrigens.get(trecho.Origem__c));
                if (trecho.Offshore__c == null)
                {
                    //TODO: Renato e Fernando: Setar erro bonitinho
                    trecho.Origem__c.addError('Origem inexistente');
                }                  
            }
        }
    }
    
    @testVisible
    private Boolean isOffshore(Local__c local)
    {
        if (local == null)
        {
            return null;
        }
        
        return local.Tipo__c.equals(OFFSHORE);
    }
    
    private void handleOnBeforeInsert(Map<Id, Local__c> mapOrigens)
    {
        Map<Id,Voo__c> mapVoos = new Map<Id,Voo__c>(VoosSelector.newInstance().selectById(Utils.getSetIds(records, 'Voo__c')));
        for (Trecho__c trecho : (List<Trecho__c>)records)
        {
            trecho.Offshore__c = isOffshore(mapOrigens.get(trecho.Origem__c));
            if (trecho.Offshore__c == null)
            {
                //TODO: Renato e Fernando: Setar erro bonitinho
                trecho.Origem__c.addError('Origem inexistente');
            }
            //Solicitação de não gravar segundos em trecho
            trecho.Ligado__c = trecho.Ligado__c != null? trecho.Ligado__c.addSeconds(-1*trecho.Ligado__c.second()) : null;
            trecho.Decolagem__c = trecho.Decolagem__c != null? trecho.Decolagem__c.addSeconds(-1*trecho.Decolagem__c.second()) : null;
            trecho.Pouso__c = trecho.Pouso__c != null? trecho.Pouso__c.addSeconds(-1*trecho.Pouso__c.second()) : null;
            trecho.Cut__c = trecho.Cut__c != null? trecho.Cut__c.addSeconds(-1*trecho.Cut__c.second()) : null;
            gerenciarTipo(trecho, mapVoos);
        }
    }
    private void integrarSigTripEOOS(Map<Id,SObject> trechosOld, List<Trecho__c> trechos){

        System.debug('>>>>entrou em Trechos.integrarSigTripEOOS');
        Set<Id> voosIds = new Set<Id>();
        Set<Id> voosIdsOOS = new Set<Id>();
        for(Trecho__c trecho:trechos) { 
            Trecho__c trechoOld = (Trecho__c) trechosOld.get(trecho.Id);
            if((!URL.getCurrentRequestUrl().getPath().toLowerCase().contains('/services/data/v')
                || System.Test.isRunningTest())
                    && trecho.IdExternoSigTrip__c <> null
                    && trechoOld.IdExternoSigTrip__c == trecho.IdExternoSigTrip__c
                    && (trechoOld.Ligado__c <> trecho.Ligado__c 
                        || trechoOld.Decolagem__c <> trecho.Decolagem__c
                        || trechoOld.Pouso__c <> trecho.Pouso__c
                        || trechoOld.Cut__c <> trecho.Cut__c                  
                        )
                    ) {                                     
                    if(trecho.processandoSIG__c){
                        Map<String, Object> params = new Map<String, Object>();
                        params.put('vooId', trecho.Voo__c);
                        //Flow.Interview.AguardarSIG myFlow = new Flow.Interview.AguardarSIG(params);
                        //myFlow.start(); TODO, NÃO IMPORTADO O FLOW NA REVO
                        system.debug('AguardarSIG startado');
                    }else{
                        voosIds.add(trecho.Voo__c);
                    }
                }

                if ( trecho.IdExternoOOSVoo__c <> null
                    && trechoOld.IdExternoOOSVoo__c == trecho.IdExternoOOSVoo__c
                    && (
                        trechoOld.Ligado__c <> trecho.Ligado__c 
                        || trechoOld.Decolagem__c <> trecho.Decolagem__c
                        || trechoOld.Pouso__c <> trecho.Pouso__c
                        || trechoOld.Cut__c <> trecho.Cut__c
                        )
                    ) {
                    voosIdsOOS.add(trecho.Voo__c);
              }
        }
        //if(voosIds.size() > 0) System.enqueueJob(new SigtripIntegrarVooOriginSF(voosIds));
        //if(voosIdsOOS.size() > 0) System.enqueueJob(new OOSIntegrarVooOriginSF(voosIdsOOS));  
    }

    private void gerenciarTipo(Trecho__c trecho, Map<Id,Voo__c> mapVoos)
    {
        system.debug('trecho.Tipo__c: ' + trecho.Tipo__c);
        system.debug('mapVoos.get(trecho.Voo__c)?.Tipo__c: ' + mapVoos.get(trecho.Voo__c)?.Tipo__c);
        if(trecho.Tipo__c == null)
        {
            trecho.Tipo__c = mapVoos.get(trecho.Voo__c)?.Tipo__c;
        }
    }
    
    private class TrechosException extends Exception {}
    
    
}