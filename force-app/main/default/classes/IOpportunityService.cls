public interface IOpportunityService {

    List<PesquisaMalha> pesquisaMalhaVoosCliente(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo);
    List<PesquisaMalha> pesquisaMalhaVoosParceiro(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo);
    List<PesquisaMalha> pesquisaMalhaVoosConcierge(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo);

    PesquisaMalha resumoMalhaVoosCliente(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);
    PesquisaMalha resumoMalhaVoosParceiro(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);
    PesquisaMalha resumoMalhaVoosConcierge(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);

    List<PesquisaCharter> pesquisaChartCliente(List<Local__c> trajeto, DateTime data, Id contaId, String codigoPromocionalInfo);
    List<PesquisaCharter> pesquisaChartParceiro(List<Local__c> locaisTrajeto, DateTime data, Id contaId, String codigoPromocionalInfo);
    List<PesquisaCharter> pesquisaChartConcierge(List<Local__c> locaisTrajeto, DateTime data, Id contaId, String codigoPromocionalInfo);

    PesquisaCharter resumoChartCliente(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);
    PesquisaCharter resumoChartParceiro(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);
    PesquisaCharter resumoChartConcierge(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);//TODO REFATORAR REFERENCIAS

    List<PesquisaFullCabin> pesquisaFullCabinCliente(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo);
    List<PesquisaFullCabin> pesquisaFullCabinParceiro(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo);
    List<PesquisaFullCabin> pesquisaFullCabinConcierge(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo);

    PesquisaFullCabin resumoFullCabinCliente(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);       
    PesquisaFullCabin resumoFullCabinParceiro(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);       
    PesquisaFullCabin resumoFullCabinConcierge(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo);       

    void checkoutOportunidadeParceiro(Id oportunidadeID);
    void checkoutOportunidadetConcierge(Id oportunidadeID);

    void recalculaOportunidadeParceiro(Id oportunidadeID);
    void recalculaOportunidadetConcierge(Id oportunidadeID);

    void cancelarOportunidade(Id oportunidadeID);
    void aplicarModeloPromocaoOportunidade(Id oportunidadeID, Id promocaoModeloId, String codigoPromocaoParceiro);
    Opportunity visualizarPromocaoOportunidade(Id oportunidadeID, Id promocaoId);
}