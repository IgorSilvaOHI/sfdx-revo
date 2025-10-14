public class PesquisaFullCabin {

    // #region Variáveis Publicas

    @AuraEnabled     
    public String key {get; set;}

    @AuraEnabled     
    public Id produto {get; set;} 

    @AuraEnabled     
    public Id origem {get; set;} 

    @AuraEnabled     
    public Id destino {get; set;} 

    @AuraEnabled     
    public String localOrigem {get; set;}

    @AuraEnabled     
    public String localdestino {get; set;}

    @AuraEnabled     
    public String modelo {get; set;}

    @AuraEnabled     
    public String modeloId {get; set;}

    @AuraEnabled     
    public String modeloImagemUrl {get; set;}

    @AuraEnabled 
    public Integer capacidadePassageiros {get; set;}

    @AuraEnabled     
    public Double tempoTransladoIda {get; set;}

    @AuraEnabled 
    public Double tempoTransladoRetorno {get; set;}

    @AuraEnabled     
    public Double  tempoMissao {get; set;}

    @AuraEnabled     
    public Date dataMissao {get; set;}

    @AuraEnabled     
    public Double 	pesoDisponivel {get; set;}

    @AuraEnabled     
    public List<BlocoFullCabin> horarios {get; set;}

    @AuraEnabled     
    public Map<String, Id> prefixosDisponiveis {get; set;}

    @AuraEnabled     
    public Map<String, Integer> posicaoHoraFormatada {get; set;}

    @AuraEnabled     
    public Map<Id, Datetime> hrMaximoPorAeronaveId {get; set;}

    // #endregion

    // #region Variáveis Privadas

    private static Map<String, Integer> posicaoHoraFormatadaStatic;

    // #endregion

    // #region Construtor

    public PesquisaFullCabin(Id productId, Product2 modelo, List<BlocoFullCabin> horarios, Map<String, Integer>  posicaoHoraFormatada) {
        this.produto = productId;
        this.modelo = modelo.Name;
        this.modeloId = modelo.Id;
        this.modeloImagemUrl = modelo.ImagemUrl__c;
        this.capacidadePassageiros = modelo.CapacidadePassageiros__c.intValue();
        this.horarios = new List<BlocoFullCabin>();
        for(BlocoFullCabin bloco : horarios)
        {
            BlocoFullCabin b = new BlocoFullCabin(bloco.data, bloco.intervalo);
            this.horarios.add(b);
        }
        this.posicaoHoraFormatada = posicaoHoraFormatada;
    }

    // #endregion

    // #region Métodos Publicos

    public static List<Local__c> buscaLocaisOrdenados(Id origem, Id destino) {
        Map<Id, Local__c> trajetos = new Map<Id, Local__c> (LocaisSelector.newInstance().selectById(new Set<Id> { origem, destino }));

        return new List<Local__c> { trajetos.get(origem) , trajetos.get(destino) };
    }

    public static Map<Id, List<Event>> buscaEventosAeronaves(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, Datetime menorData, DateTime maiorData) {
        List<Aeronave__c> aeronavesDoCalculo = CalculoMissaoHelper.getAeronavesDosCalculos(cmrsMapByAeronaveId);

        IAeronaves ae = Aeronaves.newInstance(aeronavesDoCalculo);
        Map<String, Aeronave__c> aeronavesPorNome = ae.getPorPrefixo();
        Map<Id, List<Aeronave__c>> aeronavesPorModelo = ae.getPorModelo();

        List<Event> eventosNaData = EventsSelector.newInstance().selectByOwnerNameInDateRange(aeronavesPorNome.keySet(), menorData, maiorData, new Set<Id>());
        return Events.newInstance(eventosNaData).getPorAeronave(aeronavesPorNome);        
    }

    public static List<Aeronave__c> buscaAeronavesDisponiveis(Id produtoId) {
        List<AeronaveDisponivel__c> aeronavesDisponiveis = AeronaveDisponivelSelector.newInstance().aeronavesPorProduto(new Set<Id> { produtoId });

        Set<Id> aeronaveIds = new Set<Id>();

        for (AeronaveDisponivel__c aeDisp : aeronavesDisponiveis) {
            aeronaveIds.add(aeDisp.Aeronave__c);
        }      

        return AeronavesSelector.newInstance().selectAeronaveAndModelo(aeronaveIds);
    }

    public static List<PesquisaFullCabin> getPesquisasPorFullCabin ( PesquisaParametroOportunidade param ) {

        List<BlocoFullCabin> blocosTempo = !param.checkOut ? getBlocosTempoParaData(param.previsaoDeVoo) :  new List<BlocoFullCabin> { new BlocoFullCabin(param.previsaoDeVoo, 30) };
        List<PesquisaFullCabin> pesquisas = new List<PesquisaFullCabin>();
        
        IAeronaves ae = Aeronaves.newInstance(param.aeronaves);
        Map<Id, List<Aeronave__c>> aeronavesPorModelo = ae.getPorModelo();

        Map<Id, List<List<Aeronave__c>>> gruposPorModelo = getAeronavesAgrupadas(param.cmrsMapByAeronaveId, aeronavesPorModelo);
        
        for(Id modeloId : gruposPorModelo.keySet())
        {
            if (param.charter_modelos.containsKey(modeloId)) {
                for(List<Aeronave__c> grupoAeronaves : gruposPorModelo.get(modeloId))
                {
                    Aeronave__c primeiraAeronave = grupoAeronaves[0];
                    CalculoMissaoResult calculo = param.cmrsMapByAeronaveId.get(primeiraAeronave.Id);
                    Map<Id, Datetime> hrMaximoPorAeronaveId = new Map<Id, Datetime>();
                    Map<String, Id> prefixosDisponiveis = new Map<String, Id>();
                    String key = '';
                    for(Aeronave__c aeronave : grupoAeronaves)
                    {
                        prefixosDisponiveis.put(aeronave.Name, aeronave.Id);
                        hrMaximoPorAeronaveId.put(aeronave.Id, param.cmrsMapByAeronaveId.get(aeronave.Id).hrMaximoDecolagem);
                        key += aeronave.Name;
                    }
                    Product2 modeloProduto = param.charter_modelos.get(modeloId);
                    PesquisaFullCabin mod = new PesquisaFullCabin(param.produto.Id, modeloProduto, blocosTempo, posicaoHoraFormatadaStatic);

                    for(BlocoFullCabin bloco : mod.horarios)
                    {
                        bloco.setBlocoFullCabin(param.produto.Id, modeloId, param.quem, param.contaId,
                                              grupoAeronaves, param.eventosPorAeronave, 
                                              param.cmrsMapByAeronaveId, param.servicosDoProduto, 
                                              param.regrasDosProdutos, param.regrasDosPrecos, 
                                              param.regrasDeDescontos, param.codigoPromocional,
                                              param.codigoJaUtilizado, param.primeiraCompra,
                                              param.servicosContratados);
                    }            

                    mod.origem = param.locais[0].Id;
                    mod.localOrigem = param.locais[0].Name;
                    mod.destino = param.locais[1].Id;
                    mod.localDestino = param.locais[1].Name;
                    mod.tempoTransladoIda = calculo.tempoTransladoIda;
                    mod.tempoTransladoRetorno = calculo.tempoTransladoRetorno;
                    mod.prefixosDisponiveis = prefixosDisponiveis;
                    mod.key = key;
                    mod.pesoDisponivel = calculo.pesoMaximo;
                    mod.tempoMissao = calculo.tempoMissao;
                    mod.hrMaximoPorAeronaveId = hrMaximoPorAeronaveId;
                    mod.dataMissao = calculo.dataMissao;
                    pesquisas.add(mod);
                }                
            }
        }

        return pesquisas;
    }    

    // #endregion    

    // #region Métodos Privados

    private static List<BlocoFullCabin> getBlocosTempoParaData(Datetime data)
    {
        List<BlocoFullCabin> blocosTempo = new List<BlocoFullCabin>();
        
        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
        Integer horaFim = (Integer)configuracaoTempo.HoraFimSelecaoHorarioVoo__c;
        Integer horaInicio = (Integer)configuracaoTempo.HoraInicioSelecaoHorarioVoo__c;
        Integer minutoFim = (Integer)configuracaoTempo.MinutoFimSelecaoHorarioVoo__c;
        Integer minutoInicio = (Integer)configuracaoTempo.MinutoInicioSelecaoHorarioVoo__c;
        Integer intervalo = (Integer)configuracaoTempo.IntervaloMinutosSelecaoAeronaves__c;
        
        Time horarioInicio = Time.newInstance(horaInicio, minutoInicio, 0, 0);
        Time horarioFim = Time.newInstance(horaFim, minutoFim, 0, 0);
        DateTime dataInicio = DateTime.newInstance(data.date(), horarioInicio);
        DateTime dataFim = DateTime.newInstance(data.date(), horarioFim);
        
        Integer index = 0;
        Datetime lastDate = dataInicio;
        posicaoHoraFormatadaStatic = new Map<String, Integer>();

        While(dataInicio <= dataFim)
        {
            if(lastDate < data && dataInicio > data){
                //ADICIONA O HORARIO DO CLIENTE À MALHA
                BlocoFullCabin bloco = new BlocoFullCabin(data, intervalo);
                blocosTempo.add(bloco);
                posicaoHoraFormatadaStatic.put(bloco.horaFormatada, index);
                index++;
            }

            BlocoFullCabin bloco = new BlocoFullCabin(dataInicio, intervalo);
			blocosTempo.add(bloco);
            dataInicio = dataInicio.addMinutes(intervalo);
            
            posicaoHoraFormatadaStatic.put(bloco.horaFormatada, index);
            index++;
        }
        return blocosTempo;
    }    

    public static Map<Id, List<List<Aeronave__c>>> getAeronavesAgrupadas(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, Map<Id, List<Aeronave__c>> aeronavesPorModelo)
    {
        Map<Id, List<List<Aeronave__c>>> aeronavesAgrupadas = new Map<Id, List<List<Aeronave__c>>>();
        
        for(Id modeloId : aeronavesPorModelo.keySet())
        {
            List<Aeronave__c> aeronaves = aeronavesPorModelo.get(modeloId);
            List<List<Aeronave__c>> gruposAeronaves = new List<List<Aeronave__c>>();
            
            Map<Id, List<Aeronave__c>> aeronavesPorTranslado = getAeronavesPorTranslado(aeronaves, cmrsMapByAeronaveId);
            
            for(Id origem : aeronavesPorTranslado.keySet())
            {
                List<Aeronave__c> aerovanesDoTransalado =  aeronavesPorTranslado.get(origem);
                Map<Integer, List<Aeronave__c>> aeronavesPorGrupo = getAeronavesPorGrupo(aerovanesDoTransalado, cmrsMapByAeronaveId);
                
                gruposAeronaves.addAll(aeronavesPorGrupo.values());
            }
 
            aeronavesAgrupadas.put(modeloId, gruposAeronaves);
        }
        
        return aeronavesAgrupadas;
    }    

    private static Map<Id, List<Aeronave__c>> getAeronavesPorTranslado(List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId)
    {
        Map<Id, List<Aeronave__c>> aeronavesPorTranslado = new Map<Id, List<Aeronave__c>>();
            for(Aeronave__c aeronave : aeronaves)
            {
                CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronave.Id);
                Id origemId = calculo.baseOrigem != null ? calculo.baseOrigem.Id : null;
                if(aeronavesPorTranslado.containsKey(origemId))
                {
                    List<Aeronave__c> aeronaveDoTranslado = aeronavesPorTranslado.get(origemId);
                    aeronaveDoTranslado.add(aeronave);
                    aeronavesPorTranslado.put(origemId, aeronaveDoTranslado);
                }else
                {
                    List<Aeronave__c> aeronaveDoTranslado = new List<Aeronave__c>();
                    aeronaveDoTranslado.add(aeronave);
                    aeronavesPorTranslado.put(origemId, aeronaveDoTranslado);
                }
            }
            return aeronavesPorTranslado;
    }    

    private static Map<Integer, List<Aeronave__c>> getAeronavesPorGrupo(List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId)
    {
        Map<Integer, List<Aeronave__c>> aeronavesPorGrupo = new Map<Integer, List<Aeronave__c>>();
        ConfiguracoesTelaCustomizada__c configTela = ConfiguracoesTelaCustomizada__c.getOrgDefaults();
        Double diferencaPeso = configTela.DiferencaPesoDisponivel__c/100;
        Integer grupoAtual = 0;
        List<Aeronave__c> aeronavesOrdenadasPorPeso = getAeronavesOrdenadasPorPeso(aeronaves, cmrsMapByAeronaveId);
        
        for(Aeronave__c aeronave : aeronaves)
        {
			if(aeronavesPorGrupo.containsKey(grupoAtual))
            {
                List<Aeronave__c> grupoAeronaves = aeronavesPorGrupo.get(grupoAtual);
                Id primeiraAeronaveId = grupoAeronaves[0].Id;
                Decimal primeiroPeso = cmrsMapByAeronaveId.get(primeiraAeronaveId).pesoMaximo;
                Double limitePeso = (1+diferencaPeso)*primeiroPeso;
                Decimal pesoAtual = cmrsMapByAeronaveId.get(aeronave.Id).pesoMaximo;
                
                if(pesoAtual > limitePeso)
                {
                    grupoAtual++;
                    List<Aeronave__c> grupoAeronavesVazio = new List<Aeronave__c>();
                    grupoAeronavesVazio.add(aeronave);
                    aeronavesPorGrupo.put(grupoAtual, grupoAeronavesVazio);
                }else
                {
                    grupoAeronaves.add(aeronave);
                    aeronavesPorGrupo.put(grupoAtual, grupoAeronaves);
                }
            }else
            {
                List<Aeronave__c> grupoAeronaves = new List<Aeronave__c>();
                grupoAeronaves.add(aeronave);
                aeronavesPorGrupo.put(grupoAtual, grupoAeronaves);
            }
        }
        return aeronavesPorGrupo;
    }    

    private static List<Aeronave__c> getAeronavesOrdenadasPorPeso(List<Aeronave__c> aeronaves, Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId)
    {
        integer iterationsize = aeronaves.size();
        Aeronave__c aeronaveTemp = new Aeronave__c();
        
        for(integer i=0; i < iterationsize; i++){
            for(integer j=1; j < (iterationsize-i); j++){
                Decimal pesoPrimeiraAeronave = cmrsMapByAeronaveId.get(aeronaves[j-1].Id).pesoMaximo;
                Decimal pesoSegundaAeronave = cmrsMapByAeronaveId.get(aeronaves[j].Id).pesoMaximo;
                if(pesoPrimeiraAeronave > pesoSegundaAeronave){
                    aeronaveTemp = aeronaves[j-1];
                    aeronaves[j-1] = aeronaves[j];
                    aeronaves[j] = aeronaveTemp;
                }
            }
        }
        
        return aeronaves;
    }
 
    // #endregion

}