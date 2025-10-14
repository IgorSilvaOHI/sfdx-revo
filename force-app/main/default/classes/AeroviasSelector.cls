public class AeroviasSelector extends fflib_SObjectSelector implements IAeroviasSelector
{

    public static IAeroviasSelector newInstance()
	{
		return (IAeroviasSelector) Application.Selector.newInstance(Aerovia__c.SObjectType);
	}
    
    public AeroviasSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.Aerovia__c.FieldSets.SelectFieldList);
     
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Aerovia__c.Id
		};
	}
    
    public Schema.SObjectType getSObjectType()
	{
		return Aerovia__c.sObjectType;
	}
    
    public List<Aerovia__c> selectById(Set<ID> idSet)
	{
		return (List<Aerovia__c>) selectSObjectsById(idSet);
	}
    
    public List<Aerovia__c> selectByOrigemDestino(Set<Id> origens, Set<Id> destinos)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Origem__c IN :origens AND Destino__c IN :destinos');
        
        return (List<Aerovia__c>) Database.query(query.toSOQL());
    }
    
    public List<Aerovia__c> selectWithRetornoByOrigemDestino(Set<Id> origens, Set<Id> destinos)
    {
        fflib_QueryFactory query = newQueryFactory();
        String condition = ' (Origem__c IN :origens AND Destino__c IN :destinos) ';
        condition += ' OR (Origem__c IN :destinos AND Destino__c IN :origens) ';
            
        query.setCondition(condition);
        
        return (List<Aerovia__c>) Database.query(query.toSOQL());
    }
}