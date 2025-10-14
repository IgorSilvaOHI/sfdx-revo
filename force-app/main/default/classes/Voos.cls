public without sharing class Voos extends fflib_SObjectDomain implements IVoos {
    public Map<Voo__c, List<Trecho__c>> mapVoos;
    //DeveloperName de Metadados para Integração
    public static final String RASCUNHO = 'Rascunho';
    public static final String RESERVADO = 'Reservado';
    public static final String CONFIRMADO = 'Confirmado';
    public static final String ROTA = 'Rota';
    public static final String CANCELADO = 'Cancelado';
    public static final String EXECUTADO = 'Executado';
    public static final String FATURAMENTO = 'Em Faturamento';
    public static final String PRERESERVADO = 'Pré-reservado';
    public static final String LOGPENDENTE = 'LogPendente';
    public static final String FATURADO = 'Faturado';
    public static final String GUIANA = 'Guiana';
    public static final String TREINAMENTO = 'Treinamento';

    public static Boolean isSystemFullAcess() {
        try {
            Account v = [SELECT Id FROM Account Where Id = '0018900000YmCGLAA3' LIMIT 1];
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static final Set<Schema.SObjectField> FIELDS_IGNORE = new Set<Schema.SObjectField>{
        Voo__c.StatusRascunho__c,
        Voo__c.ChaveRota__c,
        Voo__c.Resumo__c,
        Voo__c.TempoCorte__c,
        Voo__c.TempoCortadoTexto__c,
        Voo__c.OrdemExecucaoUltimoTrecho__c,
        Voo__c.PrimeiroTrecho__c,
        Voo__c.QtdTrechosOrigemOffshore__c,
        Voo__c.QtdTrechos__c,
        Voo__c.TrechosNaoIniciados__c,
        Voo__c.UltimoTrecho__c,
        Voo__c.LastModifiedDate,
        Voo__c.SystemModstamp,
        Voo__c.HorarioVooReservado__c,
        Voo__c.HorarioVooReservado2__c,
        Voo__c.HorarioVooReservado3__c,
        Voo__c.IdContaPai__c
    };

    public Boolean ignorarTriggerUpdate() {
        SObjectType vooType = Schema.getGlobalDescribe().get('Voo__c');
        Map<String, Schema.SObjectField> mfields = vooType.getDescribe()
            .fields.getMap();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Voo__c novoVoo = (Voo__c) Trigger.new[i];
            Voo__c oldVoo = (Voo__c) Trigger.old[i];
            for (String key : mfields.keyset()) {
                Schema.SObjectField field = mfields.get(key);
                if (
                    novoVoo.get(field) != oldVoo.get(Field) &&
                    !FIELDS_IGNORE.contains(field)
                ) {
                    return false;
                }
            }
        }
        return true;
    }

    public Voos(List<Voo__c> sObjectList) {
        super(sObjectList);
	
        System.debug('isSystemFullAcess Voos.class: ' + Voos.isSystemFullAcess());

        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Voos(sObjectList);
        }
    }

    public static Voo__c criarVooRascunho(
        fflib_ISObjectUnitOfWork uow, Datetime previsaoVoo, Id prefixo, Id cliente,
        String tipoVoo, List<Local__c> rota, Boolean calculaTranslado, Boolean checkout
    ) {

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();

        Decimal tempoParaResetar = checkout ? configuracaoTempo.MinutosBloqueioReservarVoo__c : configuracaoTempo.MinutosBloqueioSelecaoVoo__c;
        tempoParaResetar += 60;

        Datetime dataReset = System.now();
        dataReset = dataReset.addMinutes(Integer.valueOf(tempoParaResetar));

        Voo__c novoVoo = new Voo__c();
        novoVoo.Status__c = 'Rascunho';
        novoVoo.Cliente__c = cliente;
        novoVoo.DataRemocaoPreReserva__c = dataReset;
        novoVoo.DataVoo__c = previsaoVoo;
        novoVoo.Prefixo__c = prefixo;
        novoVoo.Tipo__c = tipoVoo;
        novoVoo.NaoCalculaTranslado__c = !calculaTranslado;
        novoVoo.StatusRascunho__c = System.now();
        novoVoo.ChaveRota__c = '';
        novoVoo.RotaCompleta__c = '';
        novoVoo.Rota__c = '';
        novoVoo.RotaAbreviada__c = '';

        SetRotaAbreviada(novoVoo, rota);

        uow.registerNew(novoVoo);        

        return novoVoo;
    }

    private static void SetRotaAbreviada(Voo__c voo, List<Local__c> rota) {
        voo.RotaAbreviada__c = '';
        voo.RotaCompleta__c = '';
        voo.Rota__c = '';
        voo.ChaveRota__c = '';
    
        for (Integer i = 0; i < rota.size(); i++) {
            Local__c local = rota[i];
    
            voo.ChaveRota__c += local.CodigoLocal__c;
            voo.RotaAbreviada__c += local.CodigoLocal__c;
            voo.RotaCompleta__c += local.Name;
            voo.Rota__c += local.Name;
    
            // Adiciona o separador " > " apenas se não for o último elemento
            if (i < rota.size() - 1) {
                voo.RotaAbreviada__c += ' > ';
                voo.RotaCompleta__c += ' > ';
                voo.Rota__c += ' > ';
            }
        }
    }
    
    public static Trecho__c criarTrecho(
        fflib_ISObjectUnitOfWork uow, Id origem, Id destino, Voo__c voo,
        Integer ordemExecucao, String tipo
    ) {
        Trecho__c trecho = new Trecho__c(
            Origem__c = origem,
            Destino__c = destino,
            OrdemExecucao__c = ordemExecucao
        );
        if (!String.isBlank(tipo)) {
            trecho.Tipo__c = tipo;
        }
        if (voo.retroativo__c) {
            trecho.ligado__c = voo.dataVoo__c;
        }
        uow.registerNew(trecho, Trecho__c.Voo__c, voo);
        return trecho;
    }

    public static Trecho__c criarTrecho(
        fflib_ISObjectUnitOfWork uow, Id origem, Id destino, Voo__c voo,
        Integer ordemExecucao, String tipo, Id produtoShuttle, Id malha, String horarioMalha
    ) {
        Trecho__c trecho = criarTrecho(uow, origem, destino, voo, ordemExecucao, tipo);

        trecho.ProdutoShuttleSeat__c = produtoShuttle;
        trecho.MalhaVoo__c = malha;
        trecho.HorarioMalha__c = horarioMalha;

        return trecho;
    }    


    public static Passageiro__c criarPassageiro(
        fflib_ISObjectUnitOfWork uow, Trecho__c trecho, Id contatoPassageiro, String codigoReserva
    ) {
        Passageiro__c passageiro = new Passageiro__c(Contato__c = contatoPassageiro, CodigoReserva__c = codigoReserva);
        uow.registerNew(passageiro, Passageiro__c.Trecho__c, trecho);
        return passageiro;
    }    

    public Map<Id, Account> retrieveAccountMapFromVooList(
        List<Voo__c> records
    ) {
        Set<Id> accSetId = new Set<Id>();
        for (Voo__c voo : records) {
            if (voo.Cliente__c != null) accSetId.add(voo.Cliente__c);
        }
        
        if(accSetId.size()>0){
            return new Map<Id, Account>(AccountsSelector.newInstance().selectById(accSetId));           
        }
        return null;
    }

    public Set<Id> retrieveAeronaveSetIdFromRecords(List<Voo__c> records) {
        Set<Id> aeronaveSetId = new Set<Id>();
        for (Voo__c voo : records)
            aeronaveSetId.add(voo.Prefixo__c);
        return aeronaveSetId;
    }

    public Map<String, Aeronave__c> retrieveNameAeronaveMapFromAeronaveList(
        List<Aeronave__c> aeronaveList
    ) {
        Map<String, Aeronave__c> nameAeronaveMap = new Map<String, Aeronave__c>();
        for (Aeronave__c aeronave : aeronaveList)
            nameAeronaveMap.put(aeronave.Name, aeronave);
        return nameAeronaveMap;
    }

    public Datetime retrieveSmallerDateFromRecords() {
        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosByMaxAndMinTime();
        Integer tempoPlanejamentoPre = entreVoos.entreVoosPre;
        Datetime smallerDate = null;
        for (Voo__c voo : (List<Voo__c>) records) {
            if (smallerDate == null && voo.DataVoo__c != null)
                smallerDate = voo.DataVoo__c.addMinutes(-tempoPlanejamentoPre);
            else if (voo.DataVoo__c != null && voo.DataVoo__c < smallerDate)
                smallerDate = voo.DataVoo__c.addMinutes(-tempoPlanejamentoPre);
        }
        return smallerDate;
    }

    public Datetime retrieveBiggerDateFromRecords() {
        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosByMaxAndMinTime();
        Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;
        Datetime biggerDate = null;
        for (Voo__c voo : (List<Voo__c>) records) {
            if (biggerDate == null && voo.DataVoo__c != null)
                biggerDate = voo.DataVoo__c.addMinutes(tempoPlanejamentoPos);
            else if (voo.DataVoo__c != null && voo.DataVoo__c > biggerDate)
                biggerDate = voo.DataVoo__c.addMinutes(tempoPlanejamentoPos);
        }
        return biggerDate;
    }

    public Map<Id, Calendar> retrieveCalendarMapByRecords(Set<String> aeronaveSetName, Map<Id, Aeronave__c> aeronaveMap) {
        if (aeronaveSetName == null || aeronaveSetName.size() == 0) {
            return new Map<Id, Calendar>();    
        }
        
        Map<Id, Calendar> calendarMap = 
            new Map<Id, Calendar>(CalendarsSelector.newInstance().selectCalendarsByPrefixsSetName(aeronaveSetName));
        return calendarMap;
    }

    public Calendar retrieveCalendarByVooAndCalendarMap(
        Voo__c voo,
        Map<Id, Aeronave__c> aeronaveMap,
        Map<Id, Calendar> calendarMap
    ) {
        Calendar calendar = null;
        for (Calendar c : calendarMap.values()) {
            if (
                checkIfVooHasPrefixo(voo) &&
                aeronaveMap.get(voo.Prefixo__c) != null &&
                c.Name.equals(aeronaveMap.get(voo.Prefixo__c).Name)
            ) {
                calendar = c;
            }
        }
        return calendar;
    }

    public Boolean verifyExistingEventForVoo(
        Voo__c voo,
        List<Event> eventList
    ) {
        Boolean exist = false;
        for (Event event : eventList) {
            if (voo.Id.equals(event.WhatId))
                exist = true;
        }
        return exist;
    }

    public Boolean checkIfVooStatusIsPreReservado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) &&
            voo.Status__c.equals(PRERESERVADO);
    }

    public Boolean checkIfVooStatusIsReservado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) &&
            voo.Status__c.equals(RESERVADO);
    }

    public Boolean checkIfVooStatusIsConfirmado(Voo__c voo) {
        return String.isNotBlank(voo.Status__c) &&
            voo.Status__c.equals(CONFIRMADO);
    }

    public boolean checkIfVooCanCreateUpdateEvent(Voo__c voo) {
        Boolean valid = false;
        if (
            checkIfVooHasStatusToCreateUpdateEvent(voo) &&
            checkIfVooHasPrefixo(voo) &&
            checkValidDateOfVoo(voo)
        )
            valid = true;
        return valid;
    }

    public Boolean checkIfVooHasPrefixo(Voo__c voo) {
        Boolean valid = false;
        if (String.isNotBlank(voo.Prefixo__c))
            valid = true;
        else if (checkIfVooHasStatusToCreateUpdateEvent(voo))
            voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
        return valid;
    }

    public Boolean checkIfVooHasStatusReservadoConfirmado(Voo__c voo) {
        Boolean valid = false;
        if (
            checkIfVooStatusIsReservado(voo) ||
            checkIfVooStatusIsConfirmado(voo)
        )
            valid = true;
        return valid;
    }

    public Boolean checkIfVooHasStatusToCreateUpdateEvent(Voo__c voo) {
        Boolean valid = false;
        if (
            checkIfVooStatusIsPreReservado(voo) ||
            checkIfVooHasStatusReservadoConfirmado(voo)
        )
            valid = true;
        return valid;
    }

    public Boolean checkValidDateOfVoo(Voo__c voo) {
        Boolean valid = false;
        if (voo.DataVoo__c != null)
            valid = true;
        else if (checkIfVooHasStatusToCreateUpdateEvent(voo))
            voo.DataVoo__c.addError(Label.ErroDataVazio);
        return valid;
    }

    public Boolean checkVooDataToValidPlanning(Voo__c voo, Voo__c vooOld) {
        Boolean valid = true;
        if (
            (voo.Prefixo__c == vooOld.Prefixo__c &&
            voo.DataVoo__c == vooOld.DataVoo__c &&
            voo.TempoCorteCliente__c == vooOld.TempoCorteCliente__c &&
            // Se o Status mudar de Rascunho para Pré-Reservado, deve criar Eventos
            !((vooOld.Status__c.equals(RASCUNHO) &&
            voo.Status__c.equals(PRERESERVADO)) ||
            // Se o Status mudar de Rascunho para Reservado, deve criar Eventos
            (vooOld.Status__c.equals(RASCUNHO) &&
            voo.Status__c.equals(RESERVADO)) ||
            // Se o Status mudar de Pré-Reservado para Reservado, deve criar Eventos
            (vooOld.Status__c.equals(PRERESERVADO) &&
            voo.Status__c.equals(RESERVADO))) &&
            // Se a Rota mudar, ou não possuir status para criar/atualizar evento, ou não possuir uma Data valida para o Voo
            (voo.RotaCompleta__c == vooOld.Rota__c) || (voo.RotaCompleta__c == vooOld.RotaCompleta__c)) ||
            //voo.Rota__c == vooOld.Rota__c) ||
            !checkIfVooHasStatusToCreateUpdateEvent(voo) ||
            !checkValidDateOfVoo(voo)
        ) {
            valid = false;
        }
        return valid;
    }

    public List<Voo__c> getVoosToPlan(Map<Id, sObject> existingRecords) {
        List<Voo__c> validVoos = new List<Voo__c>();
        for (Voo__c voo : (List<Voo__c>) records) {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            Boolean valid = true;
            if (
                (voo.Prefixo__c == vooOld.Prefixo__c &&
                voo.DataVoo__c == vooOld.DataVoo__c &&
                voo.TempoCorteCliente__c == vooOld.TempoCorteCliente__c &&
                // Se o Status mudar de Rascunho para Pré-Reservado, deve criar Eventos
                !((vooOld.Status__c.equals(RASCUNHO) &&
                voo.Status__c.equals(PRERESERVADO)) ||
                // Se o Status mudar de Rascunho para Reservado, deve criar Eventos
                (vooOld.Status__c.equals(RASCUNHO) &&
                voo.Status__c.equals(RESERVADO)) ||
                // Se o Status mudar de Pré-Reservado para Reservado, deve criar Eventos
                (vooOld.Status__c.equals(PRERESERVADO) &&
                voo.Status__c.equals(RESERVADO))) &&
                // Se a Rota mudar, ou não possuir status para criar/atualizar evento, ou não possuir uma Data valida para o Voo
                (voo.RotaCompleta__c == vooOld.RotaCompleta__c || voo.RotaCompleta__c == vooOld.Rota__c)) ||
                //voo.Rota__c == vooOld.Rota__c) ||
                !checkIfVooHasStatusToCreateUpdateEvent(voo) ||
                !checkValidDateOfVoo(voo)
            ) {
                valid = false;
            }
            if (valid && checkIfVooHasPrefixo(voo))
                validVoos.add(voo);
        }
        return validVoos;
    }

    public static Integer getTempoPlanejamentoPre(Voo__c voo){
        
        Boolean podeAgendarVooRetroativo = FeatureManagement.checkPermission(
            'AgendarVooRetroativo'
        ); 

        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo(voo.Tipo__c);

        Integer tempoPlanejamentoPre =  entreVoos.entreVoosPre;

        Integer entreVoosRetroativo = Integer.valueOf(
            ConfiguracaoTempo__c.getOrgDefaults().EntreVoosRetroativo__c
        );

        if(voo.dataVoo__c <> voo.dataVooOriginal__c
            && voo.dataVoo__c.addMinutes(-tempoPlanejamentoPre) < system.now()
            && podeAgendarVooRetroativo){
             return entreVoosRetroativo;
        }
        return tempoPlanejamentoPre;
    }
    public Boolean validateTempoPlanejamentoPre(
        Voo__c voo,
        List<Event> eventList,
        CalculoMissaoResult cmr,
        Map<String, Aeronave__c> aeronaveMapByName
    ) {

        Integer tempoPlanejamentoPre = getTempoPlanejamentoPre(voo);
       
        if (cmr == null)
            voo.Missao__c.addError('Não foi possível calcular a missão');
        else {
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            for (Event event : eventList) {
                Boolean permissao = true;
                DateTime eventStartDateTime = event.StartDateTime;
                DateTime eventEndDateTime = event.EndDateTime;
                if (
                    eventStartDateTime < vooStartDate &&
                    eventEndDateTime >
                    vooStartDate.addMinutes(-tempoPlanejamentoPre) &&
                    !voo.Id.equals(event.WhatId) &&
                    voo.Prefixo__c.equals(
                        aeronaveMapByName.get(event.OwnerName__c).Id
                    ) &&
                    (String.isBlank(voo.VooPai__c) ||
                    (String.isNotBlank(voo.VooPai__c) &&
                    !voo.VooPai__c.equals(event.WhatId)))
                ) {
                   voo.Prefixo__c.addError(Label.ErroTempoPlanejamentoPre);
                }
                
            }
        }
        return true;
    }

    public Boolean validatePlanejamentoMeio(
        Voo__c voo,
        List<Event> eventList,
        CalculoMissaoResult cmr,
        Map<String, Aeronave__c> aeronaveMapByName
    ) {
        Boolean valid = true;
        if (cmr != null) {
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            Datetime vooEndDate = Events.calculeDatetimeEndEvent(voo, cmr);

            for (Event event : eventList) {
                Boolean permissao = true;
                DateTime eventStartDate = event.StartDateTime;
                DateTime eventEndDate = event.EndDateTime;
                if (
                    ((eventStartDate <= vooStartDate &&
                    vooEndDate <= eventEndDate) ||
                    (vooStartDate <= eventStartDate &&
                    eventEndDate <= vooEndDate)) &&
                    !voo.Id.equals(event.WhatId) &&
                    voo.Prefixo__c.equals(
                        aeronaveMapByName.get(event.OwnerName__c).Id
                    ) &&
                    (String.isBlank(voo.VooPai__c) ||
                    (String.isNotBlank(voo.VooPai__c) &&
                    !voo.VooPai__c.equals(event.WhatId)))
                ) {
                    permissao = false;
                    valid = permissao;
                }

                if (!permissao) {                   
                    voo.Prefixo__c.addError(Label.ErroVooDentroPeriodo);
                }
            }
        } else if (!checkIfVooHasPrefixo(voo)) {
            valid = false;
            voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
        } else if (cmr == null) {
            valid = false;
            voo.Missao__c.addError('Validar Meio: Não foi criado um CMR');
        }
        return valid;
    }

    public Boolean validateTempoPlanejamentoPos(
        Voo__c voo,
        List<Event> eventList,
        CalculoMissaoResult cmr,
        Map<String, Aeronave__c> aeronaveMapByName
    ) {
        Boolean valid = true;
        if (cmr != null) {
            ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo(voo.Tipo__c);
            Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;
            Datetime vooStartDate = Events.calculeDatetimeStartEvent(voo, cmr);
            Datetime vooEndDate = Events.calculeDatetimeEndEvent(voo, cmr);

            for (Event event : eventList) {
                Boolean permissao = true;
                DateTime eventStartDate = event.StartDateTime;
                DateTime eventEndDate = event.EndDateTime;

                if (
                    vooStartDate < eventStartDate &&
                    vooEndDate.addMinutes(tempoPlanejamentoPos) >
                    eventStartDate &&
                    vooEndDate < eventEndDate &&
                    !voo.Id.equals(event.WhatId) &&
                    voo.Prefixo__c.equals(
                        aeronaveMapByName.get(event.OwnerName__c).Id
                    ) &&
                    (String.isBlank(voo.VooPai__c) ||
                    (String.isNotBlank(voo.VooPai__c) &&
                    !voo.VooPai__c.equals(event.WhatId)))
                ) {
                    permissao = false;
                    valid = permissao;
                }

                if (!permissao) {
                    voo.Prefixo__c.addError(Label.ErroTempoPlanejamentoPos);
                }
            }
        } else if (cmr == null) {
            valid = false;
            voo.Missao__c.addError('Validar Pós: Não foi criado um CMR');
        }
        return valid;
    }

    public Boolean validateManutencao(
        Voo__c voo,
        List<Event> eventList,
        CalculoMissaoResult cmr,
        fflib_ISObjectUnitOfWork uow
    ) {
        Boolean valid = true;
        if (checkValidDateOfVoo(voo)) {
            Integer tempoPlanejamentoPre = getTempoPlanejamentoPre(voo);
            ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo(voo.Tipo__c);
            Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;
            Datetime vooStart = Events.calculeDatetimeStartEvent(voo, cmr)
                .addMinutes(-tempoPlanejamentoPre);
            Datetime vooEnd = null;
            Datetime horaAtual = Datetime.now();

            if (cmr != null) {
                vooEnd = Events.calculeDatetimeEndEvent(voo, cmr)
                    .addMinutes(tempoPlanejamentoPos);

                for (Event event : eventList) {
                    Boolean permissao = true;
                    Datetime eventStart = null;
                    Datetime eventEnd = null;
                    if (
                        String.isNotBlank(voo.Prefixo__c) &&
                        voo.Prefixo__c.equals(event.WhatId) &&
                        !event.Cancelado__c
                    ) {
                        eventStart = event.StartDateTime;
                        eventEnd = event.EndDateTime;
                        if (
                            eventStart <= horaAtual &&
                            horaAtual < eventEnd &&
                            eventStart < vooStart &&
                            vooStart < eventEnd
                        ) {
                            permissao = false;
                            valid = permissao;
                            voo.Prefixo__c.addError(Label.ErroEventoManutencaoJaIniciado);
                        } else if (
                            Events.newInstance(new List<Event>())
                                .validateIfDateOfEventEntersInDateOfAnotherEvent(
                                    vooStart,
                                    vooEnd,
                                    eventStart,
                                    eventEnd
                                )
                        ) {
                            if (
                                event.Urgencia__c.equals(
                                    Label.ManutencaoUrgenciaAlta
                                )
                            ) {
                                permissao = false;
                                valid = permissao;
                                voo.Prefixo__c.addError(Label.ErroManutencao);
                            } else if (
                                checkIfVooHasStatusReservadoConfirmado(voo)
                            ) {
                                event.Cancelado__c = true;
                                uow.registerDirty(event);
                            }
                        }
                    }
                    if (!permissao)
                        break;
                }
            } else if (!checkIfVooHasPrefixo(voo)) {
                valid = false;
                voo.Prefixo__c.addError(Label.ErroPrefixoVazio);
            } else if (cmr == null) {
                valid = false;
                voo.Missao__c.addError(
                    'Validar Meio: CMR não foi definido para esse Voo. Fale com um administrador'
                );
            }
        }
        return valid;
    }

    public void createEventRelatedToVoo(
        Voo__c voo,
        CalculoMissaoResult cmr,
        Map<Id, Aeronave__c> aeronaveMap,
        Map<Id, Calendar> calendarMap,
        Map<Id, Account> accountMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        Calendar calendar = retrieveCalendarByVooAndCalendarMap(
            voo,
            aeronaveMap,
            calendarMap
        );
        if (calendar != null) {
            EventsService.createEvent(
                voo,
                calendar,
                cmr,
                accountMap.get(voo.Cliente__c),
                aeronaveMap.get(voo.Prefixo__c),
                uow
            );
        } else if (checkIfVooHasPrefixo(voo)) {
            throw new VooException(Label.PrefixoNaoPossuiCalendario);
        }
    }

    public Boolean validateTempoPlanejamento(
        Voo__c voo,
        List<Event> eventList,
        CalculoMissaoResult cmr,
        Map<String, Aeronave__c> aeronaveMapByName
    ) {
        Boolean valid = false;
        if (!String.isBlank(voo.Prefixo__c)) {
            if (
                this.validatePlanejamentoMeio(
                    voo,
                    eventList,
                    cmr,
                    aeronaveMapByName
                ) &&
                this.validateTempoPlanejamentoPre(
                    voo,
                    eventList,
                    cmr,
                    aeronaveMapByName
                ) &&
                this.validateTempoPlanejamentoPos(
                    voo,
                    eventList,
                    cmr,
                    aeronaveMapByName
                )
            ) {
                valid = true;
            }
        }
        return valid;
    }

    public void validateExistingRecordsTempoPlanejamentoAndCreateUpdateRelatedEvent(
        Voo__c voo,
        List<Event> entreVoosPreEventList,
        List<Event> eventList,
        List<Event> entreVoosPosEventList,
        CalculoMissaoResult cmr,
        Map<Id, SObject> existingRecords,
        Map<Id, Aeronave__c> aeronaveMap,
        Map<Id, Calendar> calendarMap,
        Map<Id, Account> accountMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (
            !checkIfVooHasPrefixo(voo) &&
            checkIfVooHasPrefixo((Voo__c) existingRecords.get(voo.Id))
        ) {
            EventsService.deleteEventRelatedToVoo(
                voo,
                entreVoosPreEventList,
                eventList,
                entreVoosPosEventList,
                uow
            );
        } else if (
            validateTempoPlanejamento(
                voo,
                eventList,
                cmr,
                retrieveNameAeronaveMapFromAeronaveList(aeronaveMap.values())
            )
        ) {
            EventsService.deleteEventRelatedToVoo(
                voo,
                entreVoosPreEventList,
                eventList,
                entreVoosPosEventList,
                uow
            );

            Datetime umaSemanaAFrente = System.now().addDays(7); //campo para comparar a antecedência de uma semana
            if (
                voo.TrocaTurma__c == true &&
                voo.DataVoo__c > umaSemanaAFrente
            ) {
                //Comportamento adicionado para o caso previsto na story 191
                //Pela não definição de cálculo de missão e por do sol no momento de desenvolvimento,
                //crio os eventos até às 20h do dia do voo.
                //O voos não estão de subscrevendo nos tempo dos cálculos de missão, mas os eventos de voo
                //ainda estão permitindo subscrição
                Datetime fimVoo = Datetime.newInstance(
                    voo.DataVoo__c.date(),
                    time.newInstance(20, 0, 0, 0)
                );
                Long tempoVoo =
                    (fimVoo.getTime() - voo.DataVoo__c.getTime()) /
                    1000 /
                    60;
                cmr.tempoMissao = tempoVoo;
            }
            createEventRelatedToVoo(
                voo,
                cmr,
                aeronaveMap,
                calendarMap,
                accountMap,
                uow
            );
        }
    }

    public void updateTrechosBycmrMap(
        Map<Id, SObject> existingRecords,
        Map<Id, Voo__c> mapVooComTrecho,
        Map<Id, CalculoMissaoResult> mapVooViavelCMR,
        fflib_ISObjectUnitOfWork uow
    ) {
        for (Voo__c voo : (List<Voo__c>) records) {
            List<Trecho__c> trajeto = mapVooComTrecho.get(voo.Id).Trechos__r;
            CalculoMissaoResult cmr = mapVooViavelCMR.get(voo.Id);
            if (
                checkVooDataToValidPlanning(
                    voo,
                    (Voo__c) existingRecords.get(voo.Id)
                ) &&
                String.isNotBlank(voo.Prefixo__c) &&
                voo.DataVoo__c != null &&
                cmr != null
            ) {
                List<FlightLeg> flighLegs = cmr.trechos;

                if (
                    flighLegs != null &&
                    trajeto != null &&
                    trajeto.size() > 0 &&
                    flighLegs.size() > 0
                ) {
                    Decimal tempoTransladoIda = (cmr.tempoTransladoIda != null
                        ? cmr.tempoTransladoIda
                        : 0);
                    if (
                        trajeto != null &&
                        trajeto.size() > 0 &&
                        trajeto[0].Tipo__c == 'Translado'
                    ) {
                        if (
                            cmr != null &&
                            cmr.trechos != null &&
                            cmr.trechos.size() > 0 &&
                            cmr.trechos[0].tempoMissao != null
                        ) {
                            tempoTransladoIda = cmr.trechos[0].tempoMissao;
                        }
                    }
                    Boolean temTransladoIda = (tempoTransladoIda > 0
                        ? true
                        : false);
                    for (Integer index = 0; index < trajeto.size(); index++) {
                        updateTrechoBycmr(
                            voo,
                            trajeto[index],
                            flighLegs[index],
                            tempoTransladoIda,
                            uow
                        );
                    }
                } else if (
                    cmr != null &&
                    trajeto != null &&
                    trajeto.size() > 0 &&
                    (cmr.trechos == null ||
                    trajeto.size() != cmr.trechos.size())
                ) {
                    //System.debug('CMR Size: ' + (cmr != null ? cmr.trechos.size() + '' : 'Nulo (0)') + '\nTrajeto Size: ' + trajeto.size());
                    /*System.debug(
                        'CMR: ' + cmr +
                        '\nTrechos Size: ' + trajeto.size() +
                        '\nFlightleg Size: ' + (cmr.trechos != null ? String.valueOf(cmr.trechos.size()) : String.valueOf(cmr.trechos)) +
                        '\nupdateTrechosBycmrMap');*/
                    /*throw new CalloutException(
                        'CMR: ' + cmr +
                        '\nTrechos Size: ' + trajeto.size() +
                        '\nFlightleg Size: ' + (cmr.trechos != null ? String.valueOf(cmr.trechos.size()) : String.valueOf(cmr.trechos)) +
                        '\nupdateTrechosBycmrMap');*/
                }
            }
        }
    }

    public void updateTrechoBycmr(
        Voo__c voo,
        Trecho__c trecho,
        FlightLeg flightLeg,
        Decimal tempoTransladoIda,
        fflib_ISObjectUnitOfWork uow
    ) {
        trecho.TempoDecorrido__c = flightLeg.tempoDecorrido;
        trecho.TempoCruzeiro__c = flightLeg.tempoCruzeiro;
        trecho.TempoSolo__c = flightLeg.tempoSolo;
        trecho.TempoMissao__c = flightLeg.tempoMissao;
        trecho.DisponibilidadePeso__c = flightLeg.DisponibilidadePeso;
        trecho.PrevisaoDecolagem__c = voo.DataVoo__c.addMinutes(
            Integer.valueOf(flightLeg.tempoDecorrido - tempoTransladoIda)
        );
        uow.registerDirty(trecho);
    }

    public List<Voo__c> getCanceledVoosOrUpdatedToRascunho(
        Map<Id, sObject> existingRecords
    ) {
        List<Voo__c> voosToDeleteEvent = new List<Voo__c>();
        for (Voo__c voo : (List<Voo__c>) records) {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            if (
                (!vooOld.Status__c.equals(CANCELADO) &&
                voo.Status__c.equals(CANCELADO)) ||
                (!vooOld.Status__c.equals(RASCUNHO) &&
                voo.Status__c.equals(RASCUNHO))
            ) {
                voosToDeleteEvent.add(voo);
            }
        }
        return voosToDeleteEvent;
    }

    public CalculoMissaoResult createCMRByMissao(Missao__c missao) {
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        cmr.tempoTransladoIda = missao.TempoTransladoIda__c;
        cmr.tempoTransladoRetorno = missao.TempoTransladoRetorno__c;
        cmr.tempoCruzeiro = missao.TempoCruzeiro__c;
        cmr.tempoSolo = missao.TempoSolo__c;
        cmr.tempoMissao = missao.TempoMissao__c;
        return cmr;
    }

    public List<Voo__C> getVoosWithTempoMissaoUpdated(
        Map<Id, sObject> existingRecords,
        Map<Id, Missao__c> missoesMap,
        Map<Id, Aeronave__c> aeronaveMap,
        Map<Id, Calendar> calendarMap,
        Map<Id, Account> accountMap
    ) {
        List<Voo__c> voosTempoMissaoUpdated = new List<Voo__c>();
        for (Voo__c voo : (List<Voo__c>) records) {
            Voo__c vooOld = (Voo__c) existingRecords.get(voo.Id);
            Missao__c missao = missoesMap.get(voo.Missao__c);

            if (
                !checkVooDataToValidPlanning(voo, vooOld) &&
                voo.Missao__c != null &&
                (voo.TempoMissao__c != null &&
                voo.TempoMissao__c > 0) &&
                voo.TempoMissao__c != vooOld.TempoMissao__c &&
                voo.Missao__c == vooOld.Missao__c &&
                missao != null &&
                checkIfVooCanCreateUpdateEvent(voo)
            ) {
                voosTempoMissaoUpdated.add(voo);
            } else if (
                String.isNotBlank(voo.Missao__c) &&
                (voo.TempoMissao__c == null ||
                voo.TempoMissao__c <= 0) &&
                checkIfVooCanCreateUpdateEvent(voo)
            ) {
                voo.TempoMissao__c.addError(Label.ErroTempoMissaoVazio);
            }
        }
        return voosTempoMissaoUpdated;
    }

    public void createEventWithNewTempoMissaoOfVoo(
        Voo__c voo,
        Missao__c missao,
        Calendar calendar,
        Account cliente,
        Aeronave__c aeronave,
        Set<Event> eventsSet,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (missao.TempoMissao__c != voo.TempoMissao__c) {
            missao.TempoMissao__c = voo.TempoMissao__c;
            uow.registerDirty(missao);
        }

        CalculoMissaoResult cmr = createCMRByMissao(missao);

        EventsService.deleteEventRelatedToVoo(voo, eventsSet, uow);
        EventsService.createEvent(voo, calendar, cmr, cliente, aeronave, uow);
    }

    public void handleEventsOnBeforeDelete(
        List<Voo__c> voos,
        fflib_ISObjectUnitOfWork uow
    ) {
        Set<Id> aeronaveSetId = this.retrieveAeronaveSetIdFromRecords(voos);
        List<Aeronave__c> aeronaveList = AeronavesSelector.newInstance()
            .selectById(aeronaveSetId);

        Integer IntervaloEmDiasBuscaEventos = Integer.valueOf(
            ConfiguracaoTempo__c.getOrgDefaults().IntervaloEmDiasBuscaEventos__c
        );
        Datetime smallerDate = retrieveSmallerDateFromRecords();
        smallerDate = smallerDate != null
            ? Datetime.newInstance(
                      smallerDate.date(),
                      Time.newInstance(0, 0, 0, 0)
                  )
                  .addDays(-IntervaloEmDiasBuscaEventos)
            : null;
        Datetime biggerDate = retrieveBiggerDateFromRecords();
        biggerDate = biggerDate != null
            ? Datetime.newInstance(
                      biggerDate.date(),
                      Time.newInstance(23, 59, 0, 0)
                  )
                  .addDays(IntervaloEmDiasBuscaEventos)
            : null;

        Set<String> aeronaveSetName = Utils.getSetOfField(
            (List<SObject>) aeronaveList,
            'Name'
        );
        Set<String> whatIds = (Set<String>) Utils.getSetOfField(records, 'Id');
        // Todos Eventos por Nome de Calendário e id de Voo
        Map<Id, Event> eventMap = new Map<Id, Event>(
            EventsSelector.newInstance()
                .selectEventsByOwnerNameOrWhatId(
                    aeronaveSetName,
                    whatIds,
                    smallerDate,
                    biggerDate
                )
        );
        // Separar os eventos por tipo de registro
        Events eventsDomain = new Events(eventMap.values());
        List<Event> entreVoosPreEventList = eventsDomain.getEntreVoos(
            Label.Pre
        );
        List<Event> eventVooList = eventsDomain.getVoo();
        List<Event> entreVoosPosEventList = eventsDomain.getEntreVoos(
            Label.Pos
        );

        for (Voo__c voo : voos) {
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Deletar Eventos Relacionados ao Voo ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
            if (!this.verifyExistingEventForVoo(voo, eventVooList)) {
                EventsService.deleteEventRelatedToVoo(
                    voo,
                    entreVoosPreEventList,
                    eventVooList,
                    entreVoosPosEventList,
                    uow
                );
            }
            //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        }
    }

    public override void handleAfterDelete() {
        /*if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isDeletable())
         throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');*/

        onAfterDelete();
    }

    private void handleAtualizacaoTipo(Map<Id,Voo__c> mapVoos)
    {
        List<Trecho__c> trechosFromVoos = TrechosSelector.newInstance().selectByVooId(mapVoos.keySet());
        fflib_ISObjectUnitOfWork uowForUpdate = Application.UnitOfWork.newInstance();
        List<Trecho__c> trechosForUpdate = new List<Trecho__c>();
        for(Trecho__c trecho : trechosFromVoos)
        {
            String tipoVoo = mapVoos.get(trecho.Voo__c)?.Tipo__c;
            if(trecho.Tipo__c != tipoVoo && trecho.Tipo__c != Trechos.TRANSLADO)
            {
                trecho.Tipo__c = tipoVoo;
                trechosForUpdate.add(trecho);
            }
        }
        if(trechosForUpdate.size() > 0)
        {
            uowForUpdate.registerDirty(trechosForUpdate);
            uowForUpdate.commitWork();
        }
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if (!ignorarTriggerUpdate()) {                   
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            Map<Id,Voo__c> mapVoosUpdateTipo = new Map<Id,Voo__c>();
            for (Voo__c voo : (List<Voo__c>) records) {
                Voo__c oldVoo = (Voo__c) existingRecords.get(voo.Id);
                handleAtualizaDataVoo(voo, oldVoo);
                if(voo.Tipo__c != oldVoo.Tipo__c && voo.Tipo__c != null)
                {
                    mapVoosUpdateTipo.put(voo.Id, voo);
                }                
            }
            if(mapVoosUpdateTipo.size() > 0)
            {
                handleAtualizacaoTipo(mapVoosUpdateTipo);
            }            
            uow.commitWork();    
            
        }
        
    }

    private Boolean checkStatusDiferente(Voo__c voo, Voo__c oldVoo) {
        if (voo == null || oldVoo == null) {
            throw new VooException(
                'Algum dos voos passados no parâmetro está nulo: [Voo -> ' +
                voo +
                '] [oldVoo -> ' +
                oldVoo +
                ']'
            );
        }

        return !voo.Status__c.equals(oldVoo.Status__c);
    }

    private void updateFields(Voo__c vooToUpdate, Voo__c oldVoo) {
        if (
            checkStatusDiferente(vooToUpdate, oldVoo) &&
            checkIfVooStatusIsReservado(vooToUpdate)
        ) {
            vooToUpdate.HorarioVooReservado2__c = Utils.getDatetimeGmt(
                System.now()
            );
        }
    }

    private CalculoMissaoResult getCMR(
        Voo__c voo,
        Aeronave__c aeronave,
        List<Local__c> trajeto
    ) {
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        if (
            voo != null &&
            aeronave != null &&
            trajeto != null &&
            trajeto.size() > 0 &&
            voo.DataVoo__c != null
        ) {
            cmr.calculaTranslado = false;
            cmr.ExecutarCalculoMissao(aeronave, trajeto, voo.DataVoo__c.date());
        }

        return cmr;
    }

    private Boolean checkCriaCalculoMissaoResult(Voo__c voo, Voo__c oldVoo) {
        if (voo.Prefixo__c == null || voo.DataVoo__c == null) {
            return false;
        } else if (
            (oldVoo.Status__c.equals(RASCUNHO) &&
            (voo.Status__c.equals(PRERESERVADO) ||
            voo.Status__c.equals(RESERVADO))) ||
            (oldVoo.Status__c.equals(PRERESERVADO) &&
            voo.Status__c.equals(RESERVADO))
        ) {
            return true;
        } else if (
            voo.Status__c.equals(PRERESERVADO) ||
            voo.Status__c.equals(RESERVADO) ||
            voo.Status__c.equals(CONFIRMADO)
        ) {
            
            if (
                voo.Prefixo__c != oldVoo.Prefixo__c || //prefixo mudou
                voo.DataVoo__c != oldVoo.DataVoo__c || //data mudou
                voo.TempoCorteCliente__c != oldVoo.TempoCorteCliente__c || //corte mudou
                (voo.RotaCompleta__c != oldVoo.Rota__c) && (voo.RotaCompleta__c != oldVoo.RotaCompleta__c) //rota mudou
            ) {
                return true;
            }
        }

        return false;
    }
    public void handleAtualizaDataVoo(Voo__c voo, Voo__c oldVoo)
    {
        if(voo.DataVoo__c != null && voo.DataVoo__c != oldVoo.DataVoo__c && 
          (oldVoo.DataVoo__c == null
           || !(voo.DataVoo__c.date() == oldVoo.DataVoo__c.date() && voo.DataVoo__c.hour() == oldVoo.DataVoo__c.hour() && 
            voo.DataVoo__c.minute() == oldVoo.DataVoo__c.minute() && voo.DataVoo__c.second() != oldVoo.DataVoo__c.second())))
        {
            AtualizacaoDataVoo__e atualizacao = new AtualizacaoDataVoo__e();
            atualizacao.recordId__c = voo.Id;
            EventBus.publish(atualizacao);
        }
    }
    public override void onBeforeInsert() {
        
    }

    public void validaUpdate(List<Voo__c> voosList) {
        Map<Id, Voo__c> oldVoos = (Map<Id, Voo__c>) Trigger.oldMap;
        
        Profile adminProfile = 
            [SELECT Id FROM Profile
            WHERE Name = 'Administrador do Sistema' OR Name = 'System Administrator'
            LIMIT 1];
        Boolean userIsAdmin = (UserInfo.getProfileId() == adminProfile.Id);

        if (userIsAdmin || System.IsBatch()) {
            return;
        }

        for (Voo__c voo : voosList) {
            Voo__c oldVoo = oldVoos.get(voo.Id);
            if (oldVoo.Status__c == FATURAMENTO || oldVoo.Status__c == FATURADO) {
                String errorMessage = Label.OnlyAdminCanModifyFlightWithStatus.replace('{status}', oldVoo.Status__c);
                voo.addError(errorMessage);
            }
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Boolean ignorarTrigger = false;
        Map<Id, Voo__c> oldVoos = (Map<Id, Voo__c>) Trigger.oldMap;
        Map<Id, Voo__c> newVoos = (Map<Id, Voo__c>) Trigger.newMap;
        List<Voo__c> calculaMissao = new List<Voo__c>();
        
        Set<Id> idContas =  new Set<Id>();
        Set<Id> aeronaves =  new Set<Id>();
        Date dataInicio;
        Date dataFim;
        
        for (Voo__c voo : (List<Voo__c>) records) {
            if (voo.IgnorarTrigger__c) {
                ignorarTrigger = true;
                break;
            }

            calculaMissao.add(voo);

            updateFields(voo, oldVoos.get(voo.Id));
        }

        if (!ignorarTrigger && !ignorarTriggerUpdate()) {
            validaUpdate((List<Voo__c>) records);
            
			if (!ignorarTrigger && !ignorarTriggerUpdate() && calculaMissao.size() > 0 ){
                calcularMissao(calculaMissao, oldVoos);
            }
        }

	}

	public void calcularMissao(List<Voo__c> records, Map<Id, Voo__c> oldVoos){

        //Carrega dados de aeronaves
        Set<Id> aeronavesIds = new Set<Id>();
        aeronavesIds.addAll(Utils.getSetIds(records, 'Prefixo__c'));
        aeronavesIds.addAll(Utils.getSetIds(existingRecords.values(), 'Prefixo__c'));
        Map<Id, Aeronave__c> aeronaveMap = 
            new Map<Id, Aeronave__c>(AeronavesSelector.newInstance().selectAeronaveAndModelo(aeronavesIds));
        Map<String, Aeronave__c> nameAeronaveMap = this.retrieveNameAeronaveMapFromAeronaveList(aeronaveMap.values());
    
        //Carrega voos com trechos
        Map<Id, Voo__c> mapVooComTrecho = 
            new Map<Id, Voo__c>(VoosSelector.newInstance().selectWithTrechosById(Utils.getSetIds(records, 'Id')));

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Map<Id, CalculoMissaoResult> mapVooViavelCMR = new Map<Id, CalculoMissaoResult>();

        Map<Voo__c, Map<Schema.SObjectField, List<String>>> mapVooErrors = new Map<Voo__c, Map<Schema.SObjectField, List<String>>>();

        for (Voo__c voo : (List<Voo__c>) records) {
            
            Voo__c oldVoo = (Voo__c) existingRecords.get(voo.Id);

            if (
                checkCriaCalculoMissaoResult(voo, oldVoo) &&
                mapVooComTrecho.get(voo.Id) != null &&
                mapVooComTrecho.get(voo.Id).Trechos__r.size() > 0
            ) {
                Aeronave__c aeronave = aeronaveMap.get(voo.Prefixo__c);
                List<Local__c> trajeto = Trechos.newInstance(
                        mapVooComTrecho.get(voo.Id).Trechos__r
                    )
                    .getTrajeto();
                //Criação de CMR
                CalculoMissaoResult cmr = getCMR(voo, aeronave, trajeto);
                
                if (cmr != null && cmr.viabilidade) {
                    if (
                        voo.QtdTrechosOrigemOffshore__c > 0 &&
                        cmr.hrMaximoDecolagem != null &&
                        voo.DataVoo__c > cmr.hrMaximoDecolagem
                    ) {
                        //TODO: Renato e Fernando: setar erro bonitinho
                        voo.addError(
                            Label.ErroOrigemOffShoreUltrapassaHorarioMaximoDecolagem.replace(
                                '@horariomaximo',
                                cmr.hrMaximoDecolagem.format('kk:mm:ss')
                            )
                        );
                    } else {
                        //se o voo é viável, insere o cmr no map de voos viaveis
                        //TODO: Renato e Fernando: utilizar esse map para criar missões
                        mapVooViavelCMR.put(voo.Id, cmr);
                    }
                } else if (cmr != null && !cmr.viabilidade) {
                    //TODO: Renato e Fernando: setar erro bonitinho
                    voo.addError(
                        'Voo inviável por motivos de peso ou combustível'
                    );
                }
            } else {
                //setErrors(voo, mapVooErrors);
            }
        }

        List<Voo__c> voosCalculoColisao = new List<Voo__c>();
        for (Voo__c voo : (List<Voo__c>) records) {
            if (
                voo.status__c.equals(RESERVADO) ||
                voo.status__c.equals(ROTA) ||
                voo.status__c.equals(PRERESERVADO) ||
                voo.status__c.equals(CONFIRMADO)
            )
                voosCalculoColisao.add(voo);
        }

        for (Voo__c voo : voosCalculoColisao) {
            //System.debug('Voos - Before Update2');
            for (Voo__c vooToCompare : voosCalculoColisao) {
                Boolean valid = null;
                //System.debug('Voos - Update3' + voo);
                //System.debug('Voos - Update3' + vooToCompare);
                //SE AMBOS OS VOOS NÃO ESTÃO EM RASCUNHO OU CANCELADO
                if (
                    voo != vooToCompare &&
                    !voo.Status__c.equals(RASCUNHO) &&
                    !voo.Status__c.equals(CANCELADO) &&
                    !vooToCompare.Status__c.equals(RASCUNHO) &&
                    !vooToCompare.Status__c.equals(CANCELADO)
                ) {
                    //SE É A MESMA AERONAVE
                    if (voo.Prefixo__c.equals(vooToCompare.Prefixo__c)) {
                        CalculoMissaoResult cmrVoo = mapVooViavelCMR.get(
                            voo.Id
                        );
                        CalculoMissaoResult cmrVooToCompare = mapVooViavelCMR.get(
                            vooToCompare.Id
                        );
                        if (cmrVoo != null && cmrVooToCompare != null) {
                            if (
                                colideHorario(
                                    voo,
                                    cmrVoo,
                                    vooToCompare,
                                    cmrVooToCompare
                                )
                            ) {
                                valid = false;
                                voo.addError(
                                    Label.ErroHorarioConflitanteEntreVoos
                                );
                            } else {
                                valid = true;
                            }
                        }
                    }
                }
            }
        }

        // ################################# Handle Events on Before Update #################################
        Map<Id, Calendar> calendarMap = this.retrieveCalendarMapByRecords(
            nameAeronaveMap.keySet(),
            aeronaveMap
        );
        
        Map<Id, Account> accountMap = this.retrieveAccountMapFromVooList(
            (List<Voo__c>) records
        );
        
        //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        Set<Id> missoesSetId = Utils.getSetIds(records, 'Missao__c');
        Map<Id, Missao__c> missoesMap = new Map<Id, Missao__c>(
            MissoesSelector.newInstance().selectById(missoesSetId)
        );
        //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Condição para busca de Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        Boolean buscarEventos = false;
        List<Event> entreVoosPreEventList = new List<Event>();
        List<Event> eventVooList = new List<Event>();
        List<Event> entreVoosPosEventList = new List<Event>();
        List<Event> eventManutencaoList = new List<Event>();
        Set<Event> eventSet = new Set<Event>();

        List<Voo__c> voosToPlan = getVoosToPlan(existingRecords);
        List<Voo__c> voosToDeleteEvents = getCanceledVoosOrUpdatedToRascunho(
            existingRecords
        );
        List<Voo__c> voosWithTempoMissaoUpdated = getVoosWithTempoMissaoUpdated(
            existingRecords,
            missoesMap,
            aeronaveMap,
            calendarMap,
            accountMap
        );
        // Só entra se tiver condição de verificar se invade oturos eventos como entre voos e manutenções de alta prioridade
        // Ou se for deletar eventos de Voos Cancelados e Rascunho
        buscarEventos = (voosToPlan.size() > 0 ||
        voosToDeleteEvents.size() > 0 ||
        voosWithTempoMissaoUpdated.size() > 0);
        if (buscarEventos) {
            Integer IntervaloEmDiasBuscaEventos = Integer.valueOf(
                ConfiguracaoTempo__c.getOrgDefaults()
                    .IntervaloEmDiasBuscaEventos__c
            );
            Datetime smallerDate = retrieveSmallerDateFromRecords();
            smallerDate = smallerDate != null
                ? Datetime.newInstance(
                            smallerDate.date(),
                            Time.newInstance(0, 0, 0, 0)
                        )
                        .addDays(-IntervaloEmDiasBuscaEventos)
                : null;
            Datetime biggerDate = retrieveBiggerDateFromRecords();
            biggerDate = biggerDate != null
                ? Datetime.newInstance(
                            biggerDate.date(),
                            Time.newInstance(23, 59, 0, 0)
                        )
                        .addDays(IntervaloEmDiasBuscaEventos)
                : null;

            Set<String> whatIds = (Set<String>) Utils.getSetOfField(
                records,
                'Id'
            );
            // Todos Eventos por Nome de Calendário e id de Voo
            Map<Id, Event> eventMap = new Map<Id, Event>(
                EventsSelector.newInstance()
                    .selectEventsByOwnerNameOrWhatId(
                        nameAeronaveMap.keySet(),
                        whatIds,
                        smallerDate,
                        biggerDate
                    )
            );
            // Separar os eventos por tipo de registro
            Events eventsDomain = new Events(eventMap.values());
            entreVoosPreEventList.addAll(
                eventsDomain.getEntreVoos(Label.Pre)
            );
            eventVooList.addAll(eventsDomain.getVoo());
            entreVoosPosEventList.addAll(
                eventsDomain.getEntreVoos(Label.Pos)
            );
            eventManutencaoList.addAll(eventsDomain.getManutencao());
            // Criar um set de eventos apenas de entre voos e voos
            eventSet.addAll(
                eventsDomain.groupEventsList(
                    new List<List<Event>>{
                        entreVoosPreEventList,
                        eventVooList,
                        entreVoosPosEventList
                    }
                )
            );
        }

        //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Deleção de Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        EventsService.deleteEventRelatedToVoos(
            voosToDeleteEvents,
            eventSet,
            uow
        );
        //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        
        for (Voo__c voo : voosToPlan) {
            CalculoMissaoResult cmr = mapVooViavelCMR.get(voo.Id);
            //▬▬▬▬▬ Validação de Planejamento/Manutenção, Criação/Atualização de Eventos Relacionados ao Voo ▬▬▬▬▬▬
            if (
                cmr != null &&
                validateManutencao(voo, eventManutencaoList, cmr, uow)
            ) {
                Voo__c vooComTrechos = mapVooComTrecho.get(voo.Id);
                vooComTrechos.DataVoo__c = voo.DataVoo__c;
                vooComTrechos.Prefixo__c = voo.Prefixo__c;

                List<Local__c> locais = new List<Local__c>();

                for (Trecho__c trecho : vooComTrechos.Trechos__r) {
                    locais.add(trecho.Origem__r);
                }
                
                Trecho__c ultimoTrecho = vooComTrechos.Trechos__r[vooComTrechos.Trechos__r.size() - 1];
                
                locais.add(ultimoTrecho.Destino__r);

                SetRotaAbreviada(vooComTrechos, locais);

                validateExistingRecordsTempoPlanejamentoAndCreateUpdateRelatedEvent(
                    vooComTrechos,
                    entreVoosPreEventList,
                    eventVooList,
                    entreVoosPosEventList,
                    cmr,
                    existingRecords,
                    aeronaveMap,
                    calendarMap,
                    accountMap,
                    uow
                );
            }
        }

        //▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ Tempo de Missão Alterado Atualiza Eventos ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
        for (Voo__c voo : voosWithTempoMissaoUpdated) {
            Voo__c vooComTrechos = mapVooComTrecho.get(voo.Id);
            vooComTrechos.DataVoo__c = voo.DataVoo__c;
            vooComTrechos.Prefixo__c = voo.Prefixo__c;
            createEventWithNewTempoMissaoOfVoo(
                vooComTrechos,
                missoesMap.get(voo.Missao__c),
                retrieveCalendarByVooAndCalendarMap(
                    voo,
                    aeronaveMap,
                    calendarMap
                ),
                accountMap.get(voo.Cliente__c),
                aeronaveMap.get(voo.Prefixo__c),
                eventSet,
                uow
            );
        }

        //setErrors(mapVooErrors);
        Map<Id, Missao__c> mapVooMissao = MissoesService.criarMissoes(
            uow,
            mapVooViavelCMR
        );

        for (Voo__c voo : (List<Voo__c>) records) {
            gerenciarMissao(voo, mapVooMissao, uow);
        }

        updateTrechosBycmrMap(
            existingRecords,
            mapVooComTrecho,
            mapVooViavelCMR,
            uow
        );

        uow.commitWork();
        
    }

    private void gerenciarMissao(
        Voo__c voo,
        Map<Id, Missao__c> mapVooMissao,
        fflib_ISObjectUnitOfWork uow
    ) {
        Missao__c missao = mapVooMissao.get(voo.Id);
        if (missao != null) {
            Missao__c oldMissao = voo.Missao__c != null
                ? new Missao__c(Id = voo.Missao__c)
                : null;
            if (oldMissao != null) {
                uow.registerDeleted(oldMissao);
            }
            uow.registerRelationship(voo, Voo__c.Missao__c, missao);
            voo.TempoMissao__c = missao.TempoMissao__c;
        }
    }

    private Boolean colideHorario(
        Voo__c voo,
        CalculoMissaoResult cmrVoo,
        Voo__c vooToCompare,
        CalculoMissaoResult cmrVooToCompare
    ) {
        Integer tempoPlanejamentoPre = getTempoPlanejamentoPre(voo);
        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo(voo.Tipo__c);
        Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;

        Datetime vooStart = Events.calculeDatetimeStartEvent(voo, cmrVoo);
        Datetime vooEnd = Events.calculeDatetimeEndEvent(voo, cmrVoo);

        Datetime vooToCompareStart = Events.calculeDatetimeStartEvent(
            vooToCompare,
            cmrVooToCompare
        );
        Datetime vooToCompareEnd = Events.calculeDatetimeEndEvent(
            vooToCompare,
            cmrVooToCompare
        );

        IEvents events = Events.newInstance(new List<Event>());
        Boolean enterInAnotherEvent = events.validateIfDateOfEventEntersInDateOfAnotherEvent(
            vooStart,
            vooEnd,
            vooToCompareStart,
            vooToCompareEnd
        );
        return enterInAnotherEvent;
    }

    public override void onBeforeDelete() {
        //System.debug('Voos - Before Delete');

        List<Voo__c> voosDeletar = validaDelecao((List<Voo__c>) Records);

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        handleEventsOnBeforeDelete(voosDeletar, uow);

        uow.commitWork();
    }

    public static List<Voo__c> validaDelecao(List<Voo__c> voos) {
        Boolean podeDeletarVooStatusAvancado = FeatureManagement.checkPermission(
            'AdminDeletaVoo'
        );
        List<Voo__c> voosParaDeletar = new List<Voo__c>();
        if (!podeDeletarVooStatusAvancado) {
            List<StatusBloqueioDelecaoVoo__mdt> statusBloqueados = StatusBloqueioDelecaoVooSelector.newInstance()
                .selectAll();
            Set<String> setStatusBloqueados = Utils.getSetOfField(
                statusBloqueados,
                'DeveloperName'
            );
            Map<String, String> devNameToLabel = Utils.getMapDevLabelFromPicklist(
                Voo__c.Status__c.getDescribe()
            );

            for (Voo__c voo : voos) {
                if (
                    setStatusBloqueados.contains(
                        voo.Status__c.replaceAll(' ', '')
                    )
                ) {
                    String statusLabel = devNameToLabel.get(voo.Status__c);
                    voo.addError(
                        Label.NaoPodeDeletarVooStatus.replace(
                            '#statusLabel#',
                            statusLabel
                        )
                    );
                } else {
                    voosParaDeletar.add(voo);
                }
            }
        } else {
            voosParaDeletar.addAll(voos);
        }
        return voosParaDeletar;
    }

    public class VooException extends Exception {
    }
}