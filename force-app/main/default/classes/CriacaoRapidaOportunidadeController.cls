public with sharing class CriacaoRapidaOportunidadeController {

    @InvocableMethod(label='Criação de oportunidade rápida' description='Criação de oportunidade rápida')
    public static List<Opportunity> Criar(List<CriacaoRapidaWrapper> criacaoRapida){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Opportunity> lstOportunidade = new List<Opportunity>();

        for(CriacaoRapidaWrapper param : criacaoRapida){
            String codigoReserva = '';
        
            do{
                codigoReserva = TextUtils.generateBookingCode(6);
            }while (OpportunitySelector.newInstance().codigoReservaUtilizado(codigoReserva));

            lstOportunidade.add(Opportunities.criaOportunidade(
                uow, 
                param.idConta,
                param.idConta,
                param.fullName,
                param.oppotunityType, 
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
        @InvocableVariable public String oppotunityType;
    }
}