public class RegraProdutoSelector extends fflib_SObjectSelector 
implements IRegraProdutoSelector {

    public static IRegraProdutoSelector newInstance()
    {
        return (IRegraProdutoSelector) Application.Selector.newInstance(RegraProduto__c.SObjectType);
    }
    
    public RegraProdutoSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public RegraProdutoSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.RegraProduto__c.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            RegraProduto__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return RegraProduto__c.sObjectType;
    }    

    public Map<Id, List<RegraProduto__c>> selectByIdProducts(Set<ID> idProducts) 
    {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Produto__c IN :idProducts');
        
        List<RegraProduto__c> regras = Database.query( query.toSOQL() );

        Map<Id, List<RegraProduto__c>> result = new Map<Id, List<RegraProduto__c>>();

        for (RegraProduto__c regra : regras) {
            
            if (!result.containsKey(regra.Produto__c)) {
                result.put(regra.Produto__c, new List<RegraProduto__c>());
            }

            result.get(regra.Produto__c).add(regra);
        }

        return result; 
    }    
}