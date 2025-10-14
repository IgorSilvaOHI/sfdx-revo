public interface IAeronaves extends fflib_ISObjectDomain
{
    Map<Id, List<Aeronave__c>> getPorModelo();
    Map<String, Aeronave__c> getPorPrefixo();
}