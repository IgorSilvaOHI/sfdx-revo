global with sharing class VoosService 
{       

    global static void countPassengers(List<Id> vooIds)
    {
        service().countPassengers(vooIds);
    }
    
    global static void undeleteVoos(Set<Id> voosId)
    {
        service().undeleteVoos(voosId);
    }
    
    @AuraEnabled(cacheable=false)
    global static List<Voo__c> getVoos(List<Id> voosId)
    {        
    	return service().getVoos(Utils.getSetIdsByListIds(voosId));
    }
    
	private static IVoosService service()
	{
		return (IVoosService) Application.Service.newInstance(IVoosService.class);
	}	
}