public class RegraPrecoSelector extends fflib_SObjectSelector 
implements IRegraPrecoSelector {

    public static IRegraPrecoSelector newInstance()
    {
        return (IRegraPrecoSelector) Application.Selector.newInstance(RegraPreco__c.SObjectType);
    }
    
    public RegraPrecoSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public RegraPrecoSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.RegraPreco__c.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            RegraPreco__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return RegraPreco__c.sObjectType;
    }    

    public Map<Id, List<RegraPreco__c>> selectByIdProducts(Set<ID> idProducts) 
    {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Produto__c IN :idProducts');
        
        List<RegraPreco__c> regras = Database.query( query.toSOQL() );

        Map<Id, List<RegraPreco__c>> result = new Map<Id, List<RegraPreco__c>>();

        for (RegraPreco__c regra : regras) {
            
            if (!result.containsKey(regra.Produto__c)) {
                result.put(regra.Produto__c, new List<RegraPreco__c>());
            }

            result.get(regra.Produto__c).add(regra);
        }

        return result; 
    }    
}