public interface IVoosSelector extends fflib_ISObjectSelector
{
    List<Voo__c> selectById(Set<ID> idSet);
	List<Voo__c> selectByIdWithLead(Set<Id> idSet);
    List<Voo__c> selectWithTrechosById(Set<Id> vooId);
    List<Voo__c> selectRecentsWithTrechos();
    List<Voo__c> getVoosAmanhaByStatus(String status);
    List<Voo__c> selectDeletedById(Set<Id> idSet);
    List<Voo__c> selectByIdWithCombinedAttachments(Set<Id> ids);
    List<Voo__c> selectByIdToInteressadosFaturamento(Set<Id> ids);
    List<Voo__c> selectWithPrefixosAndBetweenDates(Set<Id> prefixosIds, Date menorData, Date maiorData);
    List<Voo__c> selectRastreaveisBetweenDates(Datetime menorData, Datetime maiorData);
    List<Voo__c> selectWithPrimeiroTrechoById(Set<Id> vooId);
    List<Voo__c> selectByAccountAndBetweenDates(Set<Id> accountIds, Date startDate, Date endDate);
}