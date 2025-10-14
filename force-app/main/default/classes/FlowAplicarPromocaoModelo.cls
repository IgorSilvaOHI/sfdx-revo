public with sharing class FlowAplicarPromocaoModelo {


    public class FlowAplicarPromocaoModeloChamada {
        @InvocableVariable(label='Id Oportunidade' required=true)
        public Id opportunityId;

        @InvocableVariable(label='Id promocao modelo' required=true)
        public Id promotionModelId;

        @InvocableVariable(label='Codigo promocional' required=true)
        public String promotionCode;
    }    


    @InvocableMethod(label='Aplicar Promocao Modelo na oportunidade' description='Processa a aplicação da Promocao Modelo')
    public static List<String> aplicarPromocaoModelo(List<FlowAplicarPromocaoModeloChamada> chamadas) {

        List<String> result = new List<String>();

        for(FlowAplicarPromocaoModeloChamada chamada : chamadas)
        {
            try {
                IOpportunityService service = OpportunityService.service();

                service.aplicarModeloPromocaoOportunidade(chamada.opportunityId, chamada.promotionModelId, chamada.promotionCode);

                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}