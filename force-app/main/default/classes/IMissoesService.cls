public interface IMissoesService 
{
    Map<Id, Missao__c> criarMissoes(fflib_ISObjectUnitOfWork uow, Map<Id, CalculoMissaoResult> mapVooCMR);
}