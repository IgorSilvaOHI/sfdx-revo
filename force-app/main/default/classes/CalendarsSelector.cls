public without sharing class CalendarsSelector extends fflib_SObjectSelector implements ICalendarsSelector
{    
    public static ICalendarsSelector newInstance()
	{
		return (ICalendarsSelector) Application.Selector.newInstance(Calendar.SObjectType);
	}
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Calendar.Id,
            Calendar.Name
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Calendar.SObjectType;
    }
    
    /* fflib não tem permissão de acesso para recuperar registros do objeto Calendar
     * 
    public List<Calendar> selectById(Set<ID> idSet) {
        return (List<Calendar>) selectSObjectsById(idSet);
    }
    
    public List<Calendar> selectWithEventsByPrefix(Set<String> prefixs)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name in :prefixs');
        
        return (List<Calendar>) Database.query(query.toSOQL());
    }*/
    
    public List<Calendar> selectCalendarsByPrefixsSetName(Set<String> prefixs)
    {
        return [SELECT Id, Name FROM Calendar WHERE Name IN :prefixs AND IsActive = true];
    }
}