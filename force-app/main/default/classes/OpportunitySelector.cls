public class OpportunitySelector extends fflib_SObjectSelector 
implements IOpportunitySelector  {

    public static IOpportunitySelector newInstance()
    {
        return (IOpportunitySelector) Application.Selector.newInstance(Opportunity.SObjectType);
    }
    
    public OpportunitySelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public OpportunitySelector()
    {
        super(true);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.Opportunity.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Opportunity.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Opportunity.sObjectType;
    }    

    public Boolean primeiraCompraConta(Id contaId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('AccountId = :contaId And IsClosed = true And IsWon = true');
        query.setLimit(2);

        List<Opportunity> oportunidades = Database.query( query.toSOQL() );


        if (oportunidades.isEmpty()) {
            return true;
        }
        else {
            return false;
        }
    }

    public Boolean idPromocionalUsadoNaConta(Id contaId, Id codigoPromocionalId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('AccountId = :contaId And IsClosed = true And IsWon = true And CodigoPromocional__c = :codigoPromocionalId');
        query.setLimit(2);

        List<Opportunity> oportunidades = Database.query( query.toSOQL() );

        if (oportunidades.isEmpty()) {
            return false;
        }
        else {
            return true;
        }
    }    

    public Boolean codigoReservaUtilizado(string bookingCode) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('CodigoReserva__c = :bookingCode');
        query.setLimit(2);

        List<Opportunity> oportunidades = Database.query( query.toSOQL() );

        return !oportunidades.isEmpty();
    }    

    public Boolean codigoPromocionalUsadoNaConta(Id contaId, String codigoPromocional) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('AccountId = :contaId And IsClosed = true And IsWon = true And CodigoPromocional__r.Name = :codigoPromocional');
        query.setLimit(2);

        List<Opportunity> oportunidades = Database.query( query.toSOQL() );

        if (oportunidades.isEmpty()) {
            return false;
        }
        else {
            return true;
        }
    }

    public List<Opportunity> selectById(Set<Id> opportunityIds) {

        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id IN :opportunityIds');


        return (List<Opportunity>) Database.query(query.toSOQL());
    }

    public Opportunity encontraParaFechamento(Id opportunityId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :opportunityId');

        fflib_QueryFactory subquery = query.subselectQuery('OpportunityLineItems')
        .selectFieldSet(SobjectType.OpportunityLineItem.FieldSets.Checkout)
        .selectField('MalhaVoo__r.Origem__r.Name')
        .selectField('MalhaVoo__r.Destino__r.Name')
        .selectField('Pacote__r.Product2.RecordTypeId');

        subquery.subselectQuery('LocaisProdutoOportunidade__r')
        .selectFieldSet(SobjectType.LocalOportunidade__c.FieldSets.Checkout)
        .setOrdering('Sequencia__c', fflib_QueryFactory.SortOrder.ASCENDING);

        subquery.subselectQuery('ProdutosPassageiro__r')
        .selectFieldSet(SobjectType.ProdutoPassageiro__c.FieldSets.Checkout);

        List<Opportunity> opps = Database.query( query.toSOQL() );
        
        return opps.size() > 0 ? opps[0] : null;
    }

    public Opportunity encontraParaCancelamento(Id opportunityId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :opportunityId');

        fflib_QueryFactory subquery = query.subselectQuery('Servicos__r')
        .selectFieldSet(SobjectType.Servico__c.FieldSets.SelectFieldList);

        fflib_QueryFactory subquery1 = query.subselectQuery('PromocoesOportunidades__r')
        .selectFieldSet(SobjectType.PromocaoOportunidade__c.FieldSets.SobjectFieldList);

        List<Opportunity> opps = Database.query( query.toSOQL() );
        
        return opps.size() > 0 ? opps[0] : null;
    }    


    public Opportunity encontraParaPagamento(Id opportunityId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :opportunityId');

        fflib_QueryFactory subquery = query.subselectQuery('Servicos__r')
        .selectFieldSet(SobjectType.Servico__c.FieldSets.SelectFieldList);

        List<Opportunity> opps = Database.query( query.toSOQL() );
        
        return opps.size() > 0 ? opps[0] : null;
    }    

    public Opportunity encontraParaMudarPromocao(Id opportunityId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :opportunityId');

        fflib_QueryFactory subquery1 = query.subselectQuery('Servicos__r')
        .selectFieldSet(SobjectType.Servico__c.FieldSets.SelectFieldList);        

        fflib_QueryFactory subquery = query.subselectQuery('OpportunityLineItems')
        .selectFieldSet(SobjectType.OpportunityLineItem.FieldSets.Checkout)
        .selectField('MalhaVoo__r.Origem__r.Name')
        .selectField('MalhaVoo__r.Destino__r.Name')
        .selectField('Pacote__r.Product2.RecordTypeId');

        subquery.subselectQuery('LocaisProdutoOportunidade__r')
        .selectFieldSet(SobjectType.LocalOportunidade__c.FieldSets.Checkout)
        .setOrdering('Sequencia__c', fflib_QueryFactory.SortOrder.ASCENDING);

        subquery.subselectQuery('ProdutosPassageiro__r')
        .selectFieldSet(SobjectType.ProdutoPassageiro__c.FieldSets.Checkout);

        List<Opportunity> opps = Database.query( query.toSOQL() );
        
        return opps.size() > 0 ? opps[0] : null;
    }    
}