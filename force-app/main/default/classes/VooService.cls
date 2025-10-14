public class VooService
{    
    public static Voo__c getVooById(Id vooId)
    {
        return VooSelector.getVooById(vooId);
    }
    
    public static Boolean checkStatusRascunho(Id vooId){
        Voo__c voo = VooSelector.getVooById(vooId);
        VooDomain vooDomain = new VooDomain();
        return vooDomain.checkStatusRascunho(voo);
    }
    
    public static Boolean validarVoo(Id vooId){
        Voo__c voo = VooSelector.getVooById(vooId);
        VooDomain vooDomain = new VooDomain();
        return vooDomain.checkStatusRascunho(voo);
    }
    
    public static Boolean checkPassageirosCargas(Id vooId){
        Voo__c voo = VooSelector.getVooById(vooId);
        VooDomain vooDomain = new VooDomain();
        return vooDomain.checkPassageirosCargas(voo);
    }
    
    public static Boolean checkVooNaoGerenciavel(Id vooId){
        Voo__c voo = VooSelector.getVooById(vooId);
        VooDomain vooDomain = new VooDomain();
        return vooDomain.checkVooNaoGerenciavel(voo);
    }

}