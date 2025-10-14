public without sharing class OpportunityServiceImpl implements IOpportunityService  {

    // #region Definições Internas

    private enum Para {
        Cliente, Parceiro, Concierge
    }

    // #endregion

    // #region Pesquisa Malhas 

    public List<PesquisaMalha> pesquisaMalhaVoosCliente(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo)
    {
        Datetime dataGmt = Datetime.newInstance(data, Time.newInstance(0, 0, 0, 0));
        return pesquisaMalhaVoos(Para.Cliente.name(), contaId, origem, destino, quantidade, dataGmt, offSet, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaMalha> pesquisaMalhaVoosParceiro(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo)
    {
        Datetime dataGmt = Datetime.newInstance(data, Time.newInstance(0, 0, 0, 0));
        return pesquisaMalhaVoos(Para.Parceiro.name(), contaId, origem, destino, quantidade, dataGmt, offSet, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaMalha> pesquisaMalhaVoosConcierge(Id contaId, Id origem, Id destino, Integer quantidade, Date data, Integer offSet, String codigoPromocionalInfo)
    {
        Datetime dataGmt = Datetime.newInstance(data, Time.newInstance(0, 0, 0, 0));
        return pesquisaMalhaVoos(Para.Concierge.name(), contaId, origem, destino, quantidade, dataGmt, offSet, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }  

    public PesquisaMalha resumoMalhaVoosCliente(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo){
        List<PesquisaMalha> malhas = pesquisaMalhaVoos(Para.Cliente.name(), contaId, origem, destino, quantidade, previsaoDeVoo, 0, codigoPromocionalInfo, servicosContratados, true);
        if (malhas.isEmpty()) return null; else return malhas[0];
    }

    public PesquisaMalha resumoMalhaVoosParceiro(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo){
        List<PesquisaMalha> malhas = pesquisaMalhaVoos(Para.Parceiro.name(), contaId, origem, destino, quantidade, previsaoDeVoo, 0, codigoPromocionalInfo, servicosContratados, true);
        if (malhas.isEmpty()) return null; else return malhas[0];
    }

    public PesquisaMalha resumoMalhaVoosConcierge(Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo){
        List<PesquisaMalha> malhas = pesquisaMalhaVoos(Para.Concierge.name(), contaId, origem, destino, quantidade, previsaoDeVoo, 0, codigoPromocionalInfo, servicosContratados, true);
        if (malhas.isEmpty()) return null; else return malhas[0];
    }

    // #endregion

    // #region Pesquisas Full Cabin  

    public List<PesquisaFullCabin> pesquisaFullCabinCliente(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo)
    {    
        return pesquisaFullCabin(Para.Cliente.name(), contaId, origem, destino, data, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaFullCabin> pesquisaFullCabinParceiro(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo)
    {    
        return pesquisaFullCabin(Para.Parceiro.name(), contaId, origem, destino, data, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaFullCabin> pesquisaFullCabinConcierge(Id contaId, Id origem, Id destino, Date data, String codigoPromocionalInfo)
    {    
        return pesquisaFullCabin(Para.Concierge.name(), contaId, origem, destino, data, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public PesquisaFullCabin resumoFullCabinCliente(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaFullCabin> fulls = pesquisaFullCabin(Para.Cliente.name(), contaId, origem, destino, previsaoDeVoo, codigoPromocionalInfo, servicosContratados, true);

        PesquisaFullCabin fullcabin = null;

        for (PesquisaFullCabin pesquisa : fulls) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;
    }

    public PesquisaFullCabin resumoFullCabinParceiro(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaFullCabin> fulls = pesquisaFullCabin(Para.Parceiro.name(), contaId, origem, destino, previsaoDeVoo, codigoPromocionalInfo, servicosContratados, true);

        PesquisaFullCabin fullcabin = null;

        for (PesquisaFullCabin pesquisa : fulls) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;        
    }

    public PesquisaFullCabin resumoFullCabinConcierge(Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaFullCabin> fulls = pesquisaFullCabin(Para.Concierge.name(), contaId, origem, destino, previsaoDeVoo, codigoPromocionalInfo, servicosContratados, true);

        PesquisaFullCabin fullcabin = null;

        for (PesquisaFullCabin pesquisa : fulls) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;        
    }

    // #endregion 

    // #region Pesquisa Charter      

    public List<PesquisaCharter> pesquisaChartCliente(List<Local__c> trajeto, DateTime data, Id contaId, String codigoPromocionalInfo)
    {    
        return pesquisaChart(Para.Cliente.name(), trajeto, data, contaId, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaCharter> pesquisaChartParceiro(List<Local__c> trajeto, DateTime data, Id contaId, String codigoPromocionalInfo)
    {    
        return pesquisaChart(Para.Parceiro.name(), trajeto, data, contaId, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }

    public List<PesquisaCharter> pesquisaChartConcierge(List<Local__c> trajeto, DateTime data, Id contaId, String codigoPromocionalInfo)
    {    
        return pesquisaChart(Para.Concierge.name(), trajeto, data, contaId, codigoPromocionalInfo, new Map<Id, Integer>(), false);
    }    

    public PesquisaCharter resumoChartCliente(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaCharter> charts = pesquisaChart(Para.Cliente.name(), trajeto, previsaoDeVoo, contaId, codigoPromocionalInfo, servicosContratados, true);

        PesquisaCharter chart = null;

        for (PesquisaCharter pesquisa : charts) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;         
    }
    
    public PesquisaCharter resumoChartParceiro(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaCharter> charts = pesquisaChart(Para.Parceiro.name(), trajeto, previsaoDeVoo, contaId, codigoPromocionalInfo, servicosContratados, true);

        PesquisaCharter chart = null;

        for (PesquisaCharter pesquisa : charts) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;             
    }
    
    public PesquisaCharter resumoChartConcierge(List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, Id modeloId, Map<Id, Integer> servicosContratados, String codigoPromocionalInfo) {
        List<PesquisaCharter> charts = pesquisaChart(Para.Concierge.name(), trajeto, previsaoDeVoo, contaId, codigoPromocionalInfo, servicosContratados, true);

        PesquisaCharter chart = null;

        for (PesquisaCharter pesquisa : charts) {
            if (pesquisa.modeloId == modeloId) {
                return pesquisa;
            }
        }

        return null;             
    }

    // #endregion 

    // #region Metodos da Oportunidade

    public void checkoutOportunidadeParceiro(Id oportunidadeID)
    {    
        checkoutOportunidade(Para.Parceiro.name(), oportunidadeID);
    }

    public void checkoutOportunidadetConcierge(Id oportunidadeID)
    {    
        checkoutOportunidade(Para.Concierge.name(), oportunidadeID);
    }

    public void recalculaOportunidadeParceiro(Id oportunidadeID)
    {    
        recalculaOportunidade(Para.Parceiro.name(), oportunidadeID);
    }

    public void recalculaOportunidadetConcierge(Id oportunidadeID)
    {    
        recalculaOportunidade(Para.Concierge.name(), oportunidadeID);
    }    

    public void cancelarOportunidade(Id oportunidadeID) {
        Savepoint sp = Database.setSavepoint();

        try {

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaCancelamento(oportunidadeID);

            INucleoCheckoutOportunidade checkout = CheckoutOportunidade.newInstanceNucleo(oportunidade);

            checkout.cancelaOportunidade(uow);

            uow.commitWork();

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            oportunidade = OpportunitySelector.newInstance().encontraParaCancelamento(oportunidadeID);

            checkout = CheckoutOportunidade.newInstanceNucleo(oportunidade);

            checkout.bloqueiaAlteracoesFase(uow2);

            uow2.commitWork();
        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }            
    }

    public Opportunity visualizarPromocaoOportunidade(Id oportunidadeID, Id promocaoId) {
        Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaMudarPromocao(oportunidadeID);

        CodigoPromocional__c promocao = CodigoPromocionalSelector.newInstance().selectById(promocaoId);            

        Boolean codigoJaUtilizado = OpportunitySelector.newInstance().idPromocionalUsadoNaConta(oportunidade.AccountId, promocao.Id);

        CheckoutOportunidade wrapCheckout = CheckoutOportunidade.newInstance(oportunidade);

        if (wrapCheckout.isVoo) {
            CheckoutOportunidadeVoo checkout = wrapCheckout.getCheckoutVoo();

            checkout.visualizarPromocaoOportunidade(promocao, codigoJaUtilizado);
        }

        return oportunidade;
    }    

    public void aplicarModeloPromocaoOportunidade(Id oportunidadeID, Id promocaoModeloId, String codigoPromocaoParceiro) {
        Savepoint sp = Database.setSavepoint();

        try {

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            CodigoPromocional__c promocaoModelo = CodigoPromocionalSelector.newInstance().selectById(promocaoModeloId);            

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaMudarPromocao(oportunidadeID);

            CodigoPromocional__c promocao = CodigoPromocional.clonaModeloPromocao(uow, promocaoModelo, oportunidade.AccountId, codigoPromocaoParceiro);

            uow.commitWork();

            promocao = CodigoPromocionalSelector.newInstance().selectById(promocao.Id);            

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            CheckoutOportunidade wrapCheckout = CheckoutOportunidade.newInstance(oportunidade);
            
            if (!wrapCheckout.isVoo) { 
                throw new CheckoutOportunidadeVoo.TipoOportunidadeInvalidaException(true);
            }

            CheckoutOportunidadeVoo checkout = wrapCheckout.getCheckoutVoo();

            Boolean codigoJaUtilizado = false;

            checkout.mudarPromocaoOportunidade(uow2, promocao, codigoJaUtilizado);

            uow2.commitWork(); 

            try {
                fflib_ISObjectUnitOfWork uow3 = Application.UnitOfWork.newInstance();

                oportunidade = OpportunitySelector.newInstance().encontraParaMudarPromocao(oportunidadeID);
    
                wrapCheckout = CheckoutOportunidade.newInstance(oportunidade);  
                checkout = wrapCheckout.getCheckoutVoo();
    
                if (!oportunidade.Sistema__c) {
                    checkout.bloqueiaAlteracoesFase(uow3);
                    uow3.commitWork();
                }    
            } catch (Exception e) {
                System.debug('Erro ao bloquear alteracoes, Oportunidade foi paga e sistema bloqueou a alteracao: ' + e.getMessage());
            }
        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    // #endregion

    // #region Métodos Privados Pesquisa Malha

    private List<PesquisaMalha> pesquisaMalhaVoos(String quem, Id contaId, Id origem, Id destino, Integer quantidade, DateTime previsaoDeVoo, Integer offSetDays, String codigoPromocionalInfo, Map<Id, Integer> servicosContratados, Boolean checkout)
    {
        List<PesquisaMalha> result = new List<PesquisaMalha>();

        PesquisaParametroOportunidade param = new PesquisaParametroOportunidade();

        Datetime menorData = Datetime.newInstance(previsaoDeVoo.date(), Time.newInstance(0, 0, 0, 0));
        Datetime maiorData = Datetime.newInstance(previsaoDeVoo.date().addDays(offSetDays), Time.newInstance(23, 59, 0, 0));

        param.quem = quem;
        param.contaId = contaId;
        param.quantidade = quantidade;
        param.malha_offsetDatas = offSetDays;
        param.produto = Product2Selector.newInstance().selectSeatProductByRoute(origem, destino);
        param.previsaoDeVoo = previsaoDeVoo;
        param.servicosContratados = servicosContratados;
        param.checkout = checkout;

        if (param.produto == null) {
            return result;
        }

        param.malha = MalhaVooSelector.newInstance().malhaDeVooDoProdutoNaData(param.produto.Id, param.previsaoDeVoo.date(), origem, destino, menorData, maiorData);

        if (param.malha == null) {
            return result;
        }
        
        param.locais = PesquisaMalha.buscaLocaisOrdenados(origem, destino);

        if (param.locais.size() != 2) {
            return result;
        }

        param.malha_trechos = TrechosSelector.newInstance().getTrechosByMalha(param.produto.Id, param.malha.Id, menorData, maiorData);
        param.aeronaves = PesquisaMalha.buscaAeronavesPrioritarias(param.malha.Id);

        if (param.aeronaves.isEmpty()) {
            return result;
        }

        Boolean calculaTranslado = false;
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.CalcularMissoes(param.locais, param.previsaoDeVoo.date(), param.aeronaves, calculaTranslado);
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.getCalculosViaveis(param.cmrsMapByAeronaveId);
        param.eventosPorAeronave = PesquisaMalha.buscaEventosAeronaves(param.cmrsMapByAeronaveId, menorData, maiorData);
        param.servicosDoProduto = PesquisaMalha.buscaServicosDoProduto(param.produto.Id);

        Set<Id> idProducts = new Set<Id> { param.produto.Id };

        for (ConfiguracaoPacote__c config : param.servicosDoProduto) {
            idProducts.add(config.ProdutoPacote__c);
        }        
    
        param.regrasDosProdutos = RegraProdutoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDosPrecos = RegraPrecoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDeDescontos = RegraDescontoSelector.newInstance().selectByIdProducts(idProducts);
        param.codigoPromocional = !String.isEmpty(codigoPromocionalInfo) ? CodigoPromocionalSelector.newInstance().selectByCodigo(codigoPromocionalInfo) : null;

        param.primeiraCompra = OpportunitySelector.newInstance().primeiraCompraConta(param.contaId);
        param.codigoJaUtilizado = OpportunitySelector.newInstance().codigoPromocionalUsadoNaConta(param.contaId, codigoPromocionalInfo);

        return PesquisaMalha.getPesquisasPorMalha( param );
    }

    // #endregion

    // #region Métodos Privados Pesquisa Full Cabin

    private List<PesquisaFullCabin> pesquisaFullCabin(String quem, Id contaId, Id origem, Id destino, DateTime previsaoDeVoo, String codigoPromocionalInfo, Map<Id, Integer> servicosContratados, Boolean checkout)
    {
        List<PesquisaFullCabin> result = new List<PesquisaFullCabin>();

        Datetime menorData = Datetime.newInstance(previsaoDeVoo.date(), Time.newInstance(0, 0, 0, 0));
        Datetime maiorData = Datetime.newInstance(previsaoDeVoo.date(), Time.newInstance(23, 59, 0, 0));

        PesquisaParametroOportunidade param = new PesquisaParametroOportunidade();

        param.quem = quem;
        param.contaId = contaId;
        param.quantidade = 1;
        param.produto = Product2Selector.newInstance().selectFullCabinProductByRoute(origem, destino);
        
        param.previsaoDeVoo = previsaoDeVoo;
        param.servicosContratados = servicosContratados;
        param.checkout = checkout;

        if (param.produto == null) {
            return result;
        }

        param.locais = PesquisaFullCabin.buscaLocaisOrdenados(origem, destino);
        param.aeronaves = PesquisaFullCabin.buscaAeronavesDisponiveis(param.produto.Id);

        Boolean calculaTranslado = false;
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.CalcularMissoes(param.locais, param.previsaoDeVoo.date(), param.aeronaves, calculaTranslado);
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.getCalculosViaveis(param.cmrsMapByAeronaveId);
        param.aeronaves = CalculoMissaoHelper.getAeronavesDosCalculos(param.cmrsMapByAeronaveId);
        param.eventosPorAeronave = PesquisaFullCabin.buscaEventosAeronaves(param.cmrsMapByAeronaveId, menorData, maiorData);

        Set<Id> idModelos = new Set<Id> ();

        for (Aeronave__c aeroNave : param.aeronaves) {
            idModelos.add(aeroNave.ModeloAeronave__c);
        }

        param.charter_modelos = new Map<Id, Product2>(Product2Selector.newInstance().selectById(idModelos));
        param.servicosDoProduto = PesquisaMalha.buscaServicosDoProduto(param.produto.Id);

        Set<Id> idProducts = new Set<Id> { param.produto.Id };

        for (ConfiguracaoPacote__c config : param.servicosDoProduto) {
            idProducts.add(config.ProdutoPacote__c);
        }        
    
        param.regrasDosProdutos = RegraProdutoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDosPrecos = RegraPrecoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDeDescontos = RegraDescontoSelector.newInstance().selectByIdProducts(idProducts);
        param.codigoPromocional = !String.isEmpty(codigoPromocionalInfo) ? CodigoPromocionalSelector.newInstance().selectByCodigo(codigoPromocionalInfo) : null;

        param.primeiraCompra = OpportunitySelector.newInstance().primeiraCompraConta(param.contaId);
        param.codigoJaUtilizado = OpportunitySelector.newInstance().codigoPromocionalUsadoNaConta(param.contaId, codigoPromocionalInfo);

        return PesquisaFullCabin.getPesquisasPorFullCabin ( param );
    }    

    // #endregion

    // #region Métodos Privados Pesquisa Charter

    private List<Local__c> locaisOrdenados(Map<Integer, Id> locaisTrajeto) {
        Map<Id, Local__c> trajetos = new Map<Id, Local__c>(LocaisSelector.newInstance().selectById(new Set<Id>(locaisTrajeto.values())));

        List<Integer> sequence = new List<Integer>(locaisTrajeto.keyset());

        List<Local__c> sequenciado = new List<Local__c>();

        for (Integer key : sequence) {
            Id oId = locaisTrajeto.get(key);

            if (trajetos.containsKey(oId)) {
                sequenciado.add(trajetos.get(oId));
            }
        }

        return sequenciado;
    }

    private List<PesquisaCharter> pesquisaChart(String quem, List<Local__c> trajeto, DateTime previsaoDeVoo, Id contaId, String codigoPromocionalInfo, Map<Id, Integer> servicosContratados, Boolean checkout)
    {
        List<PesquisaCharter> result = new List<PesquisaCharter>();

        Datetime menorData = Datetime.newInstance(previsaoDeVoo.date(), Time.newInstance(0, 0, 0, 0));
        Datetime maiorData = Datetime.newInstance(previsaoDeVoo.date(), Time.newInstance(23, 59, 0, 0));

        PesquisaParametroOportunidade param = new PesquisaParametroOportunidade();

        param.quem = quem;
        param.contaId = contaId;
        param.quantidade = 1;
        param.produto = Product2Selector.newInstance().selectCharterProduct();
        param.previsaoDeVoo = previsaoDeVoo;
        param.locais = trajeto;
        param.servicosContratados = servicosContratados;
        param.checkout = checkout;

        if (param.produto == null) {
            return result;
        }

        param.aeronaves = PesquisaCharter.buscaAeronavesDisponiveis(param.produto.Id);

        Boolean calculaTranslado = true;
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.CalcularMissoes(param.locais, param.previsaoDeVoo.date(), param.aeronaves, calculaTranslado);
        param.cmrsMapByAeronaveId = CalculoMissaoHelper.getCalculosViaveis(param.cmrsMapByAeronaveId);
        param.aeronaves = CalculoMissaoHelper.getAeronavesDosCalculos(param.cmrsMapByAeronaveId);

        param.eventosPorAeronave = PesquisaCharter.buscaEventosAeronaves(param.cmrsMapByAeronaveId, menorData, maiorData);

        Set<Id> idModelos = new Set<Id> ();

        for (Aeronave__c aeroNave : param.aeronaves) {
            idModelos.add(aeroNave.ModeloAeronave__c);
        }

        param.charter_modelos = new Map<Id, Product2>(Product2Selector.newInstance().selectById(idModelos));
        param.servicosDoProduto = PesquisaMalha.buscaServicosDoProduto(param.produto.Id);

        Set<Id> idProducts = new Set<Id> { param.produto.Id };

        for (ConfiguracaoPacote__c config : param.servicosDoProduto) {
            idProducts.add(config.ProdutoPacote__c);
        }        
    
        param.regrasDosProdutos = RegraProdutoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDosPrecos = RegraPrecoSelector.newInstance().selectByIdProducts(idProducts);
        param.regrasDeDescontos = RegraDescontoSelector.newInstance().selectByIdProducts(idProducts);
        param.codigoPromocional = !String.isEmpty(codigoPromocionalInfo) ? CodigoPromocionalSelector.newInstance().selectByCodigo(codigoPromocionalInfo) : null;

        param.primeiraCompra = OpportunitySelector.newInstance().primeiraCompraConta(param.contaId);
        param.codigoJaUtilizado = OpportunitySelector.newInstance().codigoPromocionalUsadoNaConta(param.contaId, codigoPromocionalInfo);

        return PesquisaCharter.getPesquisasPorCharter ( param );
    }

    // #endregion

    // #region Métodos Privados Outros

    private void recalculaOportunidade(String quem, Id oportunidadeID) {
        Savepoint sp = Database.setSavepoint();

        try {

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaFechamento(oportunidadeID);

            CheckoutOportunidade wrapCheckout = CheckoutOportunidade.newInstance(oportunidade);
            
            if (!wrapCheckout.isVoo) { 
                throw new CheckoutOportunidadeVoo.TipoOportunidadeInvalidaException(true);
            }

            CheckoutOportunidadeVoo checkout = wrapCheckout.getCheckoutVoo();

            if (oportunidade.Type == 'ShuttleSeat') {
                for (Id key : checkout.voosOportunidade.keyset()) {
                    Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                    OpportunityLineItem line = checkout.voosOportunidade.get(key);

                    if (checkout.servicosTaxas.containsKey(line.Id)) {
                        for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                            mapServicos.put(service.Product2Id, service.Quantity.intValue());
                        }
                    }
            
                    List<PesquisaMalha> malhas = pesquisaMalhaVoos(
                        quem, oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                        line.Quantity.intValue(), line.PrevisaoEmbarque__c, 0, oportunidade.CodigoPromocional__r.Name, 
                        mapServicos, true
                    );
                    
                    PesquisaMalha malha = malhas.isEmpty() ? null : malhas[0];

                    checkout.carregaCalculo(line.Id, malha);
                }

                checkout.atualizaPrecosOportunidade(uow);
            } 

            if (oportunidade.Type == 'FullCabin') {
                for (Id key : checkout.voosOportunidade.keyset()) {
                    Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                    OpportunityLineItem line = checkout.voosOportunidade.get(key);

                    if (checkout.servicosTaxas.containsKey(line.Id)) {
                        for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                            mapServicos.put(service.Product2Id, service.Quantity.intValue());
                        }
                    }
            
                    List<PesquisaFullCabin> fulls = pesquisaFullCabin(
                        quem, oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                        line.PrevisaoEmbarque__c, oportunidade.CodigoPromocional__r.Name, 
                        mapServicos, true
                    );
                    
                    PesquisaFullCabin fullcabin = null;

                    for (PesquisaFullCabin pesquisa : fulls) {
                        if (line.ModeloSelecionado__c == pesquisa.modeloId) {
                            fullcabin = pesquisa;
                            break;
                        }
                    }

                    checkout.carregaCalculo(line.Id, fullcabin);
                }

                checkout.atualizaPrecosOportunidade(uow);
            }

            if (oportunidade.Type == 'Charter') {
                for (Id key : checkout.voosOportunidade.keyset()) {
                    Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                    OpportunityLineItem line = checkout.voosOportunidade.get(key);

                    if (checkout.servicosTaxas.containsKey(line.Id)) {
                        for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                            mapServicos.put(service.Product2Id, service.Quantity.intValue());
                        }
                    }
            
                    List<Local__c> locais = RevoSiteCharterSearch.parse(line.LocaisProdutoOportunidade__r);

                    List<PesquisaCharter> charts = pesquisaChart(
                        quem, locais, line.PrevisaoEmbarque__c, oportunidade.AccountId, 
                        oportunidade.CodigoPromocional__r.Name, mapServicos, true
                    );
                    
                    PesquisaCharter charter = null;

                    for (PesquisaCharter pesquisa : charts) {
                        if (line.ModeloSelecionado__c == pesquisa.modeloId) {
                            charter = pesquisa;
                            break;
                        }
                    }

                    checkout.carregaCalculo(line.Id, charter);
                }

                checkout.atualizaPrecosOportunidade(uow);
            }            

            uow.commitWork(); 
        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }    

    private void checkoutOportunidade(String quem, Id oportunidadeID) {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaFechamento(oportunidadeID);

            CheckoutOportunidade wrapCheckout = CheckoutOportunidade.newInstance(oportunidade);
            
            if (wrapCheckout.isVoo) {
                CheckoutOportunidadeVoo checkout = wrapCheckout.getCheckoutVoo();

                if (oportunidade.Type == 'ShuttleSeat') {
                    for (Id key : checkout.voosOportunidade.keyset()) {
                        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                        OpportunityLineItem line = checkout.voosOportunidade.get(key);

                        if (checkout.servicosTaxas.containsKey(line.Id)) {
                            for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                                mapServicos.put(service.Product2Id, service.Quantity.intValue());
                            }
                        }
                
                        List<PesquisaMalha> malhas = pesquisaMalhaVoos(
                            quem, oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                            line.Quantity.intValue(), line.PrevisaoEmbarque__c, 0, oportunidade.CodigoPromocional__r.Name, 
                            mapServicos, true
                        );
                        
                        PesquisaMalha malha = malhas.isEmpty() ? null : malhas[0];

                        checkout.carregaCalculo(line.Id, malha);
                    }
                } 

                if (oportunidade.Type == 'FullCabin') {
                    for (Id key : checkout.voosOportunidade.keyset()) {
                        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                        OpportunityLineItem line = checkout.voosOportunidade.get(key);

                        if (checkout.servicosTaxas.containsKey(line.Id)) {
                            for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                                mapServicos.put(service.Product2Id, service.Quantity.intValue());
                            }
                        }
                
                        List<PesquisaFullCabin> fulls = pesquisaFullCabin(
                            quem, oportunidade.AccountId, line.Origem__c, line.Destino__c, 
                            line.PrevisaoEmbarque__c, oportunidade.CodigoPromocional__r.Name, 
                            mapServicos, true
                        );
                        
                        PesquisaFullCabin fullcabin = null;

                        for (PesquisaFullCabin pesquisa : fulls) {
                            if (line.ModeloSelecionado__c == pesquisa.modeloId) {
                                fullcabin = pesquisa;
                                break;
                            }
                        }

                        checkout.carregaCalculo(line.Id, fullcabin);
                    }
                }

                if (oportunidade.Type == 'Charter') {
                    for (Id key : checkout.voosOportunidade.keyset()) {
                        Map<Id, Integer> mapServicos = new Map<Id, Integer>();

                        OpportunityLineItem line = checkout.voosOportunidade.get(key);

                        if (checkout.servicosTaxas.containsKey(line.Id)) {
                            for (OpportunityLineItem service : checkout.servicosTaxas.get(line.Id)) {
                                mapServicos.put(service.Product2Id, service.Quantity.intValue());
                            }
                        }
                
                        List<Local__c> locais = RevoSiteCharterSearch.parse(line.LocaisProdutoOportunidade__r);

                        List<PesquisaCharter> charts = pesquisaChart(
                            quem, locais, line.PrevisaoEmbarque__c, oportunidade.AccountId, 
                            oportunidade.CodigoPromocional__r.Name, mapServicos, true
                        );
                        
                        PesquisaCharter charter = null;

                        for (PesquisaCharter pesquisa : charts) {
                            if (line.ModeloSelecionado__c == pesquisa.modeloId) {
                                charter = pesquisa;
                                break;
                            }
                        }

                        checkout.carregaCalculo(line.Id, charter);
                    }
                }            
            }

            INucleoCheckoutOportunidade checkoutNucleo = wrapCheckout.getCheckoutNucleo();

            checkoutNucleo.validaOportunidade();

            checkoutNucleo.validaOsProdutos();

            checkoutNucleo.confirmaCheckout(uow);

            uow.commitWork();                    

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            if (wrapCheckout.isVoo) {
                CheckoutOportunidadeVoo checkout = wrapCheckout.getCheckoutVoo();

                checkout.preReservaVoos(uow2);
            }

            checkoutNucleo.bloqueiaAlteracoesFase(uow2);

            uow2.commitWork();

        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }    

    // #endregion

    // #region Classe Base de Erros

    public virtual class OpportunityException extends Exception {
        public String codigo;
    
        public OpportunityException(String codigo, String mensagem) {
            this(codigo + ': ' + mensagem);
            this.codigo = codigo;
        }
    }    

    // #endregion

}