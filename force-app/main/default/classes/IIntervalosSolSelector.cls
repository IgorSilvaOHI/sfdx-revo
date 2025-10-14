public interface IIntervalosSolSelector extends fflib_ISObjectSelector {
	List<IntervaloSol__c> selectById(Set<ID> idSet);
    List<IntervaloSol__c> selectAllFuture();
}