public class RevoSiteApi {

    public static void standardBadResult(Exception e) { 
        RestContext.response.statusCode = 500;

        String codigo = 'API-0000';

        if (e instanceof RevoSiteApiException) {
            codigo = ((RevoSiteApiException)e).codigo;
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(
            JSON.serialize(new Map<String, String>{
                'status' => 'Error',
                'code' => codigo,
                'message' => e.getMessage()
            })
        );

        System.debug('Message: ' + e.getMessage());    
        System.debug('Cause: ' + e.getCause());    
        System.debug('Line number: ' + e.getLineNumber());    
        System.debug('Stack trace: ' + e.getStackTraceString());          
    }

    public virtual class RevoSiteApiException extends Exception {
        public String codigo;
    
        public RevoSiteApiException(String codigo, String mensagem) {
            this(codigo + ': ' + mensagem);
            this.codigo = codigo;
        }
    }    

    public class UsuarioNaoEncontradoException extends RevoSiteApiException {
        public UsuarioNaoEncontradoException(Boolean voidParam) {
            super('API-0001','Usuário Não Encontrado!');
        }
    }

}