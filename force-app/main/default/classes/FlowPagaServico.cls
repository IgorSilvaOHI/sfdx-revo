public without sharing class FlowPagaServico {

    public class FlowPagaServicoChamada {
        @InvocableVariable(label='Id Pagamento' required=true)
        public Id pagamentoId;

        @InvocableVariable(label='Id Serviços' required=true)
        public List<Id> servicoIds;
    }    

    @InvocableMethod(label='Paga Serviço' description='Processa o pagamento de um Serviço')
    public static List<String> pagaOportunidade(List<FlowPagaServicoChamada> chamadas) {

        List<String> result = new List<String>();

        for(FlowPagaServicoChamada chamada : chamadas)
        {
            try {
                IPagamentosService service = PagamentosService.service();

                service.confirmaPagamentoServicoComSaldo(chamada.pagamentoId, new Set<Id>(chamada.servicoIds));
                
                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}