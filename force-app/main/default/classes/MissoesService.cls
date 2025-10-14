global with sharing class MissoesService 
{    
    public static Map<Id, Missao__c> criarMissoes(fflib_ISObjectUnitOfWork uow, Map<Id, CalculoMissaoResult> mapVooCMR)
    {
        return service().criarMissoes(uow, mapVooCMR);
    }
    
    private static IMissoesService service()
    {
        return (IMissoesService) Application.Service.newInstance(IMissoesService.class);
    }
}