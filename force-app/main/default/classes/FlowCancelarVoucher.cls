public with sharing class FlowCancelarVoucher {

    @InvocableMethod(label='Cancelar Pagamento Voucher' description='Processa o cancelamento do Pagamento Voucher')
    public static List<String> cancelarPagamentoVoucher(List<Id> voucherIds) {

        List<String> result = new List<String>();

        for(Id voucherID : voucherIds)
        {
            try {
                IPagamentosService service = PagamentosService.service();

                service.cancelarPagamentoVoucher(voucherID);

                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}