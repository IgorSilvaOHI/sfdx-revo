@RestResource(urlMapping='/revosite/v1/payment/view')
global without sharing class RevoSitePaymentView {

    @HttpPost
    global static void view(PaymentView view) {
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(view.salesforcePaymentId);

            if (pagamento == null) {
                throw new PagamentoNaoEncontradoException(true);
            }            

            UsuarioSite__c usuario = UsuarioSiteSelector.newInstance().encontraPelaConta(pagamento.Conta__c);

            PaymentViewResult resultado = new PaymentViewResult();

            resultado.webSiteUserId = usuario != null ? usuario.IdSite__c : null;
            resultado.customerName = pagamento.conta__r.Name;
            resultado.customerTypeDocument = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.TipoDocumento__pc : 'CNPJ';
            resultado.customerDocument = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.NumeroDocumento__pc : pagamento.conta__r.CNPJCPF__c;
            resultado.customerPhone = pagamento.conta__r.Phone;
            resultado.customerEmail = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.PersonEmail : pagamento.conta__r.Email__c;
            resultado.paymentStatus = pagamento.StatusPagamento__c;         

            resultado.totalPending = 0;

            if (pagamento.StatusPagamento__c == 'Pendente') {

                for (Empenho__c empenho : pagamento.Empenhos__r) {

                    if (sfd(empenho.ValorEmpenho__c) != 0) {
                        continue;
                    }

                    if (empenho.Servico__r.Status__c != 'PreReservado') {
                        continue;
                    }

                    Service servico = new Service();

                    servico.productId = empenho.Servico__r.Produto__c;
                    servico.serviceId = empenho.Servico__c;
                    servico.serviceProductName = empenho.NomeProduto__c;
                    servico.routeFlightName = empenho.RotaVoo__c;
                    servico.flightDateTime = empenho.DataVoo__c;
                    servico.passangerName = empenho.NomePassageiro__c;

                    servico.pendingPayment = sfd(empenho.Servico__r.ValorTotal__c) - sfd(empenho.Servico__r.ValorPago__c);

                    resultado.totalPending += servico.pendingPayment;

                    resultado.servicesToPay.add(servico);
                }         
            }

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(
                JSON.serialize(resultado)
            );

        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    private static Decimal sfd(Decimal value) {
        return (value == null) ? 0 : value;
    }

    global class PaymentView {

        public String salesforcePaymentId { get; set; }

    }

    global class PaymentViewResult {
        public String webSiteUserId {get;set;}
        public String customerName {get;set;}
        public String customerTypeDocument {get;set;}
        public String customerDocument {get;set;}
        public String customerPhone {get;set;}
        public String customerEmail {get;set;}
        public String paymentStatus {get;set;}
        public List<Service> servicesToPay {get;set;}

        public PaymentViewResult() {
            servicesToPay = new List<Service>();
        }
        public Decimal totalPending { get; set; }
    }    

    global class Service {
        public String productId {get;set;}
        public String serviceId {get;set;}
        public String serviceProductName {get;set;}
        public String routeFlightName {get;set;}
        public DateTime flightDateTime {get;set;}
        public String flightTimeZone {get { return 'GMT-03:00'; } set;}
        public String passangerName {get;set;}
        public Decimal pendingPayment {get;set;}
    }


    // #region Excepitions

    public class PagamentoNaoEncontradoException extends RevoSiteApi.RevoSiteApiException {
        public PagamentoNaoEncontradoException(Boolean voidParam) {
            super('API-0007','Pagamento não encontrado!');
        }
    }

    // #endregion
}