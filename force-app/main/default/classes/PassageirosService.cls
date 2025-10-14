global with sharing class PassageirosService 
{		
    @AuraEnabled
    global static String salvarListaPassageiros(List<Id> passageirosVoo, Map<Id, List<Id>> passageirosTrechos, Id vooId){
        return service().salvarListaPassageiros(passageirosVoo, passageirosTrechos, vooId);
    }
    
    private static IPassageirosService service()
    {
        return (IPassageirosService) Application.Service.newInstance(IPassageirosService.class);
    }
}