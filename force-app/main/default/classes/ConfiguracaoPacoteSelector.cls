public class ConfiguracaoPacoteSelector extends fflib_SObjectSelector 
implements IConfiguracaoPacoteSelector {

    public static IConfiguracaoPacoteSelector newInstance()
    {
        return (IConfiguracaoPacoteSelector) Application.Selector.newInstance(ConfiguracaoPacote__c.SObjectType);
    }
    
    public ConfiguracaoPacoteSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public ConfiguracaoPacoteSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.ConfiguracaoPacote__c.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            ConfiguracaoPacote__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return ConfiguracaoPacote__c.sObjectType;
    }    

    public Map<Id, List<ConfiguracaoPacote__c>> selectByIdProducts(Set<ID> idProducts) 
    {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('ProdutoPai__c IN :idProducts And ProdutoPacote__r.IsActive = true');
        query.setOrdering('Posicao__c', fflib_QueryFactory.SortOrder.ASCENDING);

        List<ConfiguracaoPacote__c> configs = Database.query( query.toSOQL() );

        Map<Id, List<ConfiguracaoPacote__c>> result = new Map<Id, List<ConfiguracaoPacote__c>>();

        for (ConfiguracaoPacote__c config : configs) {
            
            if (!result.containsKey(config.ProdutoPai__c)) {
                result.put(config.ProdutoPai__c, new List<ConfiguracaoPacote__c>());
            }

            result.get(config.ProdutoPai__c).add(config);
        }

        return result; 
    }
}