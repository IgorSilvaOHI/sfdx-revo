public interface IPassageirosVooSelector {
	List<PassageiroVoo__c> selectByVooId(Set<Id> voosId);
}