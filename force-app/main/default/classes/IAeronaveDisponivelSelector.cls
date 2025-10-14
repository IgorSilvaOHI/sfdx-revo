public interface IAeronaveDisponivelSelector {

    List<AeronaveDisponivel__c> aeronavesPorProduto(Set<Id> idProducts);

}