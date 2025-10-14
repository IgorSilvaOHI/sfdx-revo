public interface IPassageirosService 
{
    String salvarListaPassageiros(List<Id> passageirosVoo, Map<Id, List<Id>> passageirosTrechos, Id vooId);
    List<Passageiro__c> getPassageirosByVooId(List<Id> vooIds);
}