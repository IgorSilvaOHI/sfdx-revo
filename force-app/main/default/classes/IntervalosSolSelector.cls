public without sharing class IntervalosSolSelector extends fflib_SObjectSelector implements IIntervalosSolSelector
{
    public static IIntervalosSolSelector newInstance()
	{
		return (IIntervalosSolSelector) Application.Selector.newInstance(IntervaloSol__c.SObjectType);
	}
    
    public IntervalosSolSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public IntervalosSolSelector()
    {
        super(true);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
            IntervaloSol__c.Date__c,
            IntervaloSol__c.Sunrise__c,
            IntervaloSol__c.Sunset__c,
            IntervaloSol__c.WeekDay__c,
            IntervaloSol__c.Aero__c,
            IntervaloSol__c.CodigoICAO__c
		};
	}
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.IntervaloSol__c.FieldSets.Intervalo	};
    }
    
    public Schema.SObjectType getSObjectType()
	{
		return IntervaloSol__c.sObjectType;
	}

    public List<IntervaloSol__c> selectById(Set<ID> idSet)
	{
		return (List<IntervaloSol__c>) selectSObjectsById(idSet);
	}
    
    public List<IntervaloSol__c> selectByCodigoICAOAndDate(Set<String> codigoICAOSet, Date data)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('CodigoICAO__c in :codigoICAOSet AND Date__c = :data');
        return (List<IntervaloSol__c>) Database.query(query.toSOQL());
    }
    
    public List<IntervaloSol__c> selectAllFuture()
    {
        fflib_QueryFactory query = newQueryFactory();
        Date data = Date.today();
        query.setCondition('Date__c >= :data');
        return (List<IntervaloSol__c>) Database.query(query.toSOQL());
    }
}