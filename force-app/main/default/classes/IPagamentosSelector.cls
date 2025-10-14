public interface IPagamentosSelector extends fflib_ISObjectSelector 
{
    List<Pagamento__c> selectById(Set<ID> idSet);
    List<Pagamento__c> selectPagamentoPendenteGatewayOppId(Set<ID> idSet);

    Pagamento__c selectPagamentoGateway(Id pagamentoId);
}