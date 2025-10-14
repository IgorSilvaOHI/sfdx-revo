public class MalhaVooSelector  extends fflib_SObjectSelector 
implements IMalhaVooSelector {
    
    public static IMalhaVooSelector newInstance()
    {
        return (IMalhaVooSelector) Application.Selector.newInstance(MalhaVoo__c.SObjectType);
    }
    
    public MalhaVooSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public MalhaVooSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.MalhaVoo__c.FieldSets.SelectFieldList);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            MalhaVoo__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return MalhaVoo__c.sObjectType;
    }

    public List<MalhaVoo__c> selectById(Set<ID> idSet)
    {
        return (List<MalhaVoo__c>) selectSObjectsById(idSet);
    }   

    public List<MalhaVoo__c> selectByProduct(Id productId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Produto__c = :productId');
        query.setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.query(query.toSOQL());
    }

    public MalhaVoo__c malhaDeVooDoProdutoNaData(Id idProduct, Date data, Id origem, Id destino, Datetime menorData, Datetime maiorData) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Ativa__c = True And Produto__c = :idProduct And ' + 
        'Origem__c = :origem And Destino__c = :destino And ' + 
        'DataInicio__c <= :data And DataFim__c >= :data');

        fflib_QueryFactory subquery = query.subselectQuery('HorariosExtraMalha__r')
        .setCondition('DataHoraExtra__c >= :menorData And DataHoraExtra__c <= :maiorData')
        .selectFieldSet(SobjectType.HorarioExtraDaMalha__c.FieldSets.SobjectFieldList);
        
        System.debug('MalhaVoo: ' + query.toSOQL());
        
        List<MalhaVoo__c> malhas = Database.query( query.toSOQL() );

        return malhas.size() > 0 ? malhas[0] : null; 
    }    
    
}