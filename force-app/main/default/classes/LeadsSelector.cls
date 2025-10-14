public class LeadsSelector extends fflib_SObjectSelector
	implements ILeadsSelector
{

    public LeadsSelector(Boolean includeFieldSetFields) 
    {
        super(includeFieldSetFields);
    }
    
    public LeadsSelector()
    {
        super(true);
    }	

    public static ILeadsSelector newInstance()
	{
		return (ILeadsSelector) Application.Selector.newInstance(Lead.SObjectType);
	}
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Lead.Id,
            Lead.Email
		};
	}

    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet> 
        {	
            SobjectType.Lead.FieldSets.SobjectFieldList	
		};
	}	
    
    public Schema.SObjectType getSObjectType()
	{
		return Lead.sObjectType;
	}
    
    public List<Lead> selectById(Set<ID> idSet)
	{
		return (List<Lead>) selectSObjectsById(idSet);
	}
  
}