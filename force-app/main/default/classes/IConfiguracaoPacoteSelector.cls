public interface IConfiguracaoPacoteSelector {
    
    Map<Id, List<ConfiguracaoPacote__c>> selectByIdProducts(Set<ID> idProducts);

}