public class PrioridadeMalhaSelector extends fflib_SObjectSelector 
implements IPrioridadeMalhaSelector {
    
    public static IPrioridadeMalhaSelector newInstance()
    {
        return (IPrioridadeMalhaSelector) Application.Selector.newInstance(PrioridadeMalha__c.SObjectType);
    }
    
    public PrioridadeMalhaSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public PrioridadeMalhaSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.PrioridadeMalha__c.FieldSets.SelectFieldList);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            PrioridadeMalha__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return PrioridadeMalha__c.sObjectType;
    }

    public List<PrioridadeMalha__c> aeronavesPorPriridadeMalha(Id malhaId) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('MalhaVoo__c = :malhaId');
        
        return (List<PrioridadeMalha__c>) Database.query( query.toSOQL() );         
    }    

    public Map<Id,List<PrioridadeMalha__c>> aeronavesPorPriridadeMalhas(Set<Id> malhaIds) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('MalhaVoo__c IN :malhaId');
        
        List<PrioridadeMalha__c> prioridades = (List<PrioridadeMalha__c>) Database.query( query.toSOQL() );

        Map<Id, List<PrioridadeMalha__c>> result = new Map<Id, List<PrioridadeMalha__c>>();

        for (PrioridadeMalha__c prioridade : prioridades) {

            if (!result.containsKey(prioridade.MalhaVoo__c)) {
                result.put(prioridade.MalhaVoo__c, new List<PrioridadeMalha__c>());
            }

            List<PrioridadeMalha__c> lista = result.get(prioridade.MalhaVoo__c);

            lista.add(prioridade);
        }

        return result;             
    }
}