public with sharing class FlowRecalcularOportunidade {

    @InvocableMethod(label='Recalcula Preço da Oportunidade' description='Consulta novamente os preços e atualiza a oportunidade')
    public static List<String> recalculaOportunidade(List<Id> opportunityIds) {

        List<String> result = new List<String>();

        for(Id oportunidadeID : opportunityIds)
        {
            try {
                IOpportunityService service = OpportunityService.service();

                User currentUser = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId()];

                if (currentUser.IsPartner) {
                    service.recalculaOportunidadeParceiro(oportunidadeID);
                } else {
                    service.recalculaOportunidadetConcierge(oportunidadeID);
                }

                result.add('SUCESSO');
            } catch (Exception e) {
                result.add(e.getMessage());
            }
        }

        return result;
    }

}