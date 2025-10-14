public interface IOpportunitySelector {

    Boolean primeiraCompraConta(Id contaId);
    Boolean codigoPromocionalUsadoNaConta(Id contaId, String codigoPromocional);    
    Boolean idPromocionalUsadoNaConta(Id contaId, Id codigoPromocionalId);    
    List<Opportunity> selectById(Set<Id> opportunityIds);
    Opportunity encontraParaFechamento(Id opportunityId);
    Opportunity encontraParaCancelamento(Id opportunityId);
    Opportunity encontraParaPagamento(Id opportunityId);
    Opportunity encontraParaMudarPromocao(Id opportunityId);
    Boolean codigoReservaUtilizado(string bookingCode);
}