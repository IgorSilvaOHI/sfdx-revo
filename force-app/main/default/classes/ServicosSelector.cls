public class ServicosSelector extends fflib_SObjectSelector implements IServicosSelector
{

    public ServicosSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public ServicosSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet> {
            SobjectType.Servico__c.FieldSets.SelectFieldList
        };
    }
    
    public static IServicosSelector newInstance()
    {
        return (IServicosSelector) Application.Selector.newInstance(Servico__c.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
            Servico__c.Id
		};
	}                  
    
    public Schema.SObjectType getSObjectType()
    {
        return Servico__c.sObjectType;
    }    

    public List<Servico__c> selectByOpportunityId(Set<ID> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Oportunidade__c IN :idSet');
        return (List<Servico__c>) Database.query(query.toSOQL());        
    }

    public List<Servico__c> selectByVooId(Set<ID> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :idSet AND ProdutoOportunidade__r.Pacote__c = null');
        query.selectField('Oportunidade__r.CodigoReserva__c');
        return (List<Servico__c>) Database.query(query.toSOQL());        
    }
    

    public List<Servico__c> selectById(Set<ID> idSet) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :idSet');
        return (List<Servico__c>) Database.query(query.toSOQL());        
    }

}