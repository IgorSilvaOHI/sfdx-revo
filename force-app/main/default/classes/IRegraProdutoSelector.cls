public interface IRegraProdutoSelector {

    Map<Id, List<RegraProduto__c>> selectByIdProducts(Set<ID> idProducts);
    
}