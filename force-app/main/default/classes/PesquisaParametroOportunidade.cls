public class PesquisaParametroOportunidade {
    // All Filled
    public String quem;
    public Id contaId;
    public Integer quantidade;
    public Product2 produto;
    public DateTime previsaoDeVoo;
    public List<Local__c> locais;
    public List<Aeronave__c> aeronaves;
    public Map<Id, List<Event>> eventosPorAeronave;
    public Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId;
    public List<ConfiguracaoPacote__c> servicosDoProduto;        
    public Map<Id, List<RegraProduto__c>> regrasDosProdutos;
    public Map<Id, List<RegraPreco__c>> regrasDosPrecos;
    public Map<Id, List<RegraDesconto__c>> regrasDeDescontos;
    public CodigoPromocional__c codigoPromocional;
    public Boolean codigoJaUtilizado;
    public Boolean primeiraCompra;
    public Boolean checkOut;
    
    public Map<Id, Integer> servicosContratados;

    // Optional
    public Map<Id, Product2> charter_modelos;
    public List<Trecho__c> malha_trechos;
    public Integer malha_offsetDatas;
    public MalhaVoo__c malha;
}