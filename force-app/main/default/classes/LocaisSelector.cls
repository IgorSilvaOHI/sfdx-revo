public class LocaisSelector extends fflib_SObjectSelector 
implements ILocaisSelector
{
    private static final String validado = 'Validado';
    
    public static ILocaisSelector newInstance()
    {
        return (ILocaisSelector) Application.Selector.newInstance(Local__c.SObjectType);
    }
    
    public LocaisSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public LocaisSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>
        {	SobjectType.Local__c.FieldSets.SelectFieldList	};
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Local__c.Id,
            Local__c.Name,
            Local__c.CodigoLocal__c,
            Local__c.Categoria__c,
            Local__c.Tipo__c
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Local__c.sObjectType;
    }
    
    public List<Local__c> selectById(Set<ID> idSet)
    {
        return (List<Local__c>) selectSObjectsById(idSet);
    }
}