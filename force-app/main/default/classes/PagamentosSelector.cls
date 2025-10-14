public class PagamentosSelector extends fflib_SObjectSelector
	implements IPagamentosSelector
{

    public static IPagamentosSelector newInstance()
	{
		return (IPagamentosSelector) Application.Selector.newInstance(Pagamento__c.SObjectType);
	}
    
    public PagamentosSelector()
    {
        super(true);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }	

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Pagamento__c.Id
		};
	}
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>    
        {   SobjectType.Pagamento__c.FieldSets.SobjectFieldList    };
    }
    	
    
    public Schema.SObjectType getSObjectType()
	{
		return Pagamento__c.sObjectType;
	}
    
    public List<Pagamento__c> selectById(Set<ID> idSet)
	{
		return (List<Pagamento__c>) selectSObjectsById(idSet);
	}
  
    public Pagamento__c selectPagamentoGateway(Id pagamentoId)
	{
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :pagamentoId').setForUpdate();

        System.debug(query.getOrderings());

        fflib_QueryFactory subquery = query.subselectQuery('TransacesGateway__r')
        .selectFieldSet(SobjectType.TransacaoGateway__c.FieldSets.SobjectFieldList)
		.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        fflib_QueryFactory subquery1 = query.subselectQuery('Empenhos__r')
        .selectFieldSet(SobjectType.Empenho__c.FieldSets.SobjectFieldList);

        System.debug(query.getOrderings());

        System.debug(query.toSOQL());

        List<Pagamento__c> pagts = Database.query( query.toSOQL() );
        
        return pagts.size() > 0 ? pagts[0] : null;		
	}	

    public List<Pagamento__c> selectPagamentoPendenteGatewayOppId(Set<ID> idSet)
	{
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('OportunidadeOrigem__c IN :idSet And RecordType.DeveloperName = \'GatewayPagamento\' And StatusPagamento__c = \'Pendente\'');

        return (List<Pagamento__c>) Database.query(query.toSOQL());
	}	

}