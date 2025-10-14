public interface IPassageirosSelector extends fflib_ISObjectSelector 
{
	//List<PassageirosSelector.PassageiroInfo> selectPassageiroInfo(Set<ID> idSet);
    List<Passageiro__c> selectByIdWithTrechosIniciados(Set<ID> idSet);
    List<Passageiro__c> selectByVooId(Set<Id> vooId);
    List<Passageiro__c> selectById(Set<ID> idSet);
    //List<Passageiro__c> getPassageirosByContactIdsAndVooIds(Set<Id> idsContato, Set<Id> idsVoo);
}