public class AeronavesSelector extends fflib_SObjectSelector implements IAeronavesSelector {
    
    private final String spot = 'Spot';
    private final String shared = 'Shared';
    
    public static IAeronavesSelector newInstance()
	{
        //system.debug('aeronaves selector');
		return (IAeronavesSelector) Application.Selector.newInstance(Aeronave__c.SObjectType);
	}
    
    public AeronavesSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public AeronavesSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Aeronave__c.FieldSets.SelectFieldList	
        };
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Aeronave__c.Id,
            Aeronave__c.Name,
            Aeronave__c.Posicao__Latitude__s,
            Aeronave__c.Posicao__Longitude__s,
            Aeronave__c.TempoSoloAterrissagem__c,
            Aeronave__c.TempoSoloDecolagem__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Aeronave__c.sObjectType;
    }
    
    public List<Aeronave__c> selectById(Set<Id> idSet) {
        return (List<Aeronave__c>) selectSObjectsById(idSet);
    }
    
    public List<Aeronave__c> getPrefixosValidos(Set<Id> prefixosExclusos)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Desativada__c = false AND Id NOT IN :prefixosExclusos');
        
        return (List<Aeronave__c>) Database.query(query.toSOQL());
    }
    
    public List<Aeronave__c> selectTodasAtivas()
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Desativada__c = false');
       
        return (List<Aeronave__c>) Database.query(query.toSOQL());
    }
    
    public List<Aeronave__c> selectAll()
    {
        fflib_QueryFactory query = newQueryFactory();
        
        return (List<Aeronave__c>) Database.query(query.toSOQL());
    }
    
    public List<Aeronave__c> selectAeronaveAndModelo(Set<Id> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :idSet');
        
        fflib_SObjectSelector prodctsSelector = new Product2Selector();
        prodctsSelector.configureQueryFactoryFields(query, 'ModeloAeronave__r');
        system.debug('asdf ' + query.toSOQL());
        return (List<Aeronave__c>) Database.query(query.toSOQL());
    }
}