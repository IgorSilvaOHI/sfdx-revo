public class MissoesSelector extends fflib_SObjectSelector implements IMissoesSelector {
    public static IMissoesSelector newInstance()
	{
		return (IMissoesSelector) Application.Selector.newInstance(Missao__c.SObjectType);
	}
    
    public MissoesSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public MissoesSelector()
    {
        super(true);

        this.ignoreCRUD();
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
		};
	}
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Missao__c.FieldSets.Missoes	};
    }
    
    public Schema.SObjectType getSObjectType()
	{
		return Missao__c.sObjectType;
	}
    
    public List<Missao__c> selectById(Set<ID> idSet)
	{
		return (List<Missao__c>) selectSObjectsById(idSet);
	}
}