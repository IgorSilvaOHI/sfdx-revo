public class BlocoFullCabin {

    // #region Variáveis Publicas

    @AuraEnabled    
    public DateTime	data {get; set;}

    @AuraEnabled    
    public String 	horaFormatada {get; set;}

    @AuraEnabled    
    public Integer  intervalo {get; set;}

    @AuraEnabled    
    public Boolean 	invalido {get; set;}

    @AuraEnabled    
    public Double 	tempoMissao {get; set;}

    @AuraEnabled    
    public Integer 	aeronavesDisponiveis {get; set;}

    @AuraEnabled    
    public Id 	aeronave {get; set;}

    @AuraEnabled    
    public Id 	modeloId {get; set;}
    
    @AuraEnabled    
    public Decimal precoUnitario {get; set;}

    @AuraEnabled    
    public Decimal precoRevoSeats {get; set;}

    @AuraEnabled    
    public Decimal descontoPerc {get; set;}

    @AuraEnabled    
    public Decimal descontoValor {get; set;}

    @AuraEnabled    
    public Decimal precoFinal {get; set;}

    @AuraEnabled    
    public Decimal precoFinalRevoSeats {get; set;}

    @AuraEnabled    
    public Id idPromocional {get; set;}

    @AuraEnabled    
    public String codigoPromocionalApurado {get; set;}

    @AuraEnabled    
    public Boolean promocaoValida {get; set;}

    @AuraEnabled
    public List<ServicoDoPacote> servicos {get; set;}        

    // #endregion

    // #region Construtor

    public BlocoFullCabin (DateTime data, Integer intervalo) {

        this.data = data;
        this.intervalo = intervalo;
        this.invalido = false;
        this.horaFormatada = data.hour() + ':' + (data.minute() >= 10 ? String.valueOf(data.minute()) : '0'+data.minute());
    }

    // #endregion

    // #region Métodos Publicos

    public void setBlocoFullCabin (
        Id productId, Id modeloId, String quem, Id contaId,
        List<Aeronave__c> aeronaves, Map<Id, List<Event>> eventosPorAeronave,
        Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, List<ConfiguracaoPacote__c> pacotesDosModelos, 
        Map<Id, List<RegraProduto__c>> regrasDosProdutos, Map<Id, List<RegraPreco__c>> regrasDosPrecos, 
        Map<Id, List<RegraDesconto__c>> regrasDeDescontos, CodigoPromocional__c codigo,
        Boolean codigoJaUtilizado, Boolean primeiraCompra, Map<Id, Integer> servicosContratados
    ) {
        carregaDadosFullCabin(
            productId, quem, modeloId, aeronaves, cmrsMapByAeronaveId, eventosPorAeronave
        );

        carregaDadosPreco(
            productId, modeloId, quem, contaId, regrasDosProdutos, regrasDosPrecos, regrasDeDescontos, codigo, codigoJaUtilizado, primeiraCompra
        );

        carregaDadosServicos(
            productId, modeloId, quem, contaId, pacotesDosModelos, regrasDosProdutos, regrasDosPrecos, 
            regrasDeDescontos, codigo, codigoJaUtilizado, primeiraCompra, cmrsMapByAeronaveId, aeronaves, servicosContratados
        );
    }

    // #endregion

    // #region Métodos Privados

    private void carregaDadosFullCabin (
        Id productId, String quem, Id modeloId, 
        List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, 
        Map<Id, List<Event>> eventosPorAeronave
    ) 
    {
        this.aeronavesDisponiveis = 0;
        this.tempoMissao = 0;

        this.precoUnitario = 0;
        this.precoRevoSeats = 0;
        this.descontoPerc = 0;
        this.descontoValor = 0;

        this.modeloId = modeloId;

        Integer aeronavesValidas = 0;

        for(Aeronave__c aeronave : aeronaves)
        {
            CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronave.Id);
            if(calculo.tempoMissao > this.tempoMissao)
            {
                this.tempoMissao = calculo.tempoMissao;
            }
            List<Event> eventosDaAeronave = eventosPorAeronave.get(aeronave.Id);

            Integer podeVoar = EventsService.podeExecutarVoo(calculo, this.data, eventosDaAeronave, new Voo__c(Tipo__c = 'FullCabin'));

            if (podeVoar > 0) {
                if (this.data > cmrsMapByAeronaveId.get(aeronave.Id).hrMaximoDecolagem) {
                    podeVoar = 0;
                }
            }

            if(podeVoar > 0)
            {
                if (this.aeronave == null) {
                    this.aeronave = aeronave.Id;
                }

                aeronavesValidas++;
                this.aeronavesDisponiveis++;
            }else {
                this.aeronavesDisponiveis += Math.abs(podeVoar);
            }
        }

        this.invalido = this.invalido || aeronavesValidas == 0;
    }

    private void carregaDadosPreco (
        Id productId, Id modeloId, String quem, Id contaId, Map<Id, List<RegraProduto__c>> regrasDosProdutos,
        Map<Id, List<RegraPreco__c>> regrasDosPrecos, Map<Id, List<RegraDesconto__c>> regrasDeDescontos, 
        CodigoPromocional__c codigo, Boolean codigoJaUtilizado, Boolean primeiraCompra
    ) 
    {

        List<RegraProduto__c> regrasProdutos = regrasDosProdutos.containsKey(productId) ? regrasDosProdutos.get(productId) : new List<RegraProduto__c>();
        List<RegraPreco__c> regrasPrecos = regrasDosPrecos.containsKey(productId) ? regrasDosPrecos.get(productId) : new List<RegraPreco__c>();
        List<RegraDesconto__c> regrasDescontos = regrasDeDescontos.containsKey(productId) ? regrasDeDescontos.get(productId) : new List<RegraDesconto__c>();

        CalculaPrecosParaPesquisa.CalculaPrecosParaPesquisaResult result = CalculaPrecosParaPesquisa.calculaPrecosVoos(
            productId, contaId, quem, null, null, this.data, this.modeloId, 1, 
            regrasProdutos, regrasPrecos, regrasDescontos, codigo, 
            codigoJaUtilizado, primeiraCompra, true, false
        );

        this.invalido = this.invalido || result.invalido;

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
    }

    private void carregaDadosServicos(
        Id productId, Id modeloId, String quem, Id contaId, List<ConfiguracaoPacote__c> configuracaoPacotes,
        Map<Id, List<RegraProduto__c>> regrasDosProdutos, Map<Id, List<RegraPreco__c>> regrasDosPrecos, 
        Map<Id, List<RegraDesconto__c>> regrasDeDescontos, CodigoPromocional__c codigo,
        Boolean codigoJaUtilizado, Boolean primeiraCompra,
        Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, List<Aeronave__c> aeronaves, Map<Id, Integer> servicosContratados
    ) 
    {
        CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronaves[0].Id);

        Id origemId = calculo.trajeto.isEmpty() ? null : calculo.trajeto[0].Id;
        Id destinoId = calculo.trajeto.isEmpty() ? null : calculo.trajeto[calculo.trajeto.size() - 1].Id;

        this.servicos = new List<ServicoDoPacote>();

        for (ConfiguracaoPacote__c config : configuracaoPacotes) {

            ServicoDoPacote.ServicoDoPacoteCache cache = new ServicoDoPacote.ServicoDoPacoteCache();

            cache.quem = quem;
            cache.produtoId = config.ProdutoPacote__c;
            cache.produtoPaiId = productId;
            cache.quantidadePai = 1;

            cache.origemId = origemId;
            cache.destinoId = destinoId;
            cache.modeloId = modeloId;
            cache.previsaoDecolagem = this.data;

            cache.contaId = contaId;
            cache.quantidade = config.QuantidadeRelativa__c == 'Pelo Padrão' ? config.QuantidadePadrao__c.intValue() : cache.quantidadePai;
            cache.quantidade = servicosContratados.containsKey(config.ProdutoPacote__c) ? servicosContratados.get(config.ProdutoPacote__c) : cache.quantidade;
            cache.configuracaoPacote = config;
            cache.porPassageiro = config.QuantidadeRelativa__c != 'Pelo Padrão';

            cache.regraPrecos = regrasDosPrecos.containsKey(config.ProdutoPacote__c) ? regrasDosPrecos.get(config.ProdutoPacote__c) : new List<RegraPreco__c>();
            cache.regraProdutos = regrasDosProdutos.containsKey(config.ProdutoPacote__c) ? regrasDosProdutos.get(config.ProdutoPacote__c) : new List<RegraProduto__c>();
            cache.regraDescontos = regrasDeDescontos.containsKey(config.ProdutoPacote__c) ? regrasDeDescontos.get(config.ProdutoPacote__c) : new List<RegraDesconto__c>();
            cache.codigoPromocional = codigo;
            cache.codigoJaUtilizado = codigoJaUtilizado;
            cache.primeiraCompra = primeiraCompra;

            ServicoDoPacote servico = new ServicoDoPacote(cache);

            if (!servico.invalido) this.servicos.add(servico);
        }        
    }   

    // #endregion
    
}