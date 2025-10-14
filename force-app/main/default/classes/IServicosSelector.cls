public interface IServicosSelector {

    List<Servico__c> selectByOpportunityId(Set<ID> idSet);

    List<Servico__c> selectById(Set<ID> idSet);

}