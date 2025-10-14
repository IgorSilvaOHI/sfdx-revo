public class ServicoDoPacote {

    // #region Definições Internas

    public class ServicoDoPacoteCache {
        public String quem;

        public Id produtoId;
        public Id produtoPaiId;
        public Integer quantidadePai;

        public Id origemId;
        public Id destinoId;
        public Id modeloId;
        public DateTime previsaoDecolagem;

        public Id contaId;

        public Integer quantidade;

        public Boolean porPassageiro;

        public ConfiguracaoPacote__c configuracaoPacote;
        public List<RegraPreco__c> regraPrecos;
        public List<RegraProduto__c> regraProdutos;
        public List<RegraDesconto__c> regraDescontos;
        public CodigoPromocional__c codigoPromocional;
        public Boolean codigoJaUtilizado;
        public Boolean primeiraCompra;        
    }

    // #endregion    

    // #region Variáveis Publicas    

    @AuraEnabled
    public Id produto {get; set;} 

    @AuraEnabled
    public String servico {get; set;} 

    @AuraEnabled    
    public Boolean invalido {get; set;}

    @AuraEnabled    
    public Boolean obrigatorio {get; set;}

    @AuraEnabled        
    public Boolean empacotado {get; set;}

    @AuraEnabled        
    public Boolean porPassageiro {get; set;}

    @AuraEnabled        
    public Boolean selecionado {get; set;}

    @AuraEnabled        
    public Integer posicao {get; set;}
    
    @AuraEnabled        
    public Integer quantidadePadrao {get; set;}

    @AuraEnabled        
    public Double precoUnitario {get; set;}

    @AuraEnabled        
    public Double precoRevoSeats {get; set;}

    @AuraEnabled        
    public Integer quantidade {get; set;}

    @AuraEnabled        
    public Decimal descontoPerc {get; set;}

    @AuraEnabled        
    public Decimal descontoValor {get; set;}

    @AuraEnabled        
    public Double precoFinal {get; set;}    

    @AuraEnabled        
    public Double precoFinalRevoSeats {get; set;}

    @AuraEnabled        
    public Id IdPromocional {get; set;}

    @AuraEnabled        
    public String codigoPromocionalApurado {get; set;}
    
    @AuraEnabled        
    public Boolean promocaoValida {get; set;}

    // #endregion    

    // #region Construtor

    public ServicoDoPacote(ServicoDoPacoteCache parameter) 
    {
        carregaDadosServico(parameter);

        carregaDadosPrecoTrecho(parameter);
    }

    // #endregion    

    // #region Métodos Privados

    private void carregaDadosServico(ServicoDoPacoteCache parameter) {
        this.produto = parameter.produtoId;
        this.servico = parameter.configuracaoPacote.ProdutoPacote__r.Name;
        this.obrigatorio = parameter.configuracaoPacote.Obrigatorio__c;
        this.empacotado = parameter.configuracaoPacote.Empacotado__c;
        this.selecionado = parameter.configuracaoPacote.Selecionado__c;
        this.quantidadePadrao = parameter.configuracaoPacote.QuantidadePadrao__c.intValue();
        this.posicao = parameter.configuracaoPacote.Posicao__c.intValue();
        this.porPassageiro = parameter.porPassageiro;
    }

    private void carregaDadosPrecoTrecho(ServicoDoPacoteCache parameter) {

        CalculaPrecosParaPesquisa.CalculaPrecosParaPesquisaResult result = CalculaPrecosParaPesquisa.calculaPrecosServicos(
            parameter.produtoId, parameter.contaId, parameter.quem, parameter.origemId, parameter.destinoId, parameter.previsaoDecolagem, 
            parameter.modeloId, parameter.quantidade, parameter.regraProdutos, parameter.regraPrecos, parameter.regraDescontos, parameter.codigoPromocional,
            parameter.codigoJaUtilizado, parameter.primeiraCompra, true, true
        );

        this.invalido = result.invalido;

        if (this.invalido) return;

        this.precoUnitario = result.precoUnitario;
        this.precoRevoSeats = result.precoRevoSeats;
        this.descontoPerc = result.descontoPerc;
        this.descontoValor = result.descontoValor;
        this.promocaoValida = result.promocaoValida;
        this.idPromocional = result.idPromocional;
        this.codigoPromocionalApurado = result.codigoPromocionalApurado;
        this.precoFinal = result.precoFinal;
        this.precoFinalRevoSeats = result.precoFinalRevoSeats;

        this.quantidade = parameter.quantidade;
        
        if (this.empacotado) {
            this.precoFinal = 0;
            this.precoFinalRevoSeats = 0;
        }
    }
    
    // #endregion
}