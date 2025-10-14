public with sharing class FlowCriarPagamentoVoucher {

    public class FlowCriarPagamentoVoucherResultado {
        @InvocableVariable(label='Pagamento ID' required=false)
        @AuraEnabled
        public Id idPagamento;

        @InvocableVariable(label='Sucesso' required=false)
        @AuraEnabled
        public Boolean sucesso;

        @InvocableVariable(label='Mensagem' required=false)
        @AuraEnabled
        public String mensagem;

        public FlowCriarPagamentoVoucherResultado(Id idPagamento, Boolean sucesso, String mensagem) {
            this.idPagamento = idPagamento;
            this.sucesso = sucesso;
            this.mensagem = mensagem;
        }
    }    

    public class FlowCriarPagamentoVoucherChamada {
        @InvocableVariable(label='Id Conta Origem' required=true)
        @AuraEnabled
        public String idContaOrigem;

        @InvocableVariable(label='Id Conta Destino' required=false)
        @AuraEnabled
        public String idContaDestino;        

        @InvocableVariable(label='Tipo Voucher' required=true)
        @AuraEnabled
        public String tipoVoucher;

        @InvocableVariable(label='Quantidade RevoSeats' required=false)
        @AuraEnabled
        public Decimal quantidadeRevoSeats;
    }       

    @InvocableMethod(label='Criar Pagamento Voucher para conta' description='Processa a criação do Pagamento do Voucher para a conta')
    public static List<FlowCriarPagamentoVoucherResultado> criarPagamentoVoucher(List<FlowCriarPagamentoVoucherChamada> chamadas) {

        System.debug('chamadas: ' + chamadas);

        List<FlowCriarPagamentoVoucherResultado> result = new List<FlowCriarPagamentoVoucherResultado>();

        for(FlowCriarPagamentoVoucherChamada chamada : chamadas)
        {
            try {
                IPagamentosService service = PagamentosService.service();

                Pagamento__c pagamento = service.criaPagamentoVoucher(chamada.idContaOrigem, chamada.idContaDestino, chamada.tipoVoucher, chamada.quantidadeRevoSeats);

                result.add(new FlowCriarPagamentoVoucherResultado(pagamento.Id, true, null));
            } catch (Exception e) {
                result.add(new FlowCriarPagamentoVoucherResultado(null, false, e.getMessage()));
            }
        }

        return result;
    }
}