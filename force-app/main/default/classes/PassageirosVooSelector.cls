public class PassageirosVooSelector extends fflib_SObjectSelector implements IPassageirosVooSelector
{    
    public List<PassageiroVoo__c> selectByVooId(Set<Id> voosId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosId');
        return (List<PassageiroVoo__c>) Database.query(query.toSOQL());
    }

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				PassageiroVoo__c.Id,
                PassageiroVoo__c.Voo__c,
                PassageiroVoo__c.Contato__c
		};
	}              
    
    public Schema.SObjectType getSObjectType()
    {
        return PassageiroVoo__c.sObjectType;
    }
    
    public PassageirosVooSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.PassageiroVoo__c.FieldSets.SelectFieldList	};
    }
    
    public static IPassageirosVooSelector newInstance()
    {
        return (IPassageirosVooSelector) Application.Selector.newInstance(PassageiroVoo__c.SObjectType);
    }
}