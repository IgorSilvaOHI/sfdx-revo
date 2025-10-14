public class VooController 
{
    @AuraEnabled
    public static String getVooWrapper(Id vooId)
    {
        Voo__c voo = getVoo(vooId);
        List<Trecho__c> trechos = getTrechos(vooId);
        return JSON.serialize(new VooWrapper(voo, trechos));
    }
    
    
    @AuraEnabled
    public static Voo__c getVoo(Id vooId)
    {
        return (new VoosSelector(true).selectById(new Set<Id>{vooId}))[0];
    }
    
    @AuraEnabled
    public static List<Trecho__c> getTrechos(Id vooId)
    {
        return new TrechosSelector().selectByVooId(new Set<Id>{vooId});
    }
    
    /*@AuraEnabled
    public static List<Passageiro__c> getPassageiros(Id vooId)
    {
        return new PassageirosSelector().selectByVooId(new Set<Id>{vooId});
    }
    
    @AuraEnabled
    public static List<Carga__c> getCargas(Id vooId)
    {
        return new CargasSelector().selectByVooId(new Set<Id>{vooId});
    }*/

    @AuraEnabled
    public static Boolean checkStatusRascunho(Id vooId)
    {
        return VooService.checkStatusRascunho(vooId);
    }
    
    @AuraEnabled
    public static Boolean validarVoo(Id vooId)
    {
        return VooService.validarVoo(vooId);
    }
    
    @AuraEnabled
    public static Boolean checkPassageirosCargas(Id vooId)
    {
        return VooService.checkPassageirosCargas(vooId);
    }
    
    @AuraEnabled
    public static Boolean checkVooNaoGerenciavel(Id vooId)
    {
        return VooService.checkVooNaoGerenciavel(vooId);
    }
}