public class FlowConsultarReceita {
    public class FlowChamada {
        @InvocableVariable(label='CNPJ' required=true)
        public String cnpj;
        
        @InvocableVariable(label='Resposta JSON Formatada' required=true)
        public Boolean jsonFormatado;
    }
    
    public class FlowResposta {
		@InvocableVariable(label='Resposta' required=true)
        public ConsultaReceitaResposta resposta;
        
        @InvocableVariable(label='Resposta JSON' required=false)
        public String respostaJSON;
    }
    
    @InvocableMethod(label='Consultar Dados da Receita Federal' description='' callout=true)
    public static List<FlowResposta> consultar(List<FlowChamada> chamadas) {
        List<FlowResposta> respostas = new List<FlowResposta>();
        
        for(FlowChamada chamada : chamadas) {
            FlowResposta resposta = new FlowResposta();
            
            resposta.resposta = ConsultaReceitaAPI.consultar(chamada.cnpj);
            resposta.respostaJSON = chamada.jsonFormatado ? JSON.serializePretty(resposta.resposta) : JSON.serialize(resposta.resposta);
            
            respostas.add(resposta);
        }
        
        return respostas;
    }
}