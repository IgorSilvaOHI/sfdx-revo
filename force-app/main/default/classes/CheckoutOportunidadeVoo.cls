public without sharing class CheckoutOportunidadeVoo implements INucleoCheckoutOportunidade {

    // #region Variaveis Publicas

    public Map<Id, OpportunityLineItem> voosOportunidade { get; private set; }
    public Map<Id, List<OpportunityLineItem>> servicosTaxas { get; private set; }
    public Map<Id, PesquisaMalha> calculosShuttlerSeats { get; private set; }
    private Map<Id, PesquisaFullCabin> calculosFullCabins { get; private set; }
    private Map<Id, PesquisaCharter> calculosCharters { get; private set; }

    // #endregion

    // #region Variaveis Privadas
    private static Set<String> tipoOportunidades = new Set<String> { 'ShuttleSeat', 'FullCabin', 'Charter' };
    private List<Voo__c> voosRascunhos = new List<Voo__c>();

    private Opportunity oportunidade;

    private enum TiposDeProdutos {
        ShuttleSeat, FullCabin, CharterFlight, ServicosTaxas
    }    

    // #endregion

    // #region Construtor

    public CheckoutOportunidadeVoo(Opportunity oportunidade) {
        if (oportunidade == null) {
            throw new OportunidadeNaoEncontradaException(true);
        }

        this.oportunidade = oportunidade;
        this.servicosTaxas = new Map<Id, List<OpportunityLineItem>>();
        this.voosOportunidade = new Map<Id, OpportunityLineItem>();
        this.calculosShuttlerSeats = new Map<Id, PesquisaMalha>();
        this.calculosFullCabins = new Map<Id, PesquisaFullCabin>();
        this.calculosCharters = new Map<Id, PesquisaCharter>();

        Map<Id, String> mapProductsTypes = productRecordTypesIds();
        Set<String> OpportunityProducts = enumTiposDeProdutosToSet();

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {
            
            if (!OpportunityProducts.contains(mapProductsTypes.get(item.Product2.RecordTypeId))) {
                throw new ProdutoInvalidoNaOportunidadeException(true);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ServicosTaxas.name()){
                if (!this.ServicosTaxas.containskey(item.Pacote__c)) {
                    this.ServicosTaxas.put(item.Pacote__c, new List<OpportunityLineItem>());
                }

                List<OpportunityLineItem> lista = this.ServicosTaxas.get(item.Pacote__c);
                lista.add(item);
            } else {
                this.voosOportunidade.put(item.Id, item);
            }
        }

    }

    // #endregion

    // #region Métodos Públicos

    public void carregaCalculo(Id lineId, PesquisaMalha pesquisa) {

        validaExistenciaCalculo(lineId);

        if (oportunidade.Type != 'ShuttleSeat') {
            throw new ProdutoInvalidoNaOportunidadeException(true);
        }

        calculosShuttlerSeats.put(lineId, pesquisa);
    }

    public void carregaCalculo(Id lineId, PesquisaFullCabin pesquisa) {

        validaExistenciaCalculo(lineId);

        if (oportunidade.Type != 'FullCabin') {
            throw new ProdutoInvalidoNaOportunidadeException(true);
        }

        calculosFullCabins.put(lineId, pesquisa);
    }

    public void carregaCalculo(Id lineId, PesquisaCharter pesquisa) {

        validaExistenciaCalculo(lineId);

        if (oportunidade.Type != 'Charter') {
            throw new ProdutoInvalidoNaOportunidadeException(true);
        }        
        calculosCharters.put(lineId, pesquisa);
    }    
    
    public void validaOportunidade() {

        if (oportunidade.StageName != 'Cotação' && oportunidade.StageName != 'Aguardando Validação') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        if (oportunidade.AccountId == null) {
            throw new ContaOportunidadeNaoInformadaException(true);
        }

        if (oportunidade.FaturadoPara__c == null) {
            throw new ContaDeFaturamentoNaoInformadaException(true);
        }

        if (oportunidade.OpportunityLineItems.isEmpty()) {
            throw new OportunidadeSemProdutosException(true);
        }

        if (!tipoOportunidades.contains(oportunidade.Type)) {
            throw new TipoOportunidadeInvalidaException(true);
        }

        if (oportunidade.ValidadeUltimoCalculo__c == null || oportunidade.ValidadeUltimoCalculo__c <= DateTime.now()) {
            throw new CalculoOportunidadeExpiradoException(true);
        }
    }

    public void validaOsProdutos() {

        Map<Id, String> mapProductsTypes = productRecordTypesIds();

        Map<Id, OpportunityLineItem> mapProdutoOportunidade = new Map<Id, OpportunityLineItem>(oportunidade.OpportunityLineItems);

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ShuttleSeat.name()){
                validaItemOppShuttlerSeat(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.FullCabin.name()){
                validaItemOppFullCabin(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.CharterFlight.name()){
                validaItemOppCharterFlight(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ServicosTaxas.name()){
                Boolean validarQuantidadePaassageiros = mapProductsTypes.get(item.Pacote__r.Product2.RecordTypeId) == TiposDeProdutos.ShuttleSeat.name();

                validaItemOppServicosTaxas(item, validarQuantidadePaassageiros);
            }        
        }               
    }

    public void atualizaPrecosOportunidade(fflib_ISObjectUnitOfWork uow) {

        if (oportunidade.StageName != 'Cotação' && oportunidade.StageName != 'Aguardando Validação') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        if (oportunidade.OpportunityLineItems.isEmpty()) {
            throw new OportunidadeSemProdutosException(true);
        }

        Map<Id, String> mapProductsTypes = productRecordTypesIds();

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ShuttleSeat.name()){
                atualizaPrecoShuttle(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.FullCabin.name()){
                atualizaPrecoFullCabin(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.CharterFlight.name()){
                atualizaPrecoCharter(item);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ServicosTaxas.name()){
                atualizaPrecoServico(item);
            }

            uow.registerDirty(item);
        }

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioSelecaoVoo__c;

        this.oportunidade.ValidadeUltimoCalculo__c = System.now();
        this.oportunidade.ValidadeUltimoCalculo__c = this.oportunidade.ValidadeUltimoCalculo__c .addMinutes(Integer.valueOf(tempoParaResetar));        

        uow.registerDirty(this.oportunidade);
    }

    public void visualizarPromocaoOportunidade(CodigoPromocional__c promocao, Boolean codigoJaUtilizado) {

        validaPromocaoOportunidade(codigoJaUtilizado);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        operacaoMudarPromocaoOportunidade(uow, promocao, codigoJaUtilizado, null);
    }

    public void mudarPromocaoOportunidade(fflib_ISObjectUnitOfWork uow, CodigoPromocional__c promocao, Boolean codigoJaUtilizado) {

        validaPromocaoOportunidade(codigoJaUtilizado);

        Servico__c servicoParceiro = null;

        if (promocao.RecordTypeId == codigoPromocionalParceiroRecordTypeId() 
            && promocao.GeraCobrancaParceiro__c 
            && promocao.ValorCobrancaParceiro__c > 0) {

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
                
            servicoParceiro = Servicos.criarServicoParceiro(uow2, oportunidade, promocao);

            uow2.commitWork();
        }            

        operacaoMudarPromocaoOportunidade(uow, promocao, codigoJaUtilizado, servicoParceiro);
    }
 

    public void confirmaCheckout(fflib_ISObjectUnitOfWork uow) {

        Map<Id, String> mapProductsTypes = productRecordTypesIds();

        for (Id key : this.voosOportunidade.keyset()) {

            OpportunityLineItem item = this.voosOportunidade.get(key);

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.ShuttleSeat.name()){
                PesquisaMalha malha = calculosShuttlerSeats.get(item.Id);
                confirmaProdutoVooShuttle(uow, item, malha);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.FullCabin.name()){
                PesquisaFullCabin pesquisa = calculosFullCabins.get(item.Id);
                BlocoFullCabin fullcabin = pesquisa.horarios[0];
                confirmaProdutoVooFullCabin(uow, item, fullcabin);
            }

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.CharterFlight.name()){
                PesquisaCharter pesquisa = calculosCharters.get(item.Id);
                BlocoCharter bloco = pesquisa.horarios[0];
                confirmaProdutoVooCharter(uow, item, bloco);
            }
        }            

        if (oportunidade.CodigoPromocional__c != null) {
            Opportunities.criaPromocaoOportunidade(uow, oportunidade, oportunidade.CodigoPromocional__c);
        }
        
        oportunidade.StageName = 'Aguardando Pagamento';
        oportunidade.Sistema__c = true;

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioReservarVoo__c;

        this.oportunidade.LimitePagamento__c = System.now();
        this.oportunidade.LimitePagamento__c = this.oportunidade.LimitePagamento__c.addMinutes(Integer.valueOf(tempoParaResetar));        

        uow.registerDirty(oportunidade);
    }

    public void preReservaVoos(fflib_ISObjectUnitOfWork uow) {

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioReservarVoo__c;
        tempoParaResetar += 60;
        Datetime dataReset = System.now();
        dataReset = dataReset.addMinutes(Integer.valueOf(tempoParaResetar));
        
        for(Voo__c voo: this.voosRascunhos)
        {
            voo.Status__c = oportunidade.Type == 'ShuttleSeat' ? 'Reservado' : 'Pré-reservado';
            voo.DataRemocaoPreReserva__c = dataReset;
            voo.ResetarPreReserva__c = oportunidade.Type == 'ShuttleSeat' ? false : true;
            voo.DataResetPreReserva__c = oportunidade.Type == 'ShuttleSeat' ? null : System.now().addMinutes(60).addSeconds(1);
        }

        if (!this.voosRascunhos.isEmpty()) {
            uow.registerDirty(this.voosRascunhos);
        }
    }

    public void atualizaLinkPagamento(fflib_ISObjectUnitOfWork uow, String linkPagamento) {

        ConfiguracaoPagamento__c configuracaoPagamento = ConfiguracaoPagamento__c.getOrgDefaults();
		String urlBase = configuracaoPagamento.UrlBaseLinkPagamento__c;

        oportunidade.LinkPagamento__c = linkPagamento;
        oportunidade.Sistema__c = true;

        uow.registerDirty(oportunidade);
    }    

    public void bloqueiaAlteracoesFase(fflib_ISObjectUnitOfWork uow) {

        oportunidade.Sistema__c = false;

        uow.registerDirty(oportunidade);
    }    

    public void cancelaOportunidade(fflib_ISObjectUnitOfWork uow) {
        
        if (oportunidade.StageName != 'Cotação' && oportunidade.StageName != 'Aguardando Validação'
        && oportunidade.StageName != 'Aguardando Pagamento') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        this.oportunidade.Sistema__c = true;

        this.oportunidade.StageName = 'Cancelado';

        uow.registerDirty(this.oportunidade);

        for (Servico__c servico : this.oportunidade.Servicos__r) {

            if (this.oportunidade.type == 'ShuttleSeat' && servico.Passageiro__r != null) {
                uow.registerDeleted(servico.Passageiro__r);
            }

            if (this.oportunidade.type == 'FullCabin' && servico.Voo__r != null) {
                uow.registerDeleted(servico.Voo__r);
            }

            if (this.oportunidade.type == 'Charter' && servico.Voo__r != null) {
                uow.registerDeleted(servico.Voo__r);
            }
        }

        if (this.oportunidade.PromocoesOportunidades__r != null && !this.oportunidade.PromocoesOportunidades__r.isEmpty()) {
            uow.registerDeleted(this.oportunidade.PromocoesOportunidades__r);
        }

        if (this.oportunidade.Servicos__r != null && !this.oportunidade.Servicos__r.isEmpty()) {
            uow.registerDeleted(this.oportunidade.Servicos__r);
        }
    }

    // #endregion
    
    // #region Métodos Privados - Checkout

    private void confirmaProdutoVooShuttle(fflib_ISObjectUnitOfWork uow, OpportunityLineItem item, PesquisaMalha malha) {

        Trecho__c trechoValido = malha.trecho;
        Voo__c novoVoo = malha.trecho != null ? new Voo__c (Id = malha.trecho.Voo__c) : null;        

        Map<Id, Passageiro__c> contatoPassageiro = new Map<Id, Passageiro__c>();

        if (trechoValido == null) {
            List<Local__c> rota = new List<Local__c> { item.Origem__r, item.Destino__r };

            String horario = malha.dataHora.format('HH:mm');

            novoVoo = Voos.criarVooRascunho(uow, item.PrevisaoEmbarque__c, malha.aeronave, item.MalhaVoo__r.OperadorMalha__c, 'ShuttleSeat', rota, false, true);
            trechoValido = Voos.criarTrecho(uow, item.Origem__c, item.Destino__c, novoVoo, 10, 'Passageiros', item.Product2Id, item.MalhaVoo__c, horario);

            this.voosRascunhos.add(novoVoo);
        }

        for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
            Passageiro__c passageiroVoo = Voos.criarPassageiro(uow, trechoValido, passageiro.PassageiroOportunidade__r.Passageiro__c, this.oportunidade.CodigoReserva__c);
            contatoPassageiro.put(passageiro.PassageiroOportunidade__r.Passageiro__c, passageiroVoo);
       
            Servicos.criarServicoOportunidade(uow, this.oportunidade, item, novoVoo, trechoValido, passageiroVoo, item.TotalPrice / item.Quantity, item.TotalRevoSeats__c / item.Quantity,
                    passageiro.Observacoes__c, passageiro.EnderecoServico__c, passageiro.CidadeServico__c, passageiro.EstadoServico__c, passageiro.PaisServico__c, 
                    passageiro.ComplementoEndereco__c, passageiro.CEPServico__c, passageiro.CompanhiaAerea__c,
                    passageiro.NumeroVoo__c, passageiro.QtdsMalasGrandes__c, passageiro.QtdsMalasMedias__c, 
                    passageiro.QtdsMalasPequenas__c);
        
        }

        if (this.ServicosTaxas.containskey(item.Id)) {
            for (OpportunityLineItem servico : this.ServicosTaxas.get(item.Id)) {
                if (servico.ServicaoPorPassageiro__c) {
                    for (ProdutoPassageiro__c passageiro : servico.ProdutosPassageiro__r) {
                        if(passageiro.Status__c == 'Configurado'){
                            Passageiro__c passageiroVoo = contatoPassageiro.get(passageiro.PassageiroOportunidade__r.Passageiro__c);
                            Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, trechoValido, passageiroVoo, servico.TotalPrice / servico.Quantity, servico.TotalRevoSeats__c / servico.Quantity,
                            passageiro.Observacoes__c, passageiro.EnderecoServico__c, passageiro.CidadeServico__c, passageiro.EstadoServico__c, passageiro.PaisServico__c, 
                            passageiro.ComplementoEndereco__c, passageiro.CEPServico__c, passageiro.CompanhiaAerea__c,
                            passageiro.NumeroVoo__c, passageiro.QtdsMalasGrandes__c, passageiro.QtdsMalasMedias__c, 
                            passageiro.QtdsMalasPequenas__c);
                        }
                    }
                } else if(!servico.ServicaoPorPassageiro__c){
                    Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, trechoValido, null, servico.TotalPrice, servico.TotalRevoSeats__c);
                }
            }
        }
    }    

    private void confirmaProdutoVooFullCabin(fflib_ISObjectUnitOfWork uow, OpportunityLineItem item, BlocoFullCabin bloco) {

        List<Local__c> rota = new List<Local__c> { item.Origem__r, item.Destino__r };

        Voo__c novoVoo = Voos.criarVooRascunho(uow, item.PrevisaoEmbarque__c, bloco.aeronave, this.Oportunidade.AccountId, 'FullCabin', rota, false, true);
        Trecho__c trechoValido = Voos.criarTrecho(uow, item.Origem__c, item.Destino__c, novoVoo, 10, 'Passageiros');

        this.voosRascunhos.add(novoVoo);

        Map<Id, Passageiro__c> contatoPassageiro = new Map<Id, Passageiro__c>();

        for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
            Passageiro__c passageiroVoo = Voos.criarPassageiro(uow, trechoValido, passageiro.PassageiroOportunidade__r.Passageiro__c, this.oportunidade.CodigoReserva__c);
            contatoPassageiro.put(passageiro.PassageiroOportunidade__r.Passageiro__c, passageiroVoo);
        }

        Servicos.criarServicoOportunidade(uow, this.oportunidade, item, novoVoo, trechoValido, null, item.TotalPrice, item.TotalRevoSeats__c);

        if (this.ServicosTaxas.containskey(item.Id)) {
            
            for (OpportunityLineItem servico : this.ServicosTaxas.get(item.Id)) {
                if (servico.ServicaoPorPassageiro__c) {
                    Integer totalConfigurado = 0;
                    for (ProdutoPassageiro__c passageiro : servico.ProdutosPassageiro__r) {
                        if(passageiro.Status__c == 'Configurado'){
                            Passageiro__c passageiroVoo = contatoPassageiro.get(passageiro.PassageiroOportunidade__r.Passageiro__c);
                            Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, trechoValido, passageiroVoo, servico.TotalPrice / servico.Quantity, servico.TotalRevoSeats__c / servico.Quantity,
                            passageiro.Observacoes__c, passageiro.EnderecoServico__c, passageiro.CidadeServico__c, passageiro.EstadoServico__c, passageiro.PaisServico__c, 
                            passageiro.ComplementoEndereco__c, passageiro.CEPServico__c, passageiro.CompanhiaAerea__c,
                            passageiro.NumeroVoo__c, passageiro.QtdsMalasGrandes__c, passageiro.QtdsMalasMedias__c, 
                            passageiro.QtdsMalasPequenas__c);
                            totalConfigurado++;
                        }
                    }

                    for (Integer i = 0; i < servico.Quantity - totalConfigurado; i++) {
                        Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, trechoValido, null, servico.TotalPrice / servico.Quantity, servico.TotalRevoSeats__c / servico.Quantity);
                    }

                } else {
                    Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, trechoValido, null, servico.TotalPrice, servico.TotalRevoSeats__c);
                }
            }
        }
    }

    private void confirmaProdutoVooCharter( fflib_ISObjectUnitOfWork uow, OpportunityLineItem item, BlocoCharter bloco) {

        List<Local__c> rota = new List<Local__c>();

        for (LocalOportunidade__c local : item.LocaisProdutoOportunidade__r) {
            rota.add(local.Local__r);
        }

        Id origemInicial = rota.isEmpty() ? null : rota[0].Id;

        Voo__c novoVoo = Voos.criarVooRascunho(uow, item.PrevisaoEmbarque__c, bloco.aeronave.Id, this.Oportunidade.AccountId, 'Charter', rota, true, true);

        this.voosRascunhos.add(novoVoo);

        if(bloco.aeronave.BaseMae__c != origemInicial)
        {
            Trecho__c trechoValido = Voos.criarTrecho(uow, bloco.aeronave.BaseMae__c, origemInicial, novoVoo, 5, 'Translado');
        }        

        Id localOrigem = null;
        Id localDestino = null;
        Id ultDestino = null;
        Integer sequencia = 0;
        List<Trecho__c> trechosComPassageiros = new List<Trecho__c>();

        for (LocalOportunidade__c local : item.LocaisProdutoOportunidade__r) {

            if (localOrigem == null) { 
                localOrigem = local.Local__c;
            } else {
                localDestino = local.Local__c;
                sequencia += 10;

                Trecho__c trechoValido = Voos.criarTrecho(uow, localOrigem, localDestino, novoVoo, sequencia, 'Passageiros');
                trechosComPassageiros.add(trechoValido);

                localOrigem = localDestino;
            }

            ultDestino = local.Local__c;
        }

        if(bloco.aeronave.BaseMae__c != ultDestino)
        {
            Trecho__c trechoValido = Voos.criarTrecho(uow, ultDestino, bloco.aeronave.BaseMae__c, novoVoo, sequencia + 5, 'Translado');
        }        

        Map<Id, Passageiro__c> contatoPassageiro = new Map<Id, Passageiro__c>();

        Trecho__c primeiroTrecho = trechosComPassageiros[0];

        Servicos.criarServicoOportunidade(uow, this.oportunidade, item, novoVoo, primeiroTrecho, null, item.TotalPrice, item.TotalRevoSeats__c);

        for (Trecho__c trecho : trechosComPassageiros) {

            for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
                Passageiro__c passageiroVoo = Voos.criarPassageiro(uow, trecho, passageiro.PassageiroOportunidade__r.Passageiro__c, this.oportunidade.CodigoReserva__c);
                contatoPassageiro.put(passageiro.PassageiroOportunidade__r.Passageiro__c, passageiroVoo);
            }            
        }
    
        if (this.ServicosTaxas.containskey(item.Id)) {
            for (OpportunityLineItem servico : this.ServicosTaxas.get(item.Id)) {
                if (servico.ServicaoPorPassageiro__c) {
                    Integer totalConfigurado = 0;

                    for (ProdutoPassageiro__c passageiro : servico.ProdutosPassageiro__r) {
                        if(passageiro.Status__c == 'Configurado'){
                            Passageiro__c passageiroVoo = contatoPassageiro.get(passageiro.PassageiroOportunidade__r.Passageiro__c);
                            Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, primeiroTrecho, passageiroVoo, servico.TotalPrice / servico.Quantity, servico.TotalRevoSeats__c / servico.Quantity,
                            passageiro.Observacoes__c, passageiro.EnderecoServico__c, passageiro.CidadeServico__c, passageiro.EstadoServico__c, passageiro.PaisServico__c, 
                            passageiro.ComplementoEndereco__c, passageiro.CEPServico__c, passageiro.CompanhiaAerea__c,
                            passageiro.NumeroVoo__c, passageiro.QtdsMalasGrandes__c, passageiro.QtdsMalasMedias__c, 
                            passageiro.QtdsMalasPequenas__c);
                            totalConfigurado++;
                        }
                    }

                    for (Integer i = 0; i < servico.Quantity - totalConfigurado; i++) {
                        Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, primeiroTrecho, null, servico.TotalPrice / servico.Quantity, servico.TotalRevoSeats__c / servico.Quantity);
                    }
                } else {
                    Servicos.criarServicoOportunidade(uow, this.oportunidade, servico, novoVoo, primeiroTrecho, null, servico.TotalPrice, servico.TotalRevoSeats__c);
                }                
            }
        }
    }

    // #endregion

    // #region Métodos Privados - Atualização de Preço 

    private void atualizaPromocao(fflib_ISObjectUnitOfWork uow, OpportunityLineItem item, Boolean ehServico, CodigoPromocional__c promocao, Datetime previsaoEmbarque, Boolean codigoJaUtilizado) {
        CodigoPromocional.PromocaoValidaProduto promocaoValida = CodigoPromocional.encontraMelhorPromocao(
            promocao, this.oportunidade.AccountId, item.Product2Id, ehServico, previsaoEmbarque.date(), false, item.PrecoUnitario__c, item.Quantity, false, codigoJaUtilizado
        );                  

        if (promocaoValida != null && !item.Empacotado__c) {
            Decimal precoFinal = (item.PrecoUnitario__c - promocaoValida.descontoValor) * (1 - promocaoValida.descontoPerc / 100) * item.Quantity;            

            item.UnitPrice = precoFinal / item.Quantity;
            item.DescontoValor__c = promocaoValida.descontoValor;
            item.DescontoPercentual__c = promocaoValida.descontoPerc;            

            uow.registerDirty(item);            
        }                
    }

    private void atualizaPrecoShuttle(OpportunityLineItem item) {
        if (!this.calculosShuttlerSeats.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }              
        
        PesquisaMalha malha = this.calculosShuttlerSeats.get(item.Id);

        if (malha == null) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (malha.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (item.Product2Id != malha.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.MalhaVoo__c != malha.malhaId) {
            throw new MudancaNosDetalhesDoVooException(true);
        }
        
        item.PrecoUnitario__c = malha.precoUnitario;
        item.UnitPrice = malha.precoFinal / malha.quantidade;
        item.PrecoRevoSeats__c = malha.precoRevoSeats;
        item.TotalRevoSeats__c = malha.precoFinalRevoSeats;
        item.DescontoValor__c = malha.descontoValor;
        item.DescontoPercentual__c = malha.descontoPerc;
    }

    private void atualizaPrecoFullCabin(OpportunityLineItem item) {
        if (!this.calculosFullCabins.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }

        PesquisaFullCabin pesquisa = this.calculosFullCabins.get(item.Id);
        BlocoFullCabin fullcabin = pesquisa.horarios[0];

        if (item.Product2Id != pesquisa.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.Origem__c != pesquisa.origem) {
            throw new MudancaNosDetalhesDoVooException(true);
        }
        
        if (item.Destino__c != pesquisa.destino) {
            throw new MudancaNosDetalhesDoVooException(true);
        }        

        if (fullcabin == null) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (fullcabin.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }   
        
        item.PrecoUnitario__c = fullcabin.precoUnitario;
        item.UnitPrice = fullcabin.precoFinal;
        item.PrecoRevoSeats__c = fullcabin.precoRevoSeats;
        item.TotalRevoSeats__c = fullcabin.precoFinalRevoSeats;
        item.DescontoValor__c = fullcabin.descontoValor;
        item.DescontoPercentual__c = fullcabin.descontoPerc;        
    }

    private void atualizaPrecoCharter(OpportunityLineItem item) {
        if (!this.calculosCharters.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }        

        PesquisaCharter pesquisa = this.calculosCharters.get(item.Id);
        BlocoCharter charter = pesquisa.horarios[0];

        if (item.Product2Id != pesquisa.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (charter == null) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (charter.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        item.PrecoUnitario__c = charter.precoUnitario;
        item.UnitPrice = charter.precoFinal / item.Quantity;
        item.PrecoRevoSeats__c = charter.precoRevoSeats;
        item.TotalRevoSeats__c = charter.precoFinalRevoSeats;
        item.DescontoValor__c = charter.descontoValor;
        item.DescontoPercentual__c = charter.descontoPerc;            
    }

    private void atualizaPrecoServico(OpportunityLineItem item) {
        List<ServicoDoPacote> servicos = null;
                
        if (this.calculosShuttlerSeats.containsKey(item.Pacote__c)){ 
            PesquisaMalha malha = this.calculosShuttlerSeats.get(item.Pacote__c);
            servicos = malha.servicos;
        }

        if (this.calculosFullCabins.containsKey(item.Pacote__c)){ 
            PesquisaFullCabin pesquisa = this.calculosFullCabins.get(item.Pacote__c);
            BlocoFullCabin fullcabin = pesquisa.horarios[0];

            servicos = fullcabin.servicos;
        }

        if (this.calculosCharters.containsKey(item.Pacote__c)){ 
            PesquisaCharter pesquisa = this.calculosCharters.get(item.Pacote__c);
            BlocoCharter charter = pesquisa.horarios[0];

            servicos = charter.servicos;
        }

        if (servicos == null) {
            throw new ServicoNaoVinculadoPacoteException(true);
        }

        for (ServicoDoPacote servico : servicos) {
            if (servico.produto != item.Product2Id) {
                continue;
            }
        
            item.PrecoUnitario__c = servico.precoUnitario;
            item.UnitPrice = servico.precoFinal / servico.quantidade;
            item.PrecoRevoSeats__c = servico.precoRevoSeats;
            item.TotalRevoSeats__c = servico.precoFinalRevoSeats;
            item.DescontoValor__c = servico.descontoValor;
            item.DescontoPercentual__c = servico.descontoPerc;                               
        }        
    }

    // #endregion

    // #region Validações Itens

    private void validaItemOppShuttlerSeat(OpportunityLineItem item) {

        validaDataEmbarque(item.PrevisaoEmbarque__c);

        validaOrigem(item.Origem__c);

        validaDestino(item.Destino__c);

        validaMalha(item.MalhaVoo__c);

        validaQuantidade(item.Quantity);

        validaValorTotal(item.TotalPrice);

        if (!calculosShuttlerSeats.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }

        Integer quantidade = 0;

        for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
            if (passageiro.PassageiroOportunidade__r == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            if (passageiro.PassageiroOportunidade__r.Passageiro__c == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            quantidade++;
        }

        if (item.Quantity != quantidade) {
            throw new QuantidadePassageirosInvalidoException(true);
        }

        PesquisaMalha malha = calculosShuttlerSeats.get(item.Id);

        if (malha == null) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (malha.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (item.Product2Id != malha.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.MalhaVoo__c != malha.malhaId) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.Quantity > malha.assentosDisponiveis) {
            throw new AssentosIndisponiveisException(true);
        }
        
        if (this.ServicosTaxas.containskey(item.Id)) {
            List<OpportunityLineItem> servicos = this.ServicosTaxas.get(item.Id);
            validaServicosItem(servicos, malha.servicos);        
        }
    }

    private void validaItemOppFullCabin(OpportunityLineItem item) {

        validaDataEmbarque(item.PrevisaoEmbarque__c);

        validaOrigem(item.Origem__c);

        validaDestino(item.Destino__c);

        validaQuantidade(item.Quantity);

        validaValorTotal(item.TotalPrice);

        if (!calculosFullCabins.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }        

        Integer quantidade = 0;

        for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
            if (passageiro.PassageiroOportunidade__r == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            if (passageiro.PassageiroOportunidade__r.Passageiro__c == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            quantidade++;
        }

        PesquisaFullCabin pesquisa = calculosFullCabins.get(item.Id);
        BlocoFullCabin fullcabin = pesquisa.horarios[0];

        if (item.Product2Id != pesquisa.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.Origem__c != pesquisa.origem) {
            throw new MudancaNosDetalhesDoVooException(true);
        }
        
        if (item.Destino__c != pesquisa.destino) {
            throw new MudancaNosDetalhesDoVooException(true);
        }        

        if (item.Quantity > pesquisa.capacidadePassageiros) {
            throw new QuantidadePassageirosInvalidoException(true);
        }        

        if (fullcabin == null) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (fullcabin.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (this.ServicosTaxas.containskey(item.Id)) {
            List<OpportunityLineItem> servicos = this.ServicosTaxas.get(item.Id);
            validaServicosItem(servicos, fullcabin.servicos);        
        }        
    }

    private void validaItemOppCharterFlight(OpportunityLineItem item) {
        validaDataEmbarque(item.PrevisaoEmbarque__c);

        validaQuantidade(item.Quantity);

        validaValorTotal(item.TotalPrice);

        for (LocalOportunidade__c local : item.LocaisProdutoOportunidade__r) {
            if (local.Local__c == null) { 
                throw new LocalInvalidoParaVooCharterException(true);
            }
        }        

        Integer quantidade = 0;

        for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
            if (passageiro.PassageiroOportunidade__r == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            if (passageiro.PassageiroOportunidade__r.Passageiro__c == null) {
                throw new PassageiroNaoVinculadoCorretamenteException(true);
            }

            quantidade++;
        }

        if (!calculosCharters.containsKey(item.Id)) {
            throw new CalculoNaoEncontradoException(true);
        }        

        PesquisaCharter pesquisa = calculosCharters.get(item.Id);
        BlocoCharter charter = pesquisa.horarios[0];

        if (item.Product2Id != pesquisa.produto) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (item.Quantity > pesquisa.capacidadePassageiros) {
            throw new QuantidadePassageirosInvalidoException(true);
        }        

        if (charter == null) {
            throw new MudancaNosDetalhesDoVooException(true);
        }

        if (charter.invalido) {
            throw new SelecaoHorarioVooIndisponivelException(true);
        }

        if (this.ServicosTaxas.containskey(item.Id)) {
            List<OpportunityLineItem> servicos = this.ServicosTaxas.get(item.Id);
            validaServicosItem(servicos, charter.servicos);        
        }
    }

    private void validaItemOppServicosTaxas(OpportunityLineItem item, Boolean validarQuantidadePassageiros) {

        if (item.Pacote__c == null) {
            throw new ServicoNaoVinculadoPacoteException(true);
        }

        if (!this.voosOportunidade.containsKey(item.Pacote__c)) {
            throw new ServicoNaoVinculadoPacoteException(true);
        }

        if (!this.servicosTaxas.containsKey(item.Pacote__c)) {
            throw new ServicoNaoVinculadoPacoteException(true);
        }

        validaQuantidade(item.Quantity);

        if (item.ServicaoPorPassageiro__c) {
            Integer quantidade = 0;

            for (ProdutoPassageiro__c passageiro : item.ProdutosPassageiro__r) {
                if (passageiro.PassageiroOportunidade__r == null) {
                    throw new PassageiroNaoVinculadoCorretamenteException(true);
                }

                if (passageiro.PassageiroOportunidade__r.Passageiro__c == null) {
                    throw new PassageiroNaoVinculadoCorretamenteException(true);
                }

                if (passageiro.Status__c == 'Configurado' || (item.Empacotado__c && passageiro.Status__c == 'Removido')) {
                    quantidade++;
                }
            }

            if ((item.Quantity > quantidade || quantidade > item.Quantity) && validarQuantidadePassageiros) {
                throw new QuantidadeServNaoConfiguradoException(true, item.Description, item.Quantity, quantidade);
            }
        }

        if (!item.Empacotado__c) {
            validaValorTotal(item.TotalPrice);
        }

    }

    private void validaServicosItem(List<OpportunityLineItem> itensCriados, List<ServicoDoPacote> servicos) {
        
        Map<Id, ServicoDoPacote> validos = new Map<Id, ServicoDoPacote>();
        Set<Id> obrigatorios = new Set<Id>();
        Set<Id> existentes = new Set<Id>();

        for (OpportunityLineItem item : itensCriados) {
            existentes.add(item.Product2Id);
        }

        for (ServicoDoPacote servico : servicos) {
            validos.put(servico.produto, servico);

            if (servico.empacotado || servico.obrigatorio) {
                obrigatorios.add(servico.produto);
            }
        }

        if (!existentes.containsAll(obrigatorios)) {
            throw new AlgunsServicosSaoObrigatoriosException(true);
        }

        if (!validos.keyset().containsAll(existentes)) {
            throw new ServicosNaoEstaoDisponiveisException(true);
        }
    }

    // #endregion

    // #region Métodos Privados - Promocao

    private void validaPromocaoOportunidade(Boolean codigoJaUtilizado) {
        if (this.oportunidade.StageName != 'Aguardando Pagamento') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        if (this.oportunidade.OpportunityLineItems.isEmpty()) {
            throw new OportunidadeSemProdutosException(true);
        }

        if (codigoJaUtilizado) {
            throw new CodigoPromocionalJaUtilizadoException(true);
        }        
    }

    private void operacaoMudarPromocaoOportunidade(fflib_ISObjectUnitOfWork uow, CodigoPromocional__c promocao, Boolean codigoJaUtilizado, Servico__c servicoParceiro) {

        Map<Id, OpportunityLineItem> mapOppItem = new Map<Id, OpportunityLineItem>();

        for (Id key : this.voosOportunidade.keyset()) {

            OpportunityLineItem voo = this.voosOportunidade.get(key);        

            atualizaPromocao(uow, voo, false, promocao, voo.PrevisaoEmbarque__c, codigoJaUtilizado);

            mapOppItem.put(voo.Id, voo);

            if (this.ServicosTaxas.get(voo.Id) != null) {
                for (OpportunityLineItem servico : this.ServicosTaxas.get(voo.Id)) {
                    atualizaPromocao(uow, servico, true, promocao, voo.PrevisaoEmbarque__c, codigoJaUtilizado); 
                    mapOppItem.put(servico.Id, servico);
                }
            }
        }

        Map<OpportunityLineItem, List<Servico__c>> mapServicos = new Map<OpportunityLineItem, List<Servico__c>>();

        for (Servico__c servico : this.oportunidade.Servicos__r) {

            if (!mapOppItem.containsKey(servico.ProdutoOportunidade__c)) {
                continue;
            }            

            OpportunityLineItem item = mapOppItem.get(servico.ProdutoOportunidade__c);

            if (!mapServicos.containsKey(item)) {
                mapServicos.put(item, new List<Servico__c>());
            }

            mapServicos.get(item).add(servico);
        }
          

        for (OpportunityLineItem item : mapServicos.keySet()) {

            Integer quantidadeServicos = 0;
            ItemPromocao__c itemPromocao = CodigoPromocional.encontraItemPromocaoUtilizado(promocao, item.Product2Id, item.Quantity); 

            for (Servico__c servico : mapServicos.get(item)) {
                System.debug('servico: ' + servico.Id);

                quantidadeServicos++;

                if (mapServicos.get(item).size() == 1 || itemPromocao == null) {
                    servico.ValorTotal__c = (item.UnitPrice * item.Quantity) / mapServicos.get(item).size();
                } else {

                    if (itemPromocao.QuantidadeMaxima__c >= quantidadeServicos) {
                        if (itemPromocao.DescontoUnitario__c > 0) {
                            servico.ValorTotal__c = item.PrecoUnitario__c - itemPromocao.DescontoUnitario__c;
                        } else {
                            servico.ValorTotal__c = item.PrecoUnitario__c * (1 - itemPromocao.PercDesconto__c / 100);
                        }
                    } else {
                        servico.ValorTotal__c = item.PrecoUnitario__c * (1 - (promocao.Desconto__c <= 0 ? 0 : promocao.Desconto__c) / 100);
                    }
                }

                if (servicoParceiro != null) {
                    servico.ServicoPromocao__c = servicoParceiro.Id;
                }   

                uow.registerDirty(servico);
            }
        }

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioReservarVoo__c;

        this.oportunidade.LimitePagamento__c = System.now();
        this.oportunidade.LimitePagamento__c = this.oportunidade.LimitePagamento__c.addMinutes(Integer.valueOf(tempoParaResetar));        

        this.oportunidade.CodigoPromocional__c = promocao.Id;
        this.oportunidade.Sistema__c = true;

        Opportunities.criaPromocaoOportunidade(uow, oportunidade, promocao.Id);        

        uow.registerDirty(this.oportunidade);

    }   

    // #endregion

    // #region Micro Validações

    private void validaExistenciaCalculo(Id lineId) {
        if (!voosOportunidade.containsKey(lineId)) {
            throw new VooNaoEncontradoParaCalculoException(true);
        }
    }

    private void validaMalha(Id malhaId){ 
        if (malhaId == null) {
            throw new MalhaOportunidadeInvalidaException(true);
        }
    }

    private void validaOrigem(Id localId){ 
        if (localId == null) {
            throw new LocalOrigemInvalidoException(true);
        }
    }

    private void validaDestino(Id localId){ 
        if (localId == null) {
            throw new LocalDestinoInvalidoException(true);
        }
    }

    private void validaDataEmbarque(DateTime data){ 
        if (data == null || data <= DateTime.now()) {
            throw new DataPrevisaoEmbarqueException(true);
        }
    }

    private void validaQuantidade(Decimal quantidade){ 
        if (quantidade <= 0.00) {
            throw new QuantidadeInvalidoException(true);
        }
    }

    private void validaValorTotal(Decimal valorTotal){ 
        if (valorTotal < 0.00) {
            throw new ValorOportunidadeInvalidaException(true);
        }
    }    

    private Map<Id, String> productRecordTypesIds() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Map<Id, String> result = new Map<Id, String>();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            result.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
        }

        return result;
    }    

    private Set<String> enumTiposDeProdutosToSet() {
        Set<String> result = new Set<String>();

        for (TiposDeProdutos tipo : TiposDeProdutos.values()) {
            result.add(tipo.name());
        }

        return result;
    }

    private Id codigoPromocionalParceiroRecordTypeId() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('CodigoPromocional__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'PromocaoParceiro') {
                return rtInfo.getRecordTypeId();
            }
        }        

        return null;
    }

    // #endregion

    // #region Catálogo de Erros

    public virtual class OpportunityException extends Exception {
        public String codigo;
    
        public OpportunityException(String codigo, String mensagem) {
            this(codigo + ': ' + mensagem);
            this.codigo = codigo;
        }
    }    

    public class OportunidadeNaoEncontradaException extends OpportunityException {
        public OportunidadeNaoEncontradaException(Boolean voidParam) {
            super('CKV-0001','Oportunidade não encontrada!');
        }
    }

    public class OportunidadeFaseInvalidaException extends OpportunityException {
        public OportunidadeFaseInvalidaException(Boolean voidParam) {
            super('CKV-0002','Fase da Oportunidade Inválida!');
        }
    }

    public class OportunidadeSemProdutosException extends OpportunityException {
        public OportunidadeSemProdutosException(Boolean voidParam) {
            super('CKV-0003','Oportunidade sem Produtos!');
        }
    }

    public class ProdutoInvalidoNaOportunidadeException extends OpportunityException {
        public ProdutoInvalidoNaOportunidadeException(Boolean voidParam) {
            super('CKV-0004','Produto Inválido na Oportunidade!');
        }
    }    

    public class DataPrevisaoEmbarqueException extends OpportunityException {
        public DataPrevisaoEmbarqueException(Boolean voidParam) {
            super('CKV-0005','Data de Previsão de Embarque inválido!');
        }
    }    

    public class LocalOrigemInvalidoException extends OpportunityException {
        public LocalOrigemInvalidoException(Boolean voidParam) {
            super('CKV-0006','Local de Origem inválido!');
        }
    }    

    public class LocalDestinoInvalidoException extends OpportunityException {
        public LocalDestinoInvalidoException(Boolean voidParam) {
            super('CKV-0007','Local de Destino inválido!');
        }
    }    

    public class QuantidadeInvalidoException extends OpportunityException {
        public QuantidadeInvalidoException(Boolean voidParam) {
            super('CKV-0008','Quantidade inválida!');
        }
    }    

    public class ValorOportunidadeInvalidaException extends OpportunityException {
        public ValorOportunidadeInvalidaException(Boolean voidParam) {
            super('CKV-0009','Valor Total da Oportunidade inválida!');
        }
    }    

    public class MalhaOportunidadeInvalidaException extends OpportunityException {
        public MalhaOportunidadeInvalidaException(Boolean voidParam) {
            super('CKV-0010','Malha da Oportunidade inválida!');
        }
    }    

    public class SelecaoHorarioVooIndisponivelException extends OpportunityException {
        public SelecaoHorarioVooIndisponivelException(Boolean voidParam) {
            super('CKV-0011','Horário do Voo indisponível!');
        }
    }    

    public class MudancaNosDetalhesDoVooException extends OpportunityException {
        public MudancaNosDetalhesDoVooException(Boolean voidParam) {
            super('CKV-0012','Houve uma mudança nas configurações do Voo refaça a Seleção da Malha!');
        }
    }    

    public class MudancaNoPrecoException extends OpportunityException {
        public MudancaNoPrecoException(Boolean voidParam) {
            super('CKV-0013','Houve uma mudança no preço do Voo confirme a Seleção e configuração dos serviços!');
        }
    }    

    public class AssentosIndisponiveisException extends OpportunityException {
        public AssentosIndisponiveisException(Boolean voidParam) {
            super('CKV-0014','Não há assentos disponíveis para esta Seleção de Voo!');
        }
    }    

    public class AlgunsServicosSaoObrigatoriosException extends OpportunityException {
        public AlgunsServicosSaoObrigatoriosException(Boolean voidParam) {
            super('CKV-0016','Serviços obrigatórios não encontrados no fechamento, reconfigure o produto para continuar!');
        }
    }    

    public class ServicosNaoEstaoDisponiveisException extends OpportunityException {
        public ServicosNaoEstaoDisponiveisException(Boolean voidParam) {
            super('CKV-0017','Alguns Serviços não estão disponiveis para o fechamento, reconfigure o produto para continuar!');
        }
    }    

    public class TipoOportunidadeInvalidaException extends OpportunityException {
        public TipoOportunidadeInvalidaException(Boolean voidParam) {
            super('CKV-0018','Tipo da Oportunidade Inválida!');
        }
    }    

    public class CalculoOportunidadeExpiradoException extends OpportunityException {
        public CalculoOportunidadeExpiradoException(Boolean voidParam) {
            super('CKV-0019','Calculo da Oportunidade está expirado, calcule novamente!');
        }
    }    

    public class CalculoNaoEncontradoException extends OpportunityException {
        public CalculoNaoEncontradoException(Boolean voidParam) {
            super('CKV-0020','Calculo do Voo não foi processado!');
        }
    }        

    public class ServicoNaoVinculadoPacoteException extends OpportunityException {
        public ServicoNaoVinculadoPacoteException(Boolean voidParam) {
            super('CKV-0021','Serviço não vinculado a nenhum pacote!');
        }
    }

    public class VooNaoEncontradoParaCalculoException extends OpportunityException {
        public VooNaoEncontradoParaCalculoException(Boolean voidParam) {
            super('CKV-0022','Cálculo não vinculado a nenhum item!');
        }
    }        

    public class PassageiroNaoVinculadoCorretamenteException extends OpportunityException {
        public PassageiroNaoVinculadoCorretamenteException(Boolean voidParam) {
            super('CKV-0023','Passageiro não vinculado corretamente ao Voo!');
        }
    }  

    public class QuantidadePassageirosInvalidoException extends OpportunityException {
        public QuantidadePassageirosInvalidoException(Boolean voidParam) {
            super('CKV-0024','Quantidade passageiros diferente da quantidade de assentos!');
        }
    }       

    public class ContaOportunidadeNaoInformadaException extends OpportunityException {
        public ContaOportunidadeNaoInformadaException(Boolean voidParam) {
            super('CKV-0025','Conta da Oportunidade não informada!');
        }
    }       
    
    public class ContaDeFaturamentoNaoInformadaException extends OpportunityException {
        public ContaDeFaturamentoNaoInformadaException(Boolean voidParam) {
            super('CKV-0026','Conta da Faturamento não informada!');
        }
    }           

    public class LocalInvalidoParaVooCharterException extends OpportunityException {
        public LocalInvalidoParaVooCharterException(Boolean voidParam) {
            super('CKV-0027','Local Inválido para Voo Charter!');
        }
    }           

    public class QuantidadeServNaoConfiguradoException extends OpportunityException {
        public QuantidadeServNaoConfiguradoException(Boolean voidParam, string nomeServico,
                                                                         decimal quantidadeServico, 
                                                                         integer quantidadeConfigurada) {
            super('CKV-0028',String.format('Quantidade inválida para o serviço: {0} - Quantidade: {1}, Quantidade Configurada: {2}', new List<Object>{nomeServico, quantidadeServico.intValue(), quantidadeConfigurada}));
        }
    }           

    public class CodigoPromocionalJaUtilizadoException extends OpportunityException {
        public CodigoPromocionalJaUtilizadoException(Boolean voidParam) {
            super('CKV-0029','Código Promocional já utilizado!');
        }
    }      
    
    public class PromocaoModeloNaoEncontradaException extends OpportunityException {
        public PromocaoModeloNaoEncontradaException(Boolean voidParam) {
            super('CKV-0030','Promocao Modelo não encontrada!');
        }
    }           

    // #endregion
}