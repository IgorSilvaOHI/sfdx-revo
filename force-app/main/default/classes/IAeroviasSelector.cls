public interface IAeroviasSelector extends fflib_ISObjectSelector
{
    List<Aerovia__c> selectByOrigemDestino(Set<Id> origens, Set<Id> destinos);
    List<Aerovia__c> selectWithRetornoByOrigemDestino(Set<Id> origens, Set<Id> destinos);
    List<Aerovia__c> selectById(Set<ID> idSet);
}