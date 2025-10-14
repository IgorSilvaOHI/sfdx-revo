public without sharing class OpportunityService {

    public static IOpportunityService service()
    {
        return (IOpportunityService) Application.Service.newInstance(IOpportunityService.class);
    }	    
}