public class CalloutGeraLinkPagamento {

    // #region Constants

    private static final String NAMED_CREDENTIALS = 'REVOSite';

    // #endregion

    // #region Methods

    public static String geraLinkPagamento(Id opportunity_id){

        String body = JSON.serialize(new PaymentLinkRequest(opportunity_id));

        HttpResponse response = sendStandard('POST', '/api/v2/checkout/payment-link', body, 10000);

        System.debug('body: ' + response.getBody());
        System.debug('Codi: ' + response.getStatusCode());

        if(response.getStatusCode() != 200) {

            PaymentLinkError error = (PaymentLinkError) JSON.deserialize(response.getBody(), PaymentLinkError.class);
            throw new PaymentLinkException('Erro ao gerar link de pagamento: ' + error.data.msg);
        }

        PaymentLinkResponse result = (PaymentLinkResponse) JSON.deserialize(response.getBody(), PaymentLinkResponse.class);

        return result.data?.payment_link ?? result.payment_link;
    }    

    // #endregion

    // #region Private Methods

    private static HttpResponse sendStandard(String method, String resource, String body, Integer timeout){
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + NAMED_CREDENTIALS + '/' + resource);
        request.setMethod((method == 'PATCH') ? 'POST' : method);   
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');       
        
        if (timeout != null) { 
	        request.setTimeout(timeout);     
        }
        
        if(method == 'PATCH') {
            request.setHeader('X-HTTP-Method-Override','PATCH');
        }
        
        if (!String.isEmpty(body)) {
	        request.setBody(body);
        }
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 401){
            //It is necessary to place a dummey request to update a token, as per salesforce link
            //https://help.salesforce.com/articleView?id=000313355&language=en_US&type=1&mode=1
			return sendStandard(method, resource, body, timeout);
        }
        
        return response;
    }        

    // #endregion

    // #region Classes

    private class PaymentLinkRequest {
        public String opportunity_id;
        
        public PaymentLinkRequest(String opportunityId){ 
            this.opportunity_id = opportunityId; 
        }
    }

    private class PaymentLinkResponse {
        public String payment_link;
        public data data;
        
    }

    private class data {
        public String msg;
        public String payment_link;
    }

    private class PaymentLinkError {
        public data data;
    }

    // #endregion

    // #region Exceptions

    public class PaymentLinkException extends Exception {}

    // #endregion

}