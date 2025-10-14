public without sharing class Servicos extends fflib_SObjectDomain implements IServicos {    
   
    private enum TiposDeServicos {
        ShuttleSeat, FullCabin, CharterFlight, ServicosTaxas
    }        

    public Servicos(List<Servico__c> sObjectList) {
        super(sObjectList);
    }

    public static IServicos newInstance(List<Servico__c> sObjectList) {
        return (IServicos) Application.Domain.newInstance(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Servicos(sObjectList);
        }
    }


    public static Servico__c criarServicoParceiro(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, CodigoPromocional__c promocao
    ) {
        Map<String, Id> mapServicosTypes = servicoRecordTypesNameIds();

        Servico__c servico = new Servico__c();
        servico.RecordTypeId = mapServicosTypes.get('CobrancaParceiro');
        servico.Status__c = 'Aguardando Execução';
        servico.ContaComprador__c = oportunidade.AccountId;
        servico.ContaFaturamento__c = promocao.Parceiro__c;
        servico.Oportunidade__c = oportunidade.Id;
        servico.ValorTotal__c = promocao.ValorCobrancaParceiro__c;
        servico.DataServico__c = Date.today();
        servico.PromocaoParceiro__c = promocao.Id;

        uow.registerNew(servico);        

        return servico;
    }    

    public static Servico__c criarServicoOportunidadeRevoSeats(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem line, 
        Decimal valorTotal
    ) {
        Map<Id, String> mapProductsTypes = productRecordTypesIds();
        Map<String, Id> mapServicosTypes = servicoRecordTypesNameIds();

        Servico__c servico = new Servico__c();
        servico.RecordTypeId = mapServicosTypes.get(mapProductsTypes.get(line.Product2.RecordTypeId));
        servico.Status__c = 'PreReservado';
        servico.Produto__c = line.Product2Id;
        servico.ContaComprador__c = oportunidade.AccountId;
        servico.ContaFaturamento__c = oportunidade.FaturadoPara__c;
        servico.Oportunidade__c = oportunidade.Id;
        servico.ProdutoOportunidade__c = line.Id;
        servico.ValorTotal__c = valorTotal;
        servico.DataServico__c = Date.today();

        uow.registerNew(servico);        

        return servico;
    }

    public static Servico__c criarServicoOportunidade(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem line, 
        Voo__c voo, Trecho__c trecho, Passageiro__c pasageiro, Decimal valorTotal, Decimal valorTotalRevoSeats
    ) {
        return criarServicoOportunidade(uow, oportunidade, line, voo, trecho, pasageiro, valorTotal, valorTotalRevoSeats, null, null, null, null, null, null,
        null, null, null, null, null, null);
    }

    public static Servico__c criarServicoOportunidade(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem line, 
        Voo__c voo, Trecho__c trecho, Passageiro__c pasageiro, Decimal valorTotal, Decimal valorTotalRevoSeats, String observacoes, String enderecoServico,
        String cidadeServico, String estadoServico, String paisServico, String complementoEndereco,
        String CEPServico, String companhiaAerea, String numeroVoo, Decimal qtdsMalasGrandes, 
        Decimal qtdsMalasMedias, Decimal qtdsMalasPequenas
    ) {
        Map<Id, String> mapProductsTypes = productRecordTypesIds();
        Map<String, Id> mapServicosTypes = servicoRecordTypesNameIds();

        Servico__c servico = new Servico__c();
        servico.RecordTypeId = mapServicosTypes.get(mapProductsTypes.get(line.Product2.RecordTypeId));
        servico.Status__c = 'PreReservado';
        servico.Produto__c = line.Product2Id;
        servico.ContaComprador__c = oportunidade.AccountId;
        servico.ContaFaturamento__c = oportunidade.FaturadoPara__c;
        servico.Oportunidade__c = oportunidade.Id;
        servico.ProdutoOportunidade__c = line.Id;
        servico.ValorTotal__c = valorTotal;
        servico.TotalRevoSeats__c = valorTotalRevoSeats;
        servico.DataServico__c = voo.DataVoo__c;

        servico.Observacoes__c = observacoes;
        servico.EnderecoServico__c = enderecoServico;
        servico.CidadeServico__c = cidadeServico;
        servico.EstadoServico__c = estadoServico;
        servico.ComplementoEndereco__c = complementoEndereco;
        servico.CEPServico__c = CEPServico;
        servico.PaisServico__c = paisServico;
        servico.CompanhiaAerea__c = companhiaAerea;
        servico.NumeroVoo__c = numeroVoo; 
        servico.QtdsMalasGrandes__c = qtdsMalasGrandes;
        servico.QtdsMalasMedias__c = qtdsMalasMedias;
        servico.QtdsMalasPequenas__c = qtdsMalasPequenas;

        uow.registerNew(servico);        
        uow.registerRelationship(servico, Servico__c.Voo__c, voo);

        if (trecho != null) {
            uow.registerRelationship(servico, Servico__c.Trecho__c, trecho);
        }

        if (pasageiro != null) {
            uow.registerRelationship(servico, Servico__c.Passageiro__c, pasageiro);
        }

        return servico;
    }    

    private static Map<Id, String> productRecordTypesIds() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Map<Id, String> result = new Map<Id, String>();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            result.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
        }

        return result;
    }    

    private static Map<String, Id> servicoRecordTypesNameIds() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Servico__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Map<String, Id> result = new Map<String, Id>();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            result.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
        }

        return result;
    }    

}