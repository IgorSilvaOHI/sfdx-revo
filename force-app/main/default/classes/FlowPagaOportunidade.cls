public without sharing class FlowPagaOportunidade {

    public class FlowPagaOportunidadeChamada {
        @InvocableVariable(label='Id Pagamento' required=true)
        public Id pagamentoId;

        @InvocableVariable(label='Id Oportunidade' required=true)
        public Id OportunidadeId;
    }    

    @InvocableMethod(label='Paga Oportunidade' description='Processa o pagamento da Oportunidade')
    public static List<String> pagaOportunidade(List<FlowPagaOportunidadeChamada> chamadas) {

        List<String> result = new List<String>();

        for(FlowPagaOportunidadeChamada chamada : chamadas)
        {
            try {
                IPagamentosService service = PagamentosService.service();

                service.confirmaPagamentoOportunidadeComSaldo(chamada.pagamentoId, chamada.oportunidadeId);
                
                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}