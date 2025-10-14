public with sharing class FlowCancelarOportunidade {

    @InvocableMethod(label='Cancelar Oportunidade' description='Processa o cancelamento da Oportunidade')
    public static List<String> cancelarOportunidade(List<Id> opportunityIds) {

        List<String> result = new List<String>();

        for(Id oportunidadeID : opportunityIds)
        {
            try {
                IOpportunityService service = OpportunityService.service();

                service.cancelarOportunidade(oportunidadeID);

                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}