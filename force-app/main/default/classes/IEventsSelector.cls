public interface IEventsSelector extends fflib_ISObjectSelector
{
    List<Schema.SObjectField> getSObjectFieldList();
    Schema.SObjectType getSObjectType();
    List<Event> selectById(Set<Id> idSet);
    List<Event> retrieveEventsByVoosSetId(Set<Id> voosSetId);
    
    List<Event> selectEventsByOwnerPrefixName(Set<String> prefix);
    List<Event> selectEventsByOwnerId(Set<Id> setId);
    List<Event> selectEventsByOwnerId(Set<Id> setId, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectManutencaoEventTypeByOwnerPrefixName(Set<String> prefixs);
    List<Event> selectManutencaoEventTypeByOwnerPrefixNameWithCondition(Set<String> prefixs, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectVooEventTypeByOwnerPrefixName(Set<String> prefixs);
    List<Event> selectVooEventTypeByOwnerPrefixNameWithCondition(Set<String> prefixs, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectManutencaoAltaEntreVooByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData);
    
    List<Event> selectVooEventTypeByWhatIds(Set<Id> whatIds);
    List<Event> selectVooEventTypeByWhatIds(Set<Id> whatIds, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectByEventDeveloperNameEventListByOwnerPrefixName(Set<String> prefixs, String recordTypeName, String tipo);
    List<Event> selectByEventDeveloperNameEventListByOwnerPrefixName(Set<String> prefixs, String recordTypeName, String tipo, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectVooEventByRelatedVoo(Set<Id> voo);
    List<Event> selectByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData);
    List<Event> selectByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData, Set<Id> setVoosExclusos);
    
    List<Event> selectEventsByOwnerNameOrWhatId(Set<String> prefixs, Set<String> whatids);
    List<Event> selectEventsByOwnerNameOrWhatId(Set<String> prefixs, Set<String> whatids, Datetime smallerDate, Datetime biggerDate);
    
    List<Event> selectDesativacoesByOwnerNameInDateRange(Set<String> ownerNameSet, Datetime menorData, Datetime maiorData);
    List<Event> selectByOwnerNameOnAndAfterDate(Set<String> ownerNameSet, Datetime dataInicio);
    List<Event> selectManutencaoEventTypeByWhatIdsAndDates(List<String> whatIds, Datetime smallerDate, Datetime biggerDate);
    
}