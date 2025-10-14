public without sharing class PagamentosService {

    public static IPagamentosService service()
    {
        return (IPagamentosService) Application.Service.newInstance(IPagamentosService.class);
    }	    

}