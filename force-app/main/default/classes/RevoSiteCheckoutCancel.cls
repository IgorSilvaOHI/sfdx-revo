@RestResource(urlMapping='/revosite/v1/checkout/cancel')
global without sharing class RevoSiteCheckoutCancel {
    
    @HttpPost
    global static void cancelCheckout(OpportunityCancel param) {

        try {
            IOpportunityService service = OpportunityService.service();

            service.cancelarOportunidade(param.opportunityId);

        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    global class OpportunityCancel {
        public String opportunityId { get; set; }
    }
}