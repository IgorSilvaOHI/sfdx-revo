public interface IMissoesSelector extends fflib_ISObjectSelector {
	List<Missao__c> selectById(Set<ID> idSet);
}