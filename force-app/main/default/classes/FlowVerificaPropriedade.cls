public class FlowVerificaPropriedade {
    public class FlowChamada {
        @InvocableVariable(label='Proprietário' required=true)
        public String Id;
    }
    
    public class FlowResposta {
        @InvocableVariable(label='Resposta?' required=false)
        public Boolean Proprietario;
    }        
    
    @InvocableMethod(label='Verifica se o usuário corrente é proprietário ou faz parte da cadeia de propriedade' description='' callout=true)
    public static List<FlowResposta> executar(List<FlowChamada> chamadas) {
        List<FlowResposta> respostas = new List<FlowResposta>();
        
        for(FlowChamada chamada : chamadas) {
            FlowResposta resposta = new FlowResposta();
            
            if (Schema.User.SObjectType == ((Id)chamada.Id).getSobjectType()) {
                resposta.Proprietario = ((Id)chamada.Id) == UserInfo.getUserId();
            } else {
                Map<Id, Set<Id>> mapa = FluxoTrabalhoSecurityUtil.checkOwnerShip(new Set<Id> { chamada.Id });
                
                resposta.Proprietario = mapa.containsKey(chamada.Id) && mapa.get(chamada.Id).contains(UserInfo.getUserId());
            }
            
            respostas.add(resposta);            
        }
        
        return respostas;
    }
}