public interface ICargasSelector extends fflib_ISObjectSelector
{
	List<Carga__c> selectByIdWithTrechosIniciados(Set<ID> idSet);
    Database.QueryLocator queryLocatorCargasDeletadas();
    List<Carga__c> selectByVooId(Set<Id> vooId);
}