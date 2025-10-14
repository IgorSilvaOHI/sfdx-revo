public with sharing class FlowCriarPagamentoOportunidade {

    public class FlowCriarPagamentoOportunidadeResultado {
        @InvocableVariable(label='Pagamento ID' required=false)
        @AuraEnabled
        public Id idPagamento;

        @InvocableVariable(label='Sucesso' required=false)
        @AuraEnabled
        public Boolean sucesso;

        @InvocableVariable(label='Mensagem' required=false)
        @AuraEnabled
        public String mensagem;

        public FlowCriarPagamentoOportunidadeResultado(Id idPagamento, Boolean sucesso, String mensagem) {
            this.idPagamento = idPagamento;
            this.sucesso = sucesso;
            this.mensagem = mensagem;
        }
    }    

    @InvocableMethod(label='Criar Pagamento Oportunidade' description='Processa a criação do Pagamento da Oportunidade')
    public static List<FlowCriarPagamentoOportunidadeResultado> criarPagamentoOportunidade(List<Id> opportunityIds) {

        List<FlowCriarPagamentoOportunidadeResultado> result = new List<FlowCriarPagamentoOportunidadeResultado>();

        for(Id oportunidadeID : opportunityIds)
        {
            try {
                IPagamentosService service = PagamentosService.service();

                Pagamento__c pagamento = service.criaPagamentoOportunidade(oportunidadeID);

                result.add(new FlowCriarPagamentoOportunidadeResultado(pagamento.Id, true, null));
            } catch (Exception e) {
                result.add(new FlowCriarPagamentoOportunidadeResultado(null, false, e.getMessage()));
            }
        }

        return result;
    }
}