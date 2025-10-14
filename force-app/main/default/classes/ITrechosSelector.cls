public interface ITrechosSelector extends fflib_ISObjectSelector
{
    List<Trecho__c> selectByVooId(Set<Id> vooId);
    List<Trecho__c> selectByVooIdOrderByOrdemExecucao(Set<Id> voosIds);
    List<Trecho__c> getTrechoWithPassageirosByVooId(Set<Id> voosIds, Set<Id> contatosId);
    List<Trecho__c> selectById(Set<ID> idSet);
    /*List<Trecho__c> getFirstTrechosWithPrefixosInTheDay(List<String> prefixosIds, Date reportDate);
    List<Trecho__c> getTrechosForPassengerImport(Id vooId);*/
    List<Trecho__c> getTrechosByMalha(Id produtoId, Id malhaId, DateTime startdate, DateTime enddate);
}