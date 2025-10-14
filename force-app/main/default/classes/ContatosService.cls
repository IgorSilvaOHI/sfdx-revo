global class ContatosService
{
    
	@AuraEnabled(cacheable=false)
    public static String getContatosNaoInclusos(List<Id> contatosId, String filtro)
    {
        return service().getContatosNaoInclusos(contatosId, filtro);
    }
    
    public static IContatosService service()
    {
        return (IContatosService) Application.Service.newInstance(IContatosService.class);
    }
}