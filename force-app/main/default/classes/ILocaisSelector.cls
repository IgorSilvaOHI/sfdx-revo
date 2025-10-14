public interface ILocaisSelector extends fflib_ISObjectSelector
{
	Schema.SObjectType getSObjectType();
    List<Local__c> selectById(Set<ID> idSet);
}