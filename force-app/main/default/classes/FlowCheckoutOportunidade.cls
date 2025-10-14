public with sharing class FlowCheckoutOportunidade {

        @InvocableMethod(label='Efetua Checkout da Oportunidade' description='Processa dados da oportunidade, valida e efetua reservas dos serviços')
        public static List<String> checkoutOportunidade(List<Id> opportunityIds) {
    
            List<String> result = new List<String>();
    
            for(Id oportunidadeID : opportunityIds)
            {
                try {

                    IOpportunityService service = OpportunityService.service();

                    User currentUser = [SELECT Id, IsPartner FROM User WHERE Id = :UserInfo.getUserId()];

                    if (currentUser.IsPartner) {
                        service.checkoutOportunidadeParceiro(oportunidadeID);
                    } else {
                        service.checkoutOportunidadetConcierge(oportunidadeID);
                    }

                    result.add('SUCESSO');
                } catch (Exception e) {
                    System.debug('Erro ao efetuar checkout da oportunidade: ' + e.getMessage());
                    result.add(e.getMessage());
                }
            }
    
            return result;
        }
    
    }