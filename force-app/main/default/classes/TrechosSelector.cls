public class TrechosSelector extends fflib_SObjectSelector 
implements ITrechosSelector
{
    
    public static ITrechosSelector newInstance()
    {
        return (ITrechosSelector) Application.Selector.newInstance(Trecho__c.SObjectType);
    }
    
    public TrechosSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public TrechosSelector()
    {
        super(true);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.Trecho__c.FieldSets.SelectFieldList);
        fieldSets.add(SobjectType.Trecho__c.FieldSets.SelectFieldList2);
        fieldSets.add(SobjectType.Trecho__c.FieldSets.OrigemFieldList);
        fieldSets.add(SobjectType.Trecho__c.FieldSets.DestinoFieldList);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Trecho__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Trecho__c.sObjectType;
    }
    
    public List<Trecho__c> selectById(Set<ID> idSet)
    {
        return (List<Trecho__c>) selectSObjectsById(idSet);
    }
    
    public List<Trecho__c> selectByVooId(Set<Id> vooId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :vooId');
        query.setOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        fflib_SObjectSelector voosSelector = new VoosSelector();
        voosSelector.configureQueryFactoryFields(query, 'Voo__r'); 
        
        fflib_SObjectSelector locaisSelector = new LocaisSelector();
        locaisSelector.configureQueryFactoryFields(query, 'Origem__r');
        locaisSelector.configureQueryFactoryFields(query, 'Destino__r');
        
        new PassageirosSelector(true).addQueryFactorySubselect(query, 'Passageiros__r');
        new CargasSelector(true).addQueryFactorySubselect(query, 'Cargas__r');
        
        return (List<Trecho__c>) Database.query(query.toSOQL());
    }
    
    public List<Trecho__c> selectByVooIdOrderByOrdemExecucao(Set<Id> voosIds)
    {
        fflib_QueryFactory query = newQueryFactory();
        
        fflib_SObjectSelector locaisSelector = new LocaisSelector();
        locaisSelector.configureQueryFactoryFields(query, 'Origem__r');
        locaisSelector.configureQueryFactoryFields(query, 'Destino__r');
        
        fflib_SObjectSelector voosSelector = new VoosSelector();
        voosSelector.configureQueryFactoryFields(query, 'Voo__r');        
        
        query.setCondition('Voo__c IN :voosIds');
        query.addOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Trecho__c>) Database.query(query.toSOQL()); 
    }

    public List<Trecho__c> getTrechoWithPassageirosByVooId(Set<Id> voosId, Set<Id> contatosId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosId');
        query.setOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        /*fflib_SObjectSelector voosSelector = new VoosSelector();
		voosSelector.configureQueryFactoryFields(query, 'Voo__r'); */
        
        fflib_SObjectSelector locaisSelector = new LocaisSelector();
        locaisSelector.configureQueryFactoryFields(query, 'Origem__r');
        locaisSelector.configureQueryFactoryFields(query, 'Destino__r');
        
        fflib_QueryFactory passageirosQuery = new PassageirosSelector().addQueryFactorySubselect(query, 'Passageiros__r');
        passageirosQuery.setCondition('Contato__c IN :contatosId');
        
        return (List<Trecho__c>) Database.query(query.toSOQL());
    }
    
    public List<Trecho__c> getTrechosByMalha(Id produtoId, Id malhaId, DateTime startdate, DateTime enddate)
    {
        Set<String> statusInvalidos = new Set<String> { 'Cancelado' };

        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Voo__r.Prefixo__r.NumeroAssentos__c');
        query.selectField('Voo__r.Prefixo__r.Name');
        query.selectField('Voo__r.Prefixo__r.ModeloAeronave__c');
        query.selectField('Voo__r.Prefixo__r.ModeloAeronave__r.Name');
        query.selectField('Voo__r.Prefixo__r.ModeloAeronave__r.ImagemUrl__c');

        query.setCondition('ProdutoShuttleSeat__c = :produtoId And MalhaVoo__c = :malhaId And Voo__r.Status__c Not IN :statusInvalidos And Voo__r.DataVoo__c >= :startdate And Voo__r.DataVoo__c <= :enddate');
        query.setOrdering('Voo__r.DataVoo__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Trecho__c>) Database.query( query.toSOQL() ); 
    }

}