public interface IRegraDescontoSelector {

    Map<Id, List<RegraDesconto__c>> selectByIdProducts(Set<ID> idProducts);

}