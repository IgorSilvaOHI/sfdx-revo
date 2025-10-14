public class BlocoCharter {

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
    public Double tempoTransladoIda {get; set;}

    @AuraEnabled         
    public Double tempoTransladoRetorno {get; set;}

    @AuraEnabled    
    public Double tempoMissao {get; set;}

    @AuraEnabled    
    public Integer aeronavesDisponiveis {get; set;}

    @AuraEnabled    
    public Aeronave__c 	aeronave {get; set;}
    
    @AuraEnabled    
    public Id modeloId {get; set;}

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
    public Id origemInicial {get; set;} 

    @AuraEnabled 
    public Id destinoFinal {get; set;} 

    @AuraEnabled    
    public List<ServicoDoPacote> servicos {get; set;}
    
    private Set<Id> servicosIds;
    private List<Local__c> trajeto;
    // #endregion

    // #region Construtor

    public BlocoCharter (DateTime data, Integer intervalo) {

        this.data = data;
        this.intervalo = intervalo;
        this.invalido = false;
        this.horaFormatada = data.hour() + ':' + (data.minute() >= 10 ? String.valueOf(data.minute()) : '0'+data.minute());
        this.servicosIds = new Set<Id>();
    }

    // #endregion

    // #region Métodos Publicos

    public void setBlocoCharter (
        Id produtoId, Id modeloId, String quem, Id contaId,
        List<Aeronave__c> aeronaves, Map<Id, List<Event>> eventosPorAeronave,
        Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, List<ConfiguracaoPacote__c> pacotesDosModelos, 
        Map<Id, List<RegraProduto__c>> regrasDosProdutos, Map<Id, List<RegraPreco__c>> regrasDosPrecos, 
        Map<Id, List<RegraDesconto__c>> regrasDeDescontos, CodigoPromocional__c codigo,
        Boolean codigoJaUtilizado, Boolean primeiraCompra, Map<Id, Integer> servicosContratados
    ) {
        carregaDadosCharter(
            produtoId, quem, modeloId, aeronaves, cmrsMapByAeronaveId, eventosPorAeronave
        );

        carregaDadosPreco(
            produtoId, modeloId, quem, contaId, regrasDosProdutos, regrasDosPrecos, regrasDeDescontos, codigo, codigoJaUtilizado, primeiraCompra
        );

        this.servicos = new List<ServicoDoPacote>();

        // Itera de 0 até o penúltimo índice
        for (Integer i = 0; i < this.trajeto.size() - 1; i++) {
            Local__c origem = this.trajeto[i];
            Local__c destino = this.trajeto[i + 1];
            
            carregaDadosServicos(
                produtoId, modeloId, quem, contaId, pacotesDosModelos, regrasDosProdutos, regrasDosPrecos, 
                regrasDeDescontos, codigo, codigoJaUtilizado, primeiraCompra, cmrsMapByAeronaveId, aeronaves, servicosContratados,
                origem, destino
            );
        }
    }

    // #endregion

    // #region Métodos Privados

    private void carregaDadosCharter (
        Id produtoId, String quem, Id modeloId,
        List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, 
        Map<Id, List<Event>> eventosPorAeronave
    ) 
    {

        this.aeronavesDisponiveis = 0;
        this.tempoMissao = 0;
        this.tempoTransladoIda = 0;
        this.tempoTransladoRetorno = 0;

        this.precoUnitario = 0;
        this.descontoPerc = 0;
        this.descontoValor = 0;
        this.modeloId = modeloId;

        CalculoMissaoResult calculo0 = cmrsMapByAeronaveId.get(aeronaves[0].Id);
        this.trajeto = calculo0.trajeto;
        this.origemInicial = calculo0.trajeto.isEmpty() ? null : calculo0.trajeto[0].Id;
        this.destinoFinal = calculo0.trajeto.isEmpty() ? null : calculo0.trajeto[calculo0.trajeto.size() - 1].Id;

        Integer aeronavesValidas = 0;

        for(Aeronave__c aeronave : aeronaves)
        {
            CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronave.Id);

            if(calculo.tempoMissao > this.tempoMissao)
            {
                this.tempoMissao = calculo.tempoMissao;
                this.tempoTransladoIda = calculo.tempoTransladoIda;
                this.tempoTransladoRetorno = calculo.tempoTransladoRetorno;
            }

            List<Event> eventosDaAeronave = eventosPorAeronave.get(aeronave.Id);

            Integer podeVoar = EventsService.podeExecutarVoo(calculo, this.data, eventosDaAeronave, new Voo__c(Tipo__c = 'Charter'));

            if (podeVoar > 0) {
                if (this.data > cmrsMapByAeronaveId.get(aeronave.Id).hrMaximoDecolagem) {
                    podeVoar = 0;
                }
            }

            if(podeVoar > 0)
            {
                if (this.aeronave == null) {
                    this.aeronave = aeronave;
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
        Id produtoId, id modeloId, String quem, Id contaId, Map<Id, List<RegraProduto__c>> regrasDosProdutos,
        Map<Id, List<RegraPreco__c>> regrasDosPrecos, Map<Id, List<RegraDesconto__c>> regrasDeDescontos, 
        CodigoPromocional__c codigo, Boolean codigoJaUtilizado, Boolean primeiraCompra
    ) 
    {

        List<RegraProduto__c> regrasProdutos = regrasDosProdutos.containsKey(produtoId) ? regrasDosProdutos.get(produtoId) : new List<RegraProduto__c>();        
        List<RegraPreco__c> regrasPrecos = regrasDosPrecos.containsKey(produtoId) ? regrasDosPrecos.get(produtoId) : new List<RegraPreco__c>();
        List<RegraDesconto__c> regrasDescontos = regrasDeDescontos.containsKey(produtoId) ? regrasDeDescontos.get(produtoId) : new List<RegraDesconto__c>();

        
        Decimal quantidade = this.tempoMissao / 60;
        quantidade = quantidade.setScale(2, RoundingMode.HALF_UP);

        CalculaPrecosParaPesquisa.CalculaPrecosParaPesquisaResult result = CalculaPrecosParaPesquisa.calculaPrecosVoos(
            produtoId, contaId, quem, null, null, this.data, modeloId, quantidade, 
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
        Id produtoId, Id modeloId, String quem, Id contaId, List<ConfiguracaoPacote__c> configuracaoPacotes,
        Map<Id, List<RegraProduto__c>> regrasDosProdutos, Map<Id, List<RegraPreco__c>> regrasDosPrecos, 
        Map<Id, List<RegraDesconto__c>> regrasDeDescontos, CodigoPromocional__c codigo,
        Boolean codigoJaUtilizado, Boolean primeiraCompra,
        Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, List<Aeronave__c> aeronaves, 
        Map<Id, Integer> servicosContratados, Local__c origem, Local__c destino
    ) 
    {
        for (ConfiguracaoPacote__c config : configuracaoPacotes) {

            if(servicosIds.contains(config.id)) continue;
            
            ServicoDoPacote.ServicoDoPacoteCache cache = new ServicoDoPacote.ServicoDoPacoteCache();

            cache.quem = quem;
            cache.produtoId = config.ProdutoPacote__c;
            cache.produtoPaiId = produtoId;
            cache.quantidadePai = 1;

            cache.origemId = origem.Id;
            cache.destinoId = destino.Id;
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
            
            if (!servico.invalido) {
                this.servicosIds.add(config.id);
                this.servicos.add(servico);
            } 
        }        
    }    

    // #endregion
}