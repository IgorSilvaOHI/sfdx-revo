public with sharing class FlowCriarLinkPagamentoOportunidade {

    @InvocableMethod(label='Criar Link Pagamento Oportunidade' description='Processa a criação do Link de Pagamento da Oportunidade')
    public static List<String> criarLinkPagamentoOportunidade(List<Id> opportunityIds) {

        List<String> result = new List<String>();

        for(Id opportunityId : opportunityIds)
        {
            try {

                List<Pagamento__c> pagamentosExistentes = PagamentosSelector.newInstance().selectPagamentoPendenteGatewayOppId(new Set<Id> { opportunityId });

                if (pagamentosExistentes.isEmpty()) {
                    throw new LinkdePagamentoNaoExisteException('Pagamento não existe para a oportunidade.');
                }
    
                IPagamentosService service = PagamentosService.service();

                service.criaLinkPagamentoOportunidade(pagamentosExistentes[0].Id);

                result.add('SUCESSO');
            } catch (Exception e) {
                System.debug('Erro ao criar link de pagamento: ' + e.getMessage());
                result.add(e.getMessage());
            }
        }

        return result;
    }
    
    public class LinkdePagamentoNaoExisteException extends Exception { }
}