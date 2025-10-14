public interface IMissoes extends fflib_ISObjectDomain
{
    Map<Id, Missao__c> criarMissoes(Map<Id, CalculoMissaoResult> mapVooCMR);
}