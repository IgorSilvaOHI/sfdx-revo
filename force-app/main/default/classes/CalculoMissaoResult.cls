public class CalculoMissaoResult {
    public Aeronave__c aeronave {get; set;}
    public Local__c baseOrigem {get; set;}
    public List<Local__c> trajeto {get; set;}
    
    public Date dataMissao {get; set;}
    public DateTime hrMaximoDecolagem {get; set;}
    
    public Decimal tempoMissao {get; set;} // → Tempo que será reservado na agenda (TransladoIda + TransladoRetorno + TempoCruzeiro + TempoSolo)
    public Decimal pesoMaximo {get; set;}
    public Decimal tempoTransladoIda {get; set;}
    public Decimal tempoTransladoRetorno {get; set;}
    public Decimal tempoCruzeiro {get; set;}
    public Decimal tempoSolo {get; set;}
    public Boolean viabilidade {get; set;}
    public Boolean calculaTranslado {get; set;}
    
    private List<FlightNode> malhaAerea {get; set;}
    
    public List<FlightLeg> trechos = new List<FlightLeg>();
    
    private enum TipoOperacaoAerodromo {ATERRISAGEM, DECOLAGEM}
    
    private Decimal acumulaTempoSolo = 0;
    private Decimal acumulaTempoCruzeiro = 0;
    private List<FlightLeg> acumulaFlightLeg = new List<FlightLeg>();
    
    public CalculoMissaoResult() {
        this.tempoMissao = 0;
        this.pesoMaximo = 0;
        this.tempoTransladoIda = 0;
        this.tempoTransladoRetorno = 0;
        this.tempoCruzeiro = 0;
        this.tempoSolo = 0;
        this.calculaTranslado = true;
    }
    
    public void ExecutarCalculoMissao(Aeronave__c aeronave, List<Local__c> trajeto, Date dataMissao) {
        this.aeronave = CalculoMissaoSingleton.getInstance().aeronaves.get(aeronave.Id);
        this.baseOrigem = CalculoMissaoSingleton.getInstance().locais.get(this.aeronave.BaseMae__c); 
        this.trajeto = new List<Local__c>();
        this.dataMissao = dataMissao;
        
        for (Local__c loc : trajeto) {
            Local__c localSalvo = CalculoMissaoSingleton.getInstance().locais.get(loc.Id);
            
            if (localSalvo == null) {
                CalculoMissaoSingleton.getInstance().locais.put(loc.Id, loc);
                CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.put(loc.Id, loc.clone());
                this.trajeto.add(loc);
                continue;
            }
            
            if (loc.Coordenadas__Latitude__s == null || loc.Coordenadas__Longitude__s == null) {
                this.trajeto.add(localSalvo);
                continue;
            }
            
            if (localSalvo.Coordenadas__Latitude__s != loc.Coordenadas__Latitude__s ||
                localSalvo.Coordenadas__Longitude__s != loc.Coordenadas__Longitude__s) {
                localSalvo.Coordenadas__Latitude__s = loc.Coordenadas__Latitude__s;
                localSalvo.Coordenadas__Longitude__s = loc.Coordenadas__Longitude__s;
                CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.put(loc.Id, localSalvo.clone());
            }
            this.trajeto.add(localSalvo);
        }
        
        // Otimização: Carregar malha aérea filtrada apenas para locais relevantes
        this.carregarMalhaAerea();
        
        this.calcularMissao();
    }
    
    private void CalcularTransladosIda() {
        if (this.baseOrigem == this.trajeto[0]) return;
        FlightLeg trechoTransladoIda = this.IncluirTrecho(this.baseOrigem, this.trajeto[0]);
        tempoTransladoIda += CalcularTemposMissao(this.baseOrigem, this.trajeto[0], trechoTransladoIda);
    }
    
    private void CalcularTransladosRetorno() {
        if (this.baseOrigem == this.trajeto[this.trajeto.size()-1]) return;
        FlightLeg trechoTransladoRetorno = this.IncluirTrecho(this.trajeto[this.trajeto.size()-1], this.baseOrigem);
        this.tempoTransladoRetorno += CalcularTemposMissao(this.trajeto[this.trajeto.size()-1], this.baseOrigem, trechoTransladoRetorno);
    }
    
    private void calcularMissao() {
        this.viabilidade = true;
        this.trechos = new List<FlightLeg>();
        
        if (calculaTranslado) {
            this.CalcularTransladosIda();
        }
        
        for (Integer i = 0; i < this.trajeto.size() - 1; i++) {
            FlightLeg novoTrecho = this.IncluirTrecho(this.trajeto[i], this.trajeto[i+1]);
            CalcularTemposMissao(this.trajeto[i], this.trajeto[i+1], novoTrecho);
        }
        
        if (calculaTranslado) {
            this.CalcularTransladosRetorno();
        }
        
        this.pesoMaximo = aeronave.PesoMaximoDecolagem__c;
        
        // Otimização: Calcular viabilidade e peso em um único loop final
        for (FlightLeg trecho : this.trechos) {
            if (!trecho.viabilidade) this.viabilidade = false;
            if (this.pesoMaximo > trecho.disponibilidadePeso) this.pesoMaximo = trecho.disponibilidadePeso;
        }

        this.tempoMissao = this.tempoMissao.setScale(4, RoundingMode.HALF_UP);
        this.tempoTransladoIda = this.tempoTransladoIda.setScale(4, RoundingMode.HALF_UP);
        this.tempoTransladoRetorno = this.tempoTransladoRetorno.setScale(4, RoundingMode.HALF_UP);
        this.tempoCruzeiro = this.tempoCruzeiro.setScale(4, RoundingMode.HALF_UP);
        this.tempoSolo = this.tempoSolo.setScale(4, RoundingMode.HALF_UP);
    }
    
    private FlightLeg IncluirTrecho(Local__c origem, Local__c destino) {
        Location locOrigem = CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.containsKey(origem.Id) ?
            Location.newInstance(origem.Coordenadas__Latitude__s, origem.Coordenadas__Longitude__s) : origem.Coordenadas__c;
        
        Location locDestino = CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.containsKey(destino.Id) ?
            Location.newInstance(destino.Coordenadas__Latitude__s, destino.Coordenadas__Longitude__s) : destino.Coordenadas__c;
        
        FlightLeg novoTrecho = new FlightLeg(aeronave.Name, origem.CodigoLocal__c, locOrigem, destino.CodigoLocal__c, locDestino, 
                                             this.fuelDiponibility(origem), this.fuelDiponibility(destino));
        
        this.trechos.add(novoTrecho);
        return novoTrecho;
    }
    
    private Boolean fuelDiponibility(Local__c loc) {
        return loc.Tipo__c == 'Onshore';
    }
    
    private Decimal CalcularTemposMissao(Local__c origem, Local__c destino, FlightLeg trecho) {
        Integer inicio = System.Limits.getCpuTime();
        
        Decimal tempoSoloDecolagem = this.CalcularTempoSolo(TipoOperacaoAerodromo.DECOLAGEM);
        Decimal tempoAceleracao = 0; // Assumindo 0, como no original
        Decimal tempoCruzeiro = this.CalcularDistanciaTrecho(trecho) / aeronave.VelocidadeCruzeiro__c * 60;
        Decimal tempoDesaceleracao = 0; // Assumindo 0
        Decimal tempoSoloAterrissagem = this.CalcularTempoSolo(TipoOperacaoAerodromo.ATERRISAGEM);
        
        trecho.tempoDecorrido = this.tempoMissao;
        trecho.tempoSolo = tempoSoloDecolagem + tempoSoloAterrissagem;
        trecho.tempoCruzeiro = tempoCruzeiro + tempoAceleracao + tempoDesaceleracao;
        trecho.tempoMissao = trecho.tempoSolo + trecho.tempoCruzeiro; // Adicionado para clareza
        
        this.tempoSolo += trecho.tempoSolo;
        this.tempoCruzeiro += trecho.tempoCruzeiro;
        this.tempoMissao += trecho.tempoMissao;
        
        Decimal tempoVooSeg = 30; // Minutos extras para combustível
        
        Decimal combustivelTotal;
        Decimal pesoDisponivel;
        
        if (trecho.fuelDiponibilityOnOrigin && trecho.fuelDiponibilityOnDestination) {
            combustivelTotal = aeronave.ConsumoHoraSolo__c * (trecho.tempoSolo / 60) + 
                               aeronave.ConsumoHoraVoo__c * (trecho.tempoCruzeiro / 60 + tempoVooSeg / 60);
            pesoDisponivel = aeronave.PesoMaximoDecolagem__c - aeronave.PesoBasicoOperacional__c - combustivelTotal;
            
            trecho.viabilidade = combustivelTotal < aeronave.CapacidadeTotalCombustivel__c && pesoDisponivel > 0;
            trecho.disponibilidadePeso = pesoDisponivel;
        } else {
            this.acumulaTempoSolo += trecho.tempoSolo;
            this.acumulaTempoCruzeiro += trecho.tempoCruzeiro;
            this.acumulaFlightLeg.add(trecho);
            
            if (trecho.fuelDiponibilityOnDestination) {
                combustivelTotal = aeronave.ConsumoHoraSolo__c * (this.acumulaTempoSolo / 60) + 
                                   aeronave.ConsumoHoraVoo__c * (this.acumulaTempoCruzeiro / 60 + tempoVooSeg / 60);
                pesoDisponivel = aeronave.PesoMaximoDecolagem__c - aeronave.PesoBasicoOperacional__c - combustivelTotal;
                
                Decimal combustivelRestante = combustivelTotal;
                for (FlightLeg fl : this.acumulaFlightLeg) {
                    fl.disponibilidadePeso = aeronave.PesoMaximoDecolagem__c - aeronave.PesoBasicoOperacional__c - combustivelRestante;
                    fl.viabilidade = combustivelRestante < aeronave.CapacidadeTotalCombustivel__c && fl.disponibilidadePeso > 0;
                    combustivelRestante -= aeronave.ConsumoHoraSolo__c * (fl.tempoSolo / 60) + 
                                           aeronave.ConsumoHoraVoo__c * (fl.tempoCruzeiro / 60);
                }
                
                // Reset acúmulos após processamento
                this.acumulaTempoSolo = 0;
                this.acumulaTempoCruzeiro = 0;
                this.acumulaFlightLeg.clear();
            }
        }
        
        if (destino.Tipo__c == 'Offshore' && this.dataMissao >= Date.today()) {
            DateTime porSol = DateTime.newInstanceGmt(this.dataMissao, 
                CalculoMissaoSingleton.getInstance().horariosSol.get(this.dataMissao).get(destino.CodigoICAO__c).sunset__c);
            this.hrMaximoDecolagem = porSol.addMinutes(Integer.valueOf((this.tempoMissao * -1 + this.tempoTransladoIda).round()));
        }
        
        Integer fim = System.Limits.getCpuTime();
        return trecho.tempoMissao;
    }
    
    private Decimal CalcularDistanciaTrecho(FlightLeg trecho) {
        String chave = trecho.codOrigem + trecho.codDestino;
        Decimal distancia = 0;
        
        if (CalculoMissaoSingleton.getInstance().calculatedRoute.containsKey(chave)) {
            trecho.distance = CalculoMissaoSingleton.getInstance().calculatedRoute.get(chave).distance;
            trecho.route = CalculoMissaoSingleton.getInstance().calculatedRoute.get(chave).route;
        } else {
            trecho.CalculateRoute(this.malhaAerea);
            // Otimização: Somar distâncias durante a busca, se possível; caso contrário, manter loop
            for (Integer i = 0; i < trecho.route.size() - 1; i++) {
                distancia += trecho.route[i].geolocation.getDistance(trecho.route[i+1].geolocation, 'mi') * 0.868976;
            }
            trecho.distance = distancia;
            CalculoMissaoSingleton.getInstance().calculatedRoute.put(chave, trecho.clone()); // Clone se necessário para evitar referência
        }
        return trecho.distance;
    }
    
    private Decimal CalcularTempoSolo(TipoOperacaoAerodromo tipoOp) {
        if (tipoOp == TipoOperacaoAerodromo.ATERRISAGEM) {
            return aeronave.TempoSoloAterrissagem__c == null ? 0 : aeronave.TempoSoloAterrissagem__c / 60;
        } else {
            return aeronave.TempoSoloDecolagem__c == null ? 0 : aeronave.TempoSoloDecolagem__c / 60;
        }
    }
    
    private void carregarMalhaAerea()
    {
        integer inicio = system.Limits.getCpuTime();
        Map<id, FlightNode> mapLocationNode = new Map<id, FlightNode>();
        
        List<FlightNode> mAerea = new List<FlightNode>();
         
        List<Local__c> locais = CalculoMissaoSingleton.getInstance().locais.values();
        
        for (Local__c local : locais)
        {
            System.Location geolocation;
            //TODO: Renato, Vitória: como o put lá em cima não funciona, nunca entra nesse if
            if(CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.containsKey(local.id))
            {
                
                Decimal lat =  CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.get(local.id).Coordenadas__Latitude__s;
                Decimal longi = CalculoMissaoSingleton.getInstance().locaisCoordenadasAlteradas.get(local.id).Coordenadas__Longitude__s;
                geolocation = System.Location.newInstance(lat, longi);
                
            }
            else geolocation = local.Coordenadas__c; 
            boolean needInterceptionNode = local.Coordenadas__Latitude__s<=-21.1666 && local.Coordenadas__Latitude__s>=-23.666 && local.Coordenadas__Longitude__s>=-41.9 && local.RecordType.Name == 'Padrão' && local.Tipo__c == 'Offshore'; 
            FlightNode.ShoreTypeEnum shoreType = local.Tipo__c == 'Onshore'?FlightNode.ShoreTypeEnum.Onshore : FlightNode.ShoreTypeEnum.OffShore;
            FlightNode node = new FlightNode(local.CodigoLocal__c, local.RecordType.Name, geolocation, needInterceptionNode, shoreType);
            node.name = local.CodigoLocal__c; node.nodeType = local.RecordType.Name;
            mapLocationNode.put(local.id, node);
            mAerea.add(node);
        }
        
        for (Aerovia__c  arv: CalculoMissaoSingleton.getInstance().aerovias.values())
        {
            mapLocationNode.get(arv.Origem__c).addNeighbor(mapLocationNode.get(arv.Destino__c));
        }
        this.malhaAerea = mAerea;
        integer fim = system.Limits.getCpuTime();
        System.debug('METHODTIME - carregarMalhaAerea: '+ (fim-inicio));
        
    }
}