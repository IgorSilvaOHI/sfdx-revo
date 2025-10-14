public class InteressadosSelector extends fflib_SObjectSelector implements IInteressadosSelector
{
    
    public static IInteressadosSelector newInstance()
    {
        return (IInteressadosSelector) Application.Selector.newInstance(Interessado__c.SObjectType);
    }
    
    public InteressadosSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SObjectType.Interessado__c.FieldSets.SelectFieldList);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        
        return fields;
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Interessado__c.sObjectType;
    }
    
    public List<Interessado__c> selectById(Set<ID> idSet)
    {
        return (List<Interessado__c>) selectSObjectsById(idSet);
    }    
    
    public List<Interessado__c> selectByVoo(Set<Id> voosIds)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectConclusaoVooByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND ConclusaoVoo__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectReservaByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND Reserva__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectConclusaoTrechoByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND ConclusaoTrecho__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectEmissaoEmbarqueByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND EmissaoEmbarque__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectFaturamentoByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND Faturamento__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
    
    public List<Interessado__c> selectTakeOffReportByVoo(Set<Id> voosIds)
    {
        Boolean condition = true;
        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Voo__c IN :voosIds AND TakeOffReport__c = :condition');
        
        return (List<Interessado__c>) Database.query(query.toSOQL());
    }
}