global without sharing class InteressadosService {
    @TestVisible
    private static IInteressadosService service()
    {
        return (IInteressadosService) Application.Service.newInstance(IInteressadosService.class);
    }
	
    @InvocableMethod(label='Interessados - Cria Interessados' description='Cria Interessados quando um Voo é criado, definindo os Interesses a partir do Contato')
    public static void criarInteressados(List<Id> voosIdList)
    {
        service().criarInteressados(new Set<Id>(voosIdList));
    }
}