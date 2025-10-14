public without sharing class EventsSelector extends fflib_SObjectSelector implements IEventsSelector {
    static FINAL Id RECORD_TYPE_VOO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.VooRecordTypeName).getRecordTypeId();
    static FINAL Id RECORD_TYPE_MANUTENCAO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.ManutencaoRecordTypeName).getRecordTypeId();
    static FINAL Id RECORD_TYPE_ENTRE_VOOS_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.EntreVoosRecordTypeName).getRecordTypeId();
    static FINAL String user = 'User';
    static FINAL Datetime agora = System.now();
    static FINAL String alta = 'Alta';
    
    public List<Event> selectById(Set<Id> idSet)
    {
        return (List<Event>) selectSObjectsById(idSet);
    }
    
    public List<Event> retrieveEventsByVoosSetId(Set<Id> voosSetId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('WhatId in :voosSetId');
        
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    // Owner is Calendar
    public List<Event> selectEventsByOwnerPrefixName(Set<String> prefixs)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('OwnerName__c in :prefixs');
        
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectEventsByOwnerId(Set<Id> setId)
    {
        return selectEventsByOwnerId(setId, null, null);
    }
    
    public List<Event> selectEventsByOwnerId(Set<Id> setId, Datetime smallerDate, Datetime biggerDate)
    {
        List<String> conditions = new List<String>();
        if(setId != null) conditions.add('OwnerId in :setId');
        else throw new EventsException('Conjunto de Ids não pode ser nulo');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData)
    {
        fflib_QueryFactory query = newQueryFactory();
        String queryCondition = 'Owner.Type != :user AND OwnerName__c in :ownerNameSet AND EndDateTime >= :menorData AND StartDateTime <= :maiorData AND ';
        queryCondition += '( (RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID AND Urgencia__c = :alta) OR (RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID AND EndDateTime > :agora AND StartDateTime < :agora) OR ';
        queryCondition += 	'RecordTypeId = :RECORD_TYPE_VOO_EVENT_ID OR RecordTypeId = :RECORD_TYPE_ENTRE_VOOS_EVENT_ID)';
        query.setCondition(queryCondition);
        System.debug(query.toSOQL());
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectByOwnerNameOnAndAfterDate(Set<String> ownerNameSet, Datetime dataInicio)
    {
        Set<String> recordTypes = new Set<String>{'Indisponibilidade', 'Voo', 'Manutencao'};
        fflib_QueryFactory query = newQueryFactory();
        String queryCondition = 'Owner.Type != :user AND OwnerName__c in :ownerNameSet AND EndDateTime >= :dataInicio AND ';
        queryCondition += 'RecordType.DeveloperName IN :recordTypes';
        query.setCondition(queryCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectDesativacoesByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData)
    {
        Set<String> recordTypes = new Set<String>{'Indisponibilidade'};
        fflib_QueryFactory query = newQueryFactory();
        String queryCondition = 'Owner.Type != :user AND OwnerName__c in :ownerNameSet AND EndDateTime >= :menorData AND StartDateTime <= :maiorData AND ';
        queryCondition += 'RecordType.DeveloperName IN :recordTypes';
        query.setCondition(queryCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData, Set<Id> setVoosExclusos)
    {
        fflib_QueryFactory query = newQueryFactory();
        String queryCondition = 'Owner.Type != :user AND OwnerName__c in :ownerNameSet AND WhatId NOT IN :setVoosExclusos AND EndDateTime >= :menorData AND StartDateTime <= :maiorData AND ';
        queryCondition += '( (RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID AND Urgencia__c = :alta) OR (RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID AND EndDateTime > :agora AND StartDateTime < :agora) OR ';
        queryCondition += 	'RecordTypeId = :RECORD_TYPE_VOO_EVENT_ID OR RecordTypeId = :RECORD_TYPE_ENTRE_VOOS_EVENT_ID)';
        query.setCondition(queryCondition);
        System.debug(query.toSOQL());
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectManutencaoAltaEntreVooByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData)
    {
        fflib_QueryFactory query = newQueryFactory();
        String queryCondition = 'Owner.Type != :user AND OwnerName__c in :ownerNameSet AND EndDateTime >= :menorData AND StartDateTime <= :maiorData AND ';
        queryCondition += '( (RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID AND Urgencia__c = :alta) OR ';
        queryCondition += 	'RecordTypeId = :RECORD_TYPE_ENTRE_VOOS_EVENT_ID)';
        query.setCondition(queryCondition);
        query.setOrdering('StartDateTime', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Event>) Database.query(query.toSOQL());
    }
	
    public List<Event> selectManutencaoEventTypeByOwnerPrefixName(Set<String> prefixs)
    {
        return selectManutencaoEventTypeByOwnerPrefixNameWithCondition(prefixs, null, null);
    }
	
    public List<Event> selectManutencaoEventTypeByOwnerPrefixNameWithCondition(Set<String> prefixs, Datetime smallerDate, Datetime biggerDate)
    {
        List<String> conditions = new List<String>();
        if(prefixs != null) conditions.add(' OwnerName__c in :prefixs AND RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID ');
        else throw new EventsException('Prefixo não pode ser nulo');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        //System.debug('Query: ' + strCondition + '\nPrefixs: ' + prefixs + '\nRecord Type Id: ' + RECORD_TYPE_MANUTENCAO_EVENT_ID);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    // Owner is Calendar
    public List<Event> selectVooEventTypeByOwnerPrefixName(Set<String> prefixs)
    {
        return selectVooEventTypeByOwnerPrefixNameWithCondition(prefixs, null, null);
    }
    
    public List<Event> selectVooEventTypeByOwnerPrefixNameWithCondition(Set<String> prefixs, Datetime smallerDate, Datetime biggerDate)
    {
        List<String> conditions = new List<String>();
        if(prefixs != null) conditions.add(' OwnerName__c in :prefixs AND RecordTypeId = :RECORD_TYPE_VOO_EVENT_ID ');
        else throw new EventsException('Prefixo não pode ser nulo');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectVooEventTypeByWhatIds(Set<Id> whatIds) 
    {
        return selectVooEventTypeByWhatIds(whatIds, null, null);
    }
    
    public List<Event> selectVooEventTypeByWhatIds(Set<Id> whatIds, Datetime smallerDate, Datetime biggerDate)
    {        
        List<String> conditions = new List<String>();
        if(whatIds != null) conditions.add(' WhatId in :whatIds AND RecordTypeId = :RECORD_TYPE_VOO_EVENT_ID ');
        else throw new EventsException('WhatId não pode ser nulo');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectByEventDeveloperNameEventListByOwnerPrefixName(Set<String> prefixs, String recordTypeName, String tipo) {
        return selectByEventDeveloperNameEventListByOwnerPrefixName(prefixs, recordTypeName, tipo, null, null);
    }
    
    public List<Event> selectByEventDeveloperNameEventListByOwnerPrefixName
        (Set<String> prefixs, String recordTypeName, String tipo, Datetime smallerDate, Datetime biggerDate)
    {
        if(recordTypeName == null) throw new EventsException('recordTypeName não pode ser nulo');
        Id RECORD_TYPE_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        
        List<String> conditions = new List<String>();
        if(prefixs != null) conditions.add(' OwnerName__c in :prefixs AND RecordTypeId = :RECORD_TYPE_EVENT_ID ');
        else throw new EventsException('Prefixo não pode ser nulo');
        if(String.isNotBlank(tipo)) conditions.add(' Type = :tipo ');
        else throw new EventsException('Tipo não pode ser nulo');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectVooEventByRelatedVoo(Set<Id> voo)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('WhatId in :voo AND RecordTypeId = :RECORD_TYPE_VOO_EVENT_ID');
        
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public List<Event> selectEventsByOwnerNameOrWhatId(Set<String> prefixs, Set<String> whatids)
    {
        return selectEventsByOwnerNameOrWhatId(prefixs, whatids, null, null);
    }
    
    public List<Event> selectEventsByOwnerNameOrWhatId(Set<String> prefixs, Set<String> whatids, Datetime smallerDate, Datetime biggerDate)
    {
        List<String> conditions = new List<String>();
        if(prefixs != null && whatids != null) conditions.add(' (OwnerName__c in :prefixs or WhatId in :whatids) ');
        else throw new EventsException('Prefixo e Ids Relacionados não podem ser nulos');
        if(smallerDate != null) conditions.add(' StartDateTime >= :smallerDate ');
        if(biggerDate != null) conditions.add(' EndDateTime <= :biggerDate ');
        String strCondition = '';
        for(Integer i=0;i<conditions.size();i++)
        {
            strCondition += conditions[i] + (i < (conditions.size() - 1)? ' AND ' : '');
        }
        fflib_QueryFactory query = newQueryFactory();
       	query.setCondition(strCondition);
        return (List<Event>) Database.query(query.toSOQL());
    }

    public List<Event> selectManutencaoEventTypeByWhatIdsAndDates(List<String> whatIds, Datetime smallerDate, Datetime biggerDate)
    {        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('WhatId IN :whatids AND StartDateTime >=: smallerDate AND EndDateTime <=: biggerDate '
                            + 'AND Cancelado__c = false AND RecordTypeId = :RECORD_TYPE_MANUTENCAO_EVENT_ID');
        return (List<Event>) Database.query(query.toSOQL());
    }
    
    public static IEventsSelector newInstance()
	{
		return (IEventsSelector) Application.Selector.newInstance(Event.SObjectType);
	}
    
    public EventsSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);        
    }
    
    public EventsSelector()
    {
        super(true);
        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>{ SobjectType.Event.FieldSets.SelectFieldList };
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
        	Event.Id,
                Event.Subject,
                Event.OwnerId,
                Event.StartDateTime,
                Event.EndDateTime,
                Event.Location,
                Event.WhoId,
                Event.WhatId,
                Event.Type,
                Event.RecordTypeId,
                Event.Urgencia__c,
                Event.Cancelado__c,
                Event.OwnerName__c,
                Event.TempoCruzeiro__c,
                Event.TempoSolo__c,
                Event.TempoCorteCliente__c,
                Event.TransladoIda__c,
                Event.TransladoVolta__c,
                Event.DurationInMinutes,
                Event.Description
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Event.sObjectType;
    }
}