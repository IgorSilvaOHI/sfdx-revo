public class StatusBloqueioDelecaoVooSelector extends fflib_SObjectSelector implements IStatusBloqueioDelecaoVooSelector {
    
    public static IStatusBloqueioDelecaoVooSelector newInstance()
	{
		return (IStatusBloqueioDelecaoVooSelector) Application.Selector.newInstance(StatusBloqueioDelecaoVoo__mdt.SObjectType);
	}
    
    public StatusBloqueioDelecaoVooSelector()
    {
        super(true);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            StatusBloqueioDelecaoVoo__mdt.Id,
            StatusBloqueioDelecaoVoo__mdt.DeveloperName
                };
                    }
    
    public Schema.SObjectType getSObjectType() {
        return StatusBloqueioDelecaoVoo__mdt.sObjectType;
    }
    
    public List<StatusBloqueioDelecaoVoo__mdt> selectAll()
    {
        fflib_QueryFactory query = newQueryFactory();
        
        return (List<StatusBloqueioDelecaoVoo__mdt>) Database.query(query.toSOQL());
    }
}