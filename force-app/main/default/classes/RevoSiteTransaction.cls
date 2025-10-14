@RestResource(urlMapping='/revosite/v1/payment/transaction')
global without sharing class RevoSiteTransaction {

    @HttpPost
    global static void transaction(RevoSiteUserTransaction siteTransaction) {
        try {
            IPagamentosService service = PagamentosService.service();

            service.registraTransacaoGateway(siteTransaction.salesforcePaymentId, siteTransaction.gatewayName,
                                            siteTransaction.paymentMethod, siteTransaction.transactionId, siteTransaction.transactionStatus,
                                            siteTransaction.gatewayMessage, siteTransaction.transactionValue);
        } catch (Exception e) {
            System.debug('Erro ao registrar transação: ' + e.getMessage());
            RevoSiteApi.standardBadResult(e);
        }
    }

    global class RevoSiteUserTransaction {

        public String salesforcePaymentId { get; set; }
        public String gatewayName { get; set; }
        public String paymentMethod { get; set; }
        public String transactionId { get; set; }
        public String transactionStatus { get; set; }
        public String gatewayMessage { get; set; }
        public double transactionValue { get; set; }

    }

}