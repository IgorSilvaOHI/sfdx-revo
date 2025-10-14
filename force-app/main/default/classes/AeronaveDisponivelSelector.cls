public class AeronaveDisponivelSelector  extends fflib_SObjectSelector 
implements IAeronaveDisponivelSelector {
    
    public static IAeronaveDisponivelSelector newInstance()
    {
        return (IAeronaveDisponivelSelector) Application.Selector.newInstance(AeronaveDisponivel__c.SObjectType);
    }
    
    public AeronaveDisponivelSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public AeronaveDisponivelSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.AeronaveDisponivel__c.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            AeronaveDisponivel__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return AeronaveDisponivel__c.sObjectType;
    }
    
    
    public List<AeronaveDisponivel__c> aeronavesPorProduto(Set<Id> idProducts) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Produto__c IN :idProducts');
        
        return (List<AeronaveDisponivel__c>) Database.query( query.toSOQL() );         
    }

}