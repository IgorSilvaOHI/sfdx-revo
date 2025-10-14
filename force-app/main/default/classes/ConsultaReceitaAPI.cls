public class ConsultaReceitaAPI {
    public static ConsultaReceitaResposta consultar(String cnpj) {
        String url = 'callout:cnpjws/cnpj/{0}';
        
        url = String.format(url, new String[] { cnpj.replaceAll('[^0-9]', '') });
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);
        
        if(response.getStatusCode() == 200) {
            ConsultaReceitaResposta resposta = (ConsultaReceitaResposta) JSON.deserialize(response.getBody(), ConsultaReceitaResposta.class);
            
            return resposta;
        }
        else {
            System.debug('ERROR => ' + response.getBody());
        }
        
        return null;
    }
}