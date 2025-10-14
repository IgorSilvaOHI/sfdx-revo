public with sharing class FlowCriacaoRapidaRevoSeats {

    @InvocableMethod(label='Criação de oportunidade Revo Seats' description='Criação de oportunidade Revo Seats')
    public static List<Opportunity> Criar(List<CriacaoRapidaWrapper> criacaoRapida){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Opportunity> lstOportunidade = new List<Opportunity>();

        for(CriacaoRapidaWrapper param : criacaoRapida){
            String codigoReserva = '';
        
            do{
                codigoReserva = TextUtils.generateBookingCode(6);
            }while (OpportunitySelector.newInstance().codigoReservaUtilizado(codigoReserva));

            lstOportunidade.add(Opportunities.criaOportunidadeRevoSeats(
                uow, 
                param.idConta,
                param.idConta,
                param.fullName,
                param.idCodigoPromocional,
                codigoReserva,
                'Salesforce'
            ));
        }
        
        uow.commitWork();

        return lstOportunidade;
    }
    
    public class CriacaoRapidaWrapper{
        @InvocableVariable public String idConta;
        @InvocableVariable public String fullName;
        @InvocableVariable public String idCodigoPromocional;
    }
}