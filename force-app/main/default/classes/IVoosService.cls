public interface IVoosService 
{
    void undeleteVoos(Set<Id> voosId);
    void countPassengers(List<Id> vooIds);
    List<Voo__c> getVoos(Set<Id> voosId);
}