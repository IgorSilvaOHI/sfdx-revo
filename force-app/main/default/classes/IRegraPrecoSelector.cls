public interface IRegraPrecoSelector {

    Map<Id, List<RegraPreco__c>> selectByIdProducts(Set<ID> idProducts);

}