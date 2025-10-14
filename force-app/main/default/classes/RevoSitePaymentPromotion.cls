@RestResource(urlMapping='/revosite/v1/payment/promotion')
global without sharing class RevoSitePaymentPromotion {

    @HttpPost
    global static void promotion(PaymentPromotion sitePromotion) {
        try {
            if (sitePromotion.operation == 'View') {
                viewPromotion(sitePromotion);
            } else if (sitePromotion.operation == 'Apply') {
                applyPromotion(sitePromotion);
            }
        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    private static void applyPromotion(PaymentPromotion promotion) {
        try {
            IOpportunityService service = OpportunityService.service();

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(promotion.salesforcePaymentId);
            CodigoPromocional__c codigoPromocional = CodigoPromocionalSelector.newInstance().selectById(promotion.promotionModelId);
    
            if (pagamento == null) {
                throw new PagamentoNaoEncontradoException(true);
            }            
    
            if (codigoPromocional == null) {
                throw new CodigoPromocionalNaoEncontradoException(true);
            }

            service.aplicarModeloPromocaoOportunidade(pagamento.OportunidadeOrigem__c, codigoPromocional.Id, promotion.promotionNewCode);

            RestContext.response.statusCode = 201;
        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    private static void viewPromotion(PaymentPromotion promotion) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(promotion.salesforcePaymentId);
        CodigoPromocional__c codigoPromocional = CodigoPromocionalSelector.newInstance().selectById(promotion.promotionModelId);

        if (pagamento == null) {
            throw new PagamentoNaoEncontradoException(true);
        }            

        if (codigoPromocional == null) {
            throw new CodigoPromocionalNaoEncontradoException(true);
        }

        UsuarioSite__c usuario = UsuarioSiteSelector.newInstance().encontraPelaConta(pagamento.Conta__c);

        PaymentPromotionResult resultado = new PaymentPromotionResult();

        resultado.webSiteUserId = usuario != null ? usuario.IdSite__c : null;
        resultado.customerName = pagamento.conta__r.Name;
        resultado.customerTypeDocument = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.TipoDocumento__pc : 'CNPJ';
        resultado.customerDocument = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.NumeroDocumento__pc : pagamento.conta__r.CNPJCPF__c;
        resultado.customerPhone = pagamento.conta__r.Phone;
        resultado.customerEmail = pagamento.conta__r.isPersonAccount ? pagamento.conta__r.PersonEmail : pagamento.conta__r.Email__c;
        resultado.paymentStatus = pagamento.StatusPagamento__c;         

        resultado.totalPending = 0;

        Opportunity oportunidade = OpportunityService.service().visualizarPromocaoOportunidade(pagamento.OportunidadeOrigem__c, codigoPromocional.Id);

        Map<Id, Servico__c> mapServicos = new Map<Id, Servico__c>(oportunidade.Servicos__r);

        if (pagamento.StatusPagamento__c == 'Pendente') {

            for (Empenho__c empenho : pagamento.Empenhos__r) {

                if (sfd(empenho.ValorEmpenho__c) != 0) {
                    continue;
                }

                if (empenho.Servico__r.Status__c != 'PreReservado') {
                    continue;
                }

                Service servico = new Service();

                servico.serviceId = empenho.Servico__c;
                servico.productId = empenho.Servico__r.Produto__c;
                servico.serviceProductName = empenho.NomeProduto__c;
                servico.routeFlightName = empenho.RotaVoo__c;
                servico.flightDateTime = empenho.DataVoo__c;
                servico.passangerName = empenho.NomePassageiro__c;

                if (mapServicos.containsKey(empenho.Servico__c)) {
                    servico.pendingPayment = sfd(mapServicos.get(empenho.Servico__c).ValorTotal__c) - sfd(mapServicos.get(empenho.Servico__c).ValorPago__c);
                } else {
                    servico.pendingPayment = sfd(empenho.Servico__r.ValorTotal__c) - sfd(empenho.Servico__r.ValorPago__c);
                }

                resultado.totalPending += servico.pendingPayment;

                resultado.servicesToPay.add(servico);
            }         
        }

        RestContext.response.statusCode = 200;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(
            JSON.serialize(resultado)
        );
    }    

    private static Decimal sfd(Decimal value) {
        return (value == null) ? 0 : value;
    }    

    global class PaymentPromotion {
        public String salesforcePaymentId { get; set; }
        public String promotionModelId { get; set; }
        public String promotionNewCode { get; set; }
        public String operation { get; set; }
    }

    global class PaymentPromotionResult {
        public String webSiteUserId {get;set;}
        public String customerName {get;set;}
        public String customerTypeDocument {get;set;}
        public String customerDocument {get;set;}
        public String customerPhone {get;set;}
        public String customerEmail {get;set;}
        public String paymentStatus {get;set;}
        public List<Service> servicesToPay {get;set;}

        public PaymentPromotionResult() {
            servicesToPay = new List<Service>();
        }
        public Decimal totalPending { get; set; }
    }    

    global class Service {
        public String serviceId {get;set;}
        public String productId {get;set;}
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

    public class CodigoPromocionalNaoEncontradoException extends RevoSiteApi.RevoSiteApiException {
        public CodigoPromocionalNaoEncontradoException(Boolean voidParam) {
            super('API-0008','Código Promocional não encontrado!');
        }
    }

    // #endregion

}