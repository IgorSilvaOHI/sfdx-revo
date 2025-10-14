public interface IInteressadosSelector extends fflib_ISObjectSelector
{
    List<Interessado__c> selectById(Set<ID> idSet);
    List<Interessado__c> selectByVoo(Set<Id> voosIds);
    List<Interessado__c> selectConclusaoVooByVoo(Set<Id> voosIds);
    List<Interessado__c> selectReservaByVoo(Set<Id> voosIds);
    List<Interessado__c> selectConclusaoTrechoByVoo(Set<Id> voosIds);
    List<Interessado__c> selectEmissaoEmbarqueByVoo(Set<Id> voosIds);
    List<Interessado__c> selectFaturamentoByVoo(Set<Id> voosIds);
    List<Interessado__c> selectTakeOffReportByVoo(Set<Id> voosIds);
}