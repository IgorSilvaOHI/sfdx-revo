global class PassageirosVooService {

    @AuraEnabled(cacheable=false)
    public static String getPassageirosVoo(Id vooId)
    {
        return service().getPassageirosVoo(vooId);
    }
    
    public static IPassageirosVooService service()
    {
        return (IPassageirosVooService) Application.Service.newInstance(IPassageirosVooService.class);
    }
}