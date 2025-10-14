public class CodigoPromocionalSelector extends fflib_SObjectSelector 
implements ICodigoPromocionalSelector  {

    public static ICodigoPromocionalSelector newInstance()
    {
        return (ICodigoPromocionalSelector) Application.Selector.newInstance(CodigoPromocional__c.SObjectType);
    }
    
    public CodigoPromocionalSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public CodigoPromocionalSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.CodigoPromocional__c.FieldSets.ParaCalculoPreco);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            CodigoPromocional__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return CodigoPromocional__c.sObjectType;
    }    

    public List<CodigoPromocional__c> selectById(Set<ID> idSet)
    {
        return (List<CodigoPromocional__c>) selectSObjectsById(idSet);
    }
        
    public CodigoPromocional__c selectByCodigo(String codigoPromocional)
    {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Name = :codigoPromocional And Ativo__c = true And (RecordType.DeveloperName = \'PromocaoParceiro\' OR RecordType.DeveloperName = \'CodigoPromocional\')');

        query.setLimit(1);

        query.subselectQuery('ItensPromocoes__r')
        .selectFieldSet(SobjectType.ItemPromocao__c.FieldSets.SobjectFieldList)
        .setOrdering('QuantidadeMinima__c', fflib_QueryFactory.SortOrder.DESCENDING, true);    

        List<CodigoPromocional__c> codigos = Database.query( query.toSOQL() );

        return codigos.size() > 0 ? codigos[0] : null;         
    }    

    public CodigoPromocional__c selectById(Id codigoPromocionalId)
    {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Id = :codigoPromocionalId And Ativo__c = true');

        query.setLimit(1);

        query.subselectQuery('ItensPromocoes__r')
        .selectFieldSet(SobjectType.ItemPromocao__c.FieldSets.SobjectFieldList)
        .setOrdering('QuantidadeMinima__c', fflib_QueryFactory.SortOrder.DESCENDING, true);    

        List<CodigoPromocional__c> codigos = Database.query( query.toSOQL() );

        return codigos.size() > 0 ? codigos[0] : null;         
    }    


}