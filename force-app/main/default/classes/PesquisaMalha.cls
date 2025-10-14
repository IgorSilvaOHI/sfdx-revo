public class PesquisaMalha {

    // #region Variáveis Publicas

    @AuraEnabled 
    public Id origem {get; set;} 

    @AuraEnabled 
    public Id destino {get; set;} 

    @AuraEnabled 
    public Id aeronave {get; set;}

    @AuraEnabled 
    public String localOrigem {get; set;}

    @AuraEnabled 
    public String localdestino {get; set;}

    @AuraEnabled 
    public String prefixo {get; set;}

    @AuraEnabled 
    public String modelo {get; set;}

    @AuraEnabled 
    public String modeloId {get; set;}

    @AuraEnabled 
    public String modeloImagemUrl {get; set;}

    @AuraEnabled 
    public Integer capacidadePassageiros {get; set;}
    
    @AuraEnabled 
    public Decimal tempoMissao {get; set;}
    
    @AuraEnabled 
    public DateTime dataHora {get; set;} 

    @AuraEnabled 
    public Integer assentosDisponiveis {
        get; 
        set {
            if (value < 0) {
                this.assentosDisponiveis = 0;
            } else {
                this.assentosDisponiveis = value;
            }
        }
    }

    @AuraEnabled 
    public Id produto {get; set;} 

    @AuraEnabled
    public Id malhaId {get; set;} 

    @AuraEnabled 
    public Boolean invalido {get; set;}

    @AuraEnabled 
    public Decimal precoUnitario {get; set;}

    @AuraEnabled 
    public Decimal precoRevoSeats {get; set;}

    @AuraEnabled 
    public Integer quantidade {get; set;}

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

    public Trecho__c trecho {get; set;}

    // #endregion

    // #region Váriaveis Privadas

    private MalhaVoo__c malhaAtiva {get; set;}

    // #endregion

    // #region Construtor

    private PesquisaMalha(MalhaVoo__c malha, Integer quantidade, Datetime dataHora) {
        this.capacidadePassageiros = malha.NumeroAssentos__c?.intValue();
        this.origem = malha.Origem__c;
        this.destino = malha.Destino__c;
        this.localOrigem = malha.Origem__r.Name;
        this.localDestino = malha.Destino__r.Name;
        this.dataHora = dataHora;
        this.quantidade = quantidade;
        this.produto = malha.Produto__c;
        this.malhaId = malha.Id;
        this.malhaAtiva = malha;
        this.tempoMissao = malha.Duracao__c;
    }

    public PesquisaMalha()
    {

    }

    // #endregion

    // #region Métodos Públicos

    public static List<Local__c> buscaLocaisOrdenados(Id origem, Id destino) {
        Map<Id, Local__c> trajetos = new Map<Id, Local__c> (LocaisSelector.newInstance().selectById(new Set<Id> { origem, destino }));

        return new List<Local__c> { trajetos.get(origem) , trajetos.get(destino) };
    }

    public static List<ConfiguracaoPacote__c> buscaServicosDoProduto(Id produtoId) {
        Map<Id, List<ConfiguracaoPacote__c>> mpConfigs = ConfiguracaoPacoteSelector.newInstance().selectByIdProducts(new Set<Id> { produtoId });

        return mpConfigs.containsKey(produtoId) ? mpConfigs.get(produtoId) : new List<ConfiguracaoPacote__c>();
    }    

    public static List<Aeronave__c> buscaAeronavesPrioritarias(Id malhaId) {

        List<PrioridadeMalha__c> prioridades = PrioridadeMalhaSelector.newInstance().aeronavesPorPriridadeMalha(malhaId);

        Set<Id> aeronavesIds = new Set<Id>();
        Map<Integer, Id> ids = new Map<Integer, Id>();

        for (PrioridadeMalha__c aeDisp : prioridades) {
            aeronavesIds.add(aeDisp.Aeronave__c);
            ids.put(aeDisp.Prioridade__c.intValue(), aeDisp.Aeronave__c);
        }

        Map<Id, Aeronave__c> aeronavesMap = new Map<Id, Aeronave__c> (AeronavesSelector.newInstance().selectAeronaveAndModelo(aeronavesIds));

        List<Aeronave__c> aeronavesOrdenadas = new List<Aeronave__c>();
        
        List<Integer> sequencia = new List<Integer>(ids.keyset());

        sequencia.sort();

        for (Integer key : sequencia) {

            Id idAeronave = ids.get(key);

            if (aeronavesMap.containsKey(idAeronave)) {
                aeronavesOrdenadas.add(aeronavesMap.get(idAeronave));
            }
        }

        return aeronavesOrdenadas;
    }

    public static Map<Id, List<Event>> buscaEventosAeronaves(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, Datetime menorData, DateTime maiorData) {
        List<Aeronave__c> aeronavesDoCalculo = CalculoMissaoHelper.getAeronavesDosCalculos(cmrsMapByAeronaveId);

        IAeronaves ae = Aeronaves.newInstance(aeronavesDoCalculo);
        Map<String, Aeronave__c> aeronavesPorNome = ae.getPorPrefixo();
        Map<Id, List<Aeronave__c>> aeronavesPorModelo = ae.getPorModelo();

        List<Event> eventosNaData = EventsSelector.newInstance().selectByOwnerNameInDateRange(aeronavesPorNome.keySet(), menorData, maiorData, new Set<Id>());
        System.debug('eventosNaData ' + eventosNaData.size());
        return Events.newInstance(eventosNaData).getPorAeronave(aeronavesPorNome);        
    }

    public static List<PesquisaMalha> getPesquisasPorMalha (PesquisaParametroOportunidade param)
    {
        List<PesquisaMalha> malhas = new List<PesquisaMalha>();

        Map<Date, Map<String, Trecho__c>> dataHoraTrecho = trechosPorDataHora(param.malha_trechos);

        Map<Id, Aeronave__c> mapAeronaves = new Map<Id, Aeronave__c>(param.aeronaves);

        Date inicio = param.previsaoDeVoo.date();
        Date fim = inicio.addDays(param.malha_offsetDatas);

        for (Date currentDate = inicio; currentDate <= fim; currentDate = currentDate.addDays(1)) {

            List<DateTime> horarios = horariosMalhaDia(currentDate, param.malha);
            
            if (horarios.isEmpty()) {
                continue;
            }
            
            horarios.Sort();

            for (DateTime horario : horarios) {

                if (param.checkOut && horario != param.previsaoDeVoo) {
                    continue;
                }

                PesquisaMalha pesquisa = new PesquisaMalha(param.malha, param.quantidade, horario);

                if (dataHoraTrecho.containsKey(currentDate) 
                && dataHoraTrecho.get(currentDate).containsKey(horario.format('HH:mm'))) {
                    Trecho__c trecho = dataHoraTrecho.get(currentDate).get(horario.format('HH:mm'));
                    pesquisa.carregaDadosTrecho(trecho);
                    pesquisa.invalido = false;

                } else {
                    CalculoMissaoResult calculo = qualAeronavePodeVoar(param.aeronaves, param.cmrsMapByAeronaveId, param.eventosPorAeronave, horario);
                    pesquisa.invalido = calculo == null;

                    if (!pesquisa.invalido) {
                        pesquisa.carregaDadosMissao(calculo, mapAeronaves, horario);
                    }else if(!param.cmrsMapByAeronaveId.isEmpty()){
                        pesquisa.carregaDadosMissao(param.cmrsMapByAeronaveId.values()[0], mapAeronaves, horario);
                    }
                }

                if (!pesquisa.invalido) {
                    pesquisa.carregaDadosPrecoTrecho(param);
                    pesquisa.carregaDadosServicos(param);
                }
                
                malhas.add(pesquisa);
            }
        }

        return malhas;
    }

    // #endregion

    // #region Métodos Privados

    private void carregaDadosTrecho(Trecho__c trecho) {
        this.trecho = trecho;
        this.aeronave = trecho.Voo__r.Prefixo__c;
        
        this.prefixo = trecho.Voo__r.Prefixo__r.Name;
        this.modelo = trecho.Voo__r.Prefixo__r.ModeloAeronave__r.Name;
        this.modeloId = trecho.Voo__r.Prefixo__r.ModeloAeronave__c;
        this.modeloImagemUrl = trecho.Voo__r.Prefixo__r.ModeloAeronave__r.ImagemUrl__c;
        this.dataHora = trecho.Voo__r.DataVoo__c;

        if(this.capacidadePassageiros == null){
            this.capacidadePassageiros = trecho.Voo__r.Prefixo__r.NumeroAssentos__c.intValue();
        }

        this.assentosDisponiveis = this.capacidadePassageiros - trecho.QtdPassageiros__c.intValue();

        if(this.tempoMissao == null){
            this.tempoMissao = trecho.TempoMissao__c;
        }
    }

    private void carregaDadosMissao(CalculoMissaoResult calculo, Map<Id, Aeronave__c> mapAeronaves, Datetime previsao) {
        Aeronave__c aeronave = mapAeronaves.get(calculo.aeronave.Id);

        this.aeronave = aeronave.Id;
        
        this.prefixo = aeronave.Name;
        this.modelo = aeronave.ModeloAeronave__r.Name;
        this.modeloId = aeronave.ModeloAeronave__c;

        this.modeloImagemUrl = aeronave.ModeloAeronave__r.ImagemUrl__c;
        this.dataHora = previsao;

        if(this.capacidadePassageiros == null){
            this.capacidadePassageiros = aeronave.NumeroAssentos__c.intValue();
        }

        this.assentosDisponiveis = this.capacidadePassageiros;
        
        if(this.tempoMissao == null){
            this.tempoMissao = calculo.tempoMissao;
        }
    }        

    private void carregaDadosPrecoTrecho ( PesquisaParametroOportunidade param ) 
    {
        List<RegraProduto__c> regrasProdutos = param.regrasDosProdutos.containsKey(this.produto) ? param.regrasDosProdutos.get(this.produto) : new List<RegraProduto__c>();
        List<RegraPreco__c> regrasPrecos = param.regrasDosPrecos.containsKey(this.produto) ? param.regrasDosPrecos.get(this.produto) : new List<RegraPreco__c>();
        List<RegraDesconto__c> regrasDescontos = param.regrasDeDescontos.containsKey(this.produto) ? param.regrasDeDescontos.get(this.produto) : new List<RegraDesconto__c>();

        CalculaPrecosParaPesquisa.CalculaPrecosParaPesquisaResult result = CalculaPrecosParaPesquisa.calculaPrecosVoos(
            this.produto, param.contaId, param.quem, this.origem, this.destino, this.dataHora, 
            this.modeloId, this.quantidade, regrasProdutos, regrasPrecos, regrasDescontos, param.codigoPromocional,
            param.codigoJaUtilizado, param.primeiraCompra, false, false
        );

        this.invalido = result.invalido;

        if (this.invalido) return;
        
        if(result.regraProdutoResult.numeroAssentos != null){
            this.capacidadePassageiros = result.regraProdutoResult.numeroAssentos;
            this.assentosDisponiveis = result.regraProdutoResult.numeroAssentos - (this.trecho != null ? this.trecho.QtdPassageiros__c.intValue() : 0);
        }

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

    private void carregaDadosServicos (PesquisaParametroOportunidade param) 
    {
        this.servicos = new List<ServicoDoPacote>();

        for (ConfiguracaoPacote__c config : param.servicosDoProduto) {

            ServicoDoPacote.ServicoDoPacoteCache cache = new ServicoDoPacote.ServicoDoPacoteCache();

            cache.quem = param.quem;
            cache.produtoId = config.ProdutoPacote__c;
            cache.produtoPaiId = this.produto;
            cache.quantidadePai = this.quantidade;

            cache.origemId = this.origem;
            cache.destinoId = this.destino;
            cache.modeloId = this.modeloId;
            cache.previsaoDecolagem = this.dataHora;

            cache.contaId = param.contaId;

            cache.quantidade = config.QuantidadeRelativa__c == 'Pelo Padrão' ? config.QuantidadePadrao__c.intValue() : cache.quantidadePai;
            cache.quantidade = param.servicosContratados.containsKey(config.ProdutoPacote__c) ? param.servicosContratados.get(config.ProdutoPacote__c) : cache.quantidade;
            cache.configuracaoPacote = config;
            cache.porPassageiro = config.QuantidadeRelativa__c != 'Pelo Padrão';
            
            cache.regraPrecos = param.regrasDosPrecos.containsKey(config.ProdutoPacote__c) ? param.regrasDosPrecos.get(config.ProdutoPacote__c) : new List<RegraPreco__c>();
            cache.regraProdutos = param.regrasDosProdutos.containsKey(config.ProdutoPacote__c) ? param.regrasDosProdutos.get(config.ProdutoPacote__c) : new List<RegraProduto__c>();
            cache.regraDescontos = param.regrasDeDescontos.containsKey(config.ProdutoPacote__c) ? param.regrasDeDescontos.get(config.ProdutoPacote__c) : new List<RegraDesconto__c>();
            cache.codigoPromocional = param.codigoPromocional;
            cache.codigoJaUtilizado = param.codigoJaUtilizado;
            cache.primeiraCompra = param.primeiraCompra;            

            ServicoDoPacote servico = new ServicoDoPacote(cache);

            if (!servico.invalido) this.servicos.add(servico);
        }        
    }

    private static CalculoMissaoResult qualAeronavePodeVoar(
        List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, 
        Map<Id, List<Event>> eventosPorAeronave, Datetime previsao
    ) {

        for(Aeronave__c aeronave : aeronaves)
        {
            CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronave.Id);

            List<Event> eventosDaAeronave = eventosPorAeronave.get(aeronave.Id);

            Integer podeVoar = EventsService.podeExecutarVoo(calculo, previsao, eventosDaAeronave, new Voo__c(Tipo__c = 'ShuttleSeat'));

            if (podeVoar > 0) {
                if (cmrsMapByAeronaveId.get(aeronave.Id).hrMaximoDecolagem != null) {
                    if (previsao.time() > cmrsMapByAeronaveId.get(aeronave.Id).hrMaximoDecolagem.time()) {
                        podeVoar = 0;
                    }
                }
            }

            if(podeVoar > 0)
            {
                return calculo;
            }
        }

        return null;
    }

    private static List<DateTime> horariosMalhaDia(Date data, MalhaVoo__c malhaAtiva) {
        List<DateTime> horarios = new List<DateTime>();
        
        Integer diaDaSemana = data.toStartofWeek().daysBetween(data);
        String malhaDoDia = '';

        switch on diaDaSemana {
            when 0 {
                malhaDoDia = malhaAtiva.Domingo__c;
            }
            when 1 {
                malhaDoDia = malhaAtiva.SegundaFeira__c;
            }
            when 2 {
                malhaDoDia = malhaAtiva.TercaFeira__c;
            }
            when 3 {
                malhaDoDia = malhaAtiva.QuartaFeira__c;
            }
            when 4 {
                malhaDoDia = malhaAtiva.QuintaFeira__c;
            }
            when 5 {
                malhaDoDia = malhaAtiva.SextaFeira__c;
            }
            when 6 {
                malhaDoDia = malhaAtiva.Sabado__c;
            }
        }

        if(malhaDoDia != null && malhaDoDia != '')
        {
            for (String horarioMalha : malhaDoDia.split(';')) {

                if (String.isEmpty(horarioMalha)) {
                    continue;
                } 

                Time newTime = Time.newInstance(Integer.valueOf(horarioMalha.split(':')[0]), Integer.valueOf(horarioMalha.split(':')[1]), 0, 0);

                horarios.add(DateTime.newInstance(data, newTime));
            }
        }

        for (HorarioExtraDaMalha__c horarioExtra : malhaAtiva.HorariosExtraMalha__r) {

            if (horarioExtra.DataHoraExtra__c.date() != data) {
                continue;
            }

            horarios.add(horarioExtra.DataHoraExtra__c);
        }

        return horarios; 
    }

    private static Map<Date, Map<String, Trecho__c>> trechosPorDataHora(List<Trecho__c> trechosMalha) {
        Map<Date, Map<String, Trecho__c>> result = new Map<Date, Map<String, Trecho__c>>();

        for (Trecho__c trecho : trechosMalha) {
            
            if (!result.containsKey(trecho.Voo__r.DataVoo__c.date())) {
                result.put(trecho.Voo__r.DataVoo__c.date(), new Map<String, Trecho__c>());
            }

            Map<String, Trecho__c> mapa = result.get(trecho.Voo__r.DataVoo__c.date());

            mapa.put(trecho.HorarioMalha__c, trecho);
        }

        return result;
    }

    // #endregion
}