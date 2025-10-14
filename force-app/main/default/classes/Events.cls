public without sharing class Events extends fflib_SObjectDomain implements IEvents {
    
    public static FINAL String VOO_EVENT_SUBJECT = 'Voo';
    public static FINAL String ENTRE_VOOS_EVENT_SUBJECT = 'Entre Voos';
    static FINAL Id RECORD_TYPE_VOO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Voo').getRecordTypeId();
    static FINAL Id RECORD_TYPE_MANUTENCAO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Manutencao').getRecordTypeId();
    
    static FINAL Id RECORD_TYPE_ENTRE_VOOS_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('EntreVoos').getRecordTypeId();
    
    public static IEvents newInstance(List<Event> sObjectList)
    {
        return (IEvents) Application.Domain.newInstance(sObjectList);
    }
    
    public Events(List<Event> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Events(sObjectList);
        }
    }
    
    public List<Event> getEventByDeveloperName(String recordTypeName)
    {
        return getEventByDeveloperName(recordTypeName, null);
    }
    
    public List<Event> getEventByDeveloperName(String recordTypeName, String tipo)
    {
        Id RECORD_TYPE_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        
        List<Event> eventsByType = new List<Event>();
        
        for(Event evt: (List<Event>) Records)
        {
            if(String.isNotBlank(evt.RecordTypeId) && evt.RecordTypeId.equals(RECORD_TYPE_EVENT_ID) &&
               (String.isBlank(tipo) || (String.isNotBlank(tipo) && evt.Type.equals(tipo))))
            {
                eventsByType.add(evt);
            }
        }
        
        return eventsByType;
    }
    
    public List<Event> getEntreVoos()
    {
        return getEntreVoos(null);
    }
    
    public List<Event> getEntreVoos(String tipo)
    {
        return getEventByDeveloperName('EntreVoos', tipo);
    }
    
    public List<Event> getManutencao()
    {
        return getEventByDeveloperName('Manutencao');
    }
    
    public List<Event> getVoo()
    {
        return getEventByDeveloperName('Voo');
    }
    
    public List<Event> groupEventsList(List<List<Event>> eventsToGroup)
    {
        List<Event> events = new List<Event>();
        for (List<Event> evtList : eventsToGroup)
        {
            events.addAll(evtList);
        }
        return events;
    }
    
    public static Datetime calculeDatetimeStartEvent(Voo__c voo, CalculoMissaoResult cmr)
    {
        if(voo == null) throw new EventsException('Para calcular data/hora de início do voo, o voo não pode ser nulo');
        if(cmr == null) throw new EventsException('Para calcular data/hora de início do voo, o CalculoMissaoResult não pode ser nulo');
        Integer TransladoIda = Integer.valueOf(cmr.tempoTransladoIda != null ? cmr.tempoTransladoIda : 0);
        Datetime activyDatetime = calculeDatetimeStartEvent(voo.DataVoo__c, TransladoIda);
        return activyDatetime;
    }
    
    public static Datetime calculeDatetimeStartEvent(Datetime dataVoo, Integer TransladoIda)
    {
        if(dataVoo == null) throw new EventsException('Para calcular data/hora de início do voo, a data/hora do voo não pode ser nulo');
        if(TransladoIda == null) throw new EventsException('Para calcular data/hora de início do voo, o translado de ida não pode ser nulo');
        Datetime activyDatetime = dataVoo.addMinutes(-TransladoIda);
        return activyDatetime;
    }
    
    public static Datetime calculeDatetimeEndEvent(Voo__c voo, CalculoMissaoResult cmr)
    {
        if(voo == null) throw new EventsException('Para calcular data/hora de fim do voo, o voo não pode ser nulo');
        if(cmr == null) throw new EventsException('Para calcular data/hora de fim do voo, o CalculoMissaoResult não pode ser nulo');
        Integer TransladoIda = Integer.valueOf(cmr.tempoTransladoIda != null ? cmr.tempoTransladoIda : 0);
        Integer TempoMissao = Integer.valueOf(cmr.tempoMissao != null ? cmr.tempoMissao : 0);
        Integer TempoCorteCliente = Integer.valueOf(voo.TempoCorteCliente__c != null ? voo.TempoCorteCliente__c : 0);
        Datetime endDateTime = calculeDatetimeEndEvent(voo.DataVoo__c, TransladoIda, TempoMissao, TempoCorteCliente);
        //System.debug('End Date: ' + endDateTime);
        return endDateTime;
    }
    
    public static Datetime calculeDatetimeEndEvent(Datetime dataVoo, Integer TransladoIda, Integer TempoMissao, Integer TempoCorteCliente)
    {
        if(dataVoo == null) throw new EventsException('Para calcular data/hora de fim do voo, a data do voo não pode ser nulo');
        if(TransladoIda == null) throw new EventsException('Para calcular data/hora de fim do voo, o translado de ida não pode ser nulo');
        if(TempoMissao == null) throw new EventsException('Para calcular data/hora de fim do voo, o tempo de missão não pode ser nulo');
        if(TempoCorteCliente == null) throw new EventsException('Para calcular data/hora de fim do voo, o tempo de corte do cliente não pode ser nulo');
        Integer DuracaoTotal = TempoMissao + TempoCorteCliente;
        Datetime endDateTime = dataVoo.addMinutes(-TransladoIda).addMinutes(DuracaoTotal);
        return endDateTime;
    }
    
    public void createEvent(
        Voo__c voo,  Calendar calendario, CalculoMissaoResult cmr, Account cliente, Aeronave__c aeronave, fflib_ISObjectUnitOfWork uow)
    {
        Integer TransladoIda = Integer.valueOf(cmr.tempoTransladoIda != null ? cmr.tempoTransladoIda : 0);
        if(voo.Trechos__r != null && voo.Trechos__r.size() > 0 && voo.Trechos__r[0].Tipo__c == 'Translado')
        {
            if(cmr != null && cmr.trechos != null && cmr.trechos.size() > 0 && cmr.trechos[0].tempoMissao != null)
            {
                TransladoIda = Integer.valueOf(cmr.trechos[0].tempoMissao);
            }
        }
        Integer TransladoVolta = Integer.valueOf(cmr.tempoTransladoRetorno != null ? cmr.tempoTransladoRetorno : 0);
        Integer TempoCruzeiro = Integer.valueOf(cmr.tempoCruzeiro != null ? cmr.tempoCruzeiro : 0);
        Integer TempoSolo = Integer.valueOf(cmr.tempoSolo != null ? cmr.tempoSolo : 0);
        Integer TempoMissao = Integer.valueOf(cmr.tempoMissao != null ? cmr.tempoMissao : 0);
        Integer TempoCorteCliente = Integer.valueOf(voo.TempoCorteCliente__c != null ? voo.TempoCorteCliente__c : 0);
        Integer DuracaoTotal = TempoMissao + TempoCorteCliente;
        Datetime activyDatetime = calculeDatetimeStartEvent(voo.DataVoo__c, TransladoIda);
        
        List<Event> eventAndEntreVooEvent = new List<Event>();
        String clienteName = cliente != null && cliente.Name != null ? cliente.Name : '';
        Event event = new Event(Subject = aeronave.Name + ' - ' + clienteName + ' - ' + voo.RotaAbreviada__c,
                                OwnerId = calendario.Id,
                                ActivityDateTime = activyDatetime,
                                DurationInMinutes = DuracaoTotal,
                                WhatId = voo.Id,
                                Voo__c = voo.Id,
                                TransladoIda__c = TransladoIda,
                                TransladoVolta__c = TransladoVolta,
                                TempoCruzeiro__c = TempoCruzeiro,
                                TempoCorteCliente__c = TempoCorteCliente,
                                TempoSolo__c = TempoSolo,
                                RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Voo').getRecordTypeId());
        eventAndEntreVooEvent.add(event);
        
        eventAndEntreVooEvent.add(createEntreVoosEvent(calendario.Id, voo.DataVoo__c.addMinutes(-TransladoIda), voo, Label.Pre));
        eventAndEntreVooEvent.add(createEntreVoosEvent(calendario.Id, voo.DataVoo__c.addMinutes(DuracaoTotal - TransladoIda), voo, Label.Pos));
        
        if(String.isNotBlank(event.OwnerId) && String.isNotBlank(event.WhatId))
            uow.registerNew(eventAndEntreVooEvent);
    }
    
    public void deleteEventRelatedToVoos(List<Voo__c> voos, fflib_ISObjectUnitOfWork uow)
    {
        for(Voo__c voo : voos) deleteEventRelatedToVoo(voo, uow);
    }
    
    public void deleteEventRelatedToVoo(Voo__c voo, fflib_ISObjectUnitOfWork uow)
    {
        List<Event> eventsToDelete = new List<Event>();
        for(Event e : (List<Event>) records)
        {
            if(voo != null && String.isNotBlank(voo.Id) && voo.Id.equals(e.WhatId) && !e.isChild)
            {
                e.ByPassDeleteRules__c = true;
                eventsToDelete.add(e);
            }
        }
        uow.registerDirty(eventsToDelete);
    }
    
    // Deletar um evento do voo
    public void deleteEventRelatedToVoo(
        Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList, fflib_ISObjectUnitOfWork uow)
    {
        List<Event> eventsToDelete = new List<Event>();
        
        List<List<Event>> ell = new List<List<Event>>();
        ell.add(entreVoosPreEventList);
        ell.add(eventList);
        ell.add(entreVoosPosEventList);
        
        for(List<Event> eList : ell) {
            for(Event event : eList) {
                if(voo.Id.equals(event.WhatId) && !event.isChild) {
                    event.ByPassDeleteRules__c = true;
                    eventsToDelete.add(event);
                }
            }
        }
        // Ao atualizar, no after update, é analisado o ByPassDeleteRules, e se estiver true, os eventos são deletados
        uow.registerDirty(eventsToDelete);
        //uow.registerDeleted(eventsToDelete);
    }
    
    public Event createEntreVoosEvent(Id calendarId, Datetime data, Voo__c voo, String tipo)
    {
        Datetime activityDateTime = null;
        Integer durationInMinutes = 0;
        
        if(tipo.equals(Label.Pre)) {
            Integer tempoPlanejamentoPre = Voos.getTempoPlanejamentoPre(voo);
            // Data em Entre Voos Pré é a data que o voo começa
            activityDateTime = data.addMinutes(-tempoPlanejamentoPre);
            durationInMinutes = tempoPlanejamentoPre;
        } else if(tipo.equals(Label.Pos)) {

            ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo(voo.Tipo__c);

            Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;
            // Data em Entre Voos Pós é a data que o voo começa mais a duração do voo
            activityDateTime = data; 
            durationInMinutes = tempoPlanejamentoPos;
        }
        
        Event eventEntreVoos = new Event(Subject = ENTRE_VOOS_EVENT_SUBJECT,
                                         OwnerId = calendarId,
                                         ActivityDateTime = activityDateTime,
                                         DurationInMinutes = durationInMinutes,
                                         WhatId = voo.Id,
                                         Voo__c = voo.Id,
                                         Type = tipo,
                                         RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('EntreVoos').getRecordTypeId());
        
        return eventEntreVoos;
    }
    
    public Map<Id, List<Event>> getPorAeronave(Map<String, Aeronave__c> aeronavePorNome)
    {
        Map<Id, List<Event>> mapPorAeronave = new Map<Id, List<Event>>();
        for(Event evento : (List<Event>)Records)
        {
            Id aeronaveId = aeronavePorNome.get(evento.OwnerName__c).Id;
            if(mapPorAeronave.containsKey(aeronaveId))
            {
                List<Event> eventos = mapPorAeronave.get(aeronaveId);
                eventos.add(evento);
                mapPorAeronave.put(aeronaveId, eventos);
            }
            else
            {
                List<Event> eventos = new List<Event>();
                eventos.add(evento);
                mapPorAeronave.put(aeronaveId, eventos);
            }
        }
        return mapPorAeronave;
    }
    
    public Boolean checkIfEventIsManutencao(Event event)
    {
        return String.isNotBlank(event.RecordTypeId) && event.RecordTypeId.equals(RECORD_TYPE_MANUTENCAO_EVENT_ID);
    }
    
    public Boolean validateIfDateOfEventEntersInDateOfAnotherEvent(
        Datetime eventStart, Datetime eventEnd, Datetime anotherEventStart, Datetime anotherEventEnd)
    {
        Boolean enter = false;
        if(// Evento avaliado dentro do período do evento existente
            (anotherEventStart <= eventStart && eventEnd <= anotherEventEnd) ||
            // Evento existente dentro do período do evento avaliado
            (eventStart <= anotherEventStart && anotherEventEnd <= eventEnd) ||
            // Evento existente começa antes do evento avaliado e acaba dentro do evento avaliado
            (anotherEventStart < eventStart && eventStart < anotherEventEnd && anotherEventEnd <= eventEnd) ||
            // Evento existente começa dentro do evento avaliado e acaba depois do evento avaliado
            (eventStart < anotherEventStart && anotherEventStart < eventEnd && eventEnd <= anotherEventEnd))
        {
            enter = true;
        }
        return enter;        
    }
    
    public Boolean validateIfEventEntersInAnother(Event eventToValidate, Event anotherEvent)
    {
        // Datas do Evento Avaliado
        Datetime eventStart = eventToValidate.StartDateTime;
        Datetime eventEnd = eventToValidate.EndDateTime;
        // Datas do Evento Recuperado do Calendário
        Datetime anotherEventStart = anotherEvent.StartDateTime;
        Datetime anotherEventEnd = anotherEvent.EndDateTime;
        Boolean enter = false;
        if(validateIfDateOfEventEntersInDateOfAnotherEvent(eventStart, eventEnd, anotherEventStart, anotherEventEnd))
        {
            enter = true;
        }
        // System.debug('Inside?' + enter + '\n' + eventStart + '\n' + eventEnd + '\n' + anotherEventStart + '\n' + anotherEventEnd);
        return enter;
    }
    
    public Boolean validateEventManutencao(Event event, List<Event> calendarEvents)
    {
        Boolean valid = true;
        // Lista de Eventos de qualquer Tipo de Registro referente ao Calendário do Evento avaliado
        for (Event calendarEvent : calendarEvents)
        {
            Boolean calendarEventEnterInAnother = validateIfEventEntersInAnother(event, calendarEvent) && calendarEvent.RecordTypeId != RECORD_TYPE_MANUTENCAO_EVENT_ID;
            if(// Insert, o evento avaliado não possui Id
                (String.isBlank(event.Id) ||
                 /*
                * Update, o evento avaliado possui Id e é recuperado com a lista de eventos do calendário
                * Tem que ter Id diferente do Evento avaliado
                */
                 (String.isNotBlank(event.Id) && !event.Id.equals(calendarEvent.Id))) &&
                 calendarEventEnterInAnother)
            {
                valid = false;
            }
        }
        return valid;
    }
    
    public override void onBeforeDelete()
    {
       	List<FeedItem> posts = new List<FeedItem>();
        
        for (Event e : (List<Event>)records)
        {
            //System.debug(e.ByPassDeleteRules__c);
            if(String.isNotBlank(e.RecordTypeId) &&
               (e.RecordTypeId.equals(RECORD_TYPE_VOO_EVENT_ID) || e.RecordTypeId.equals(RECORD_TYPE_ENTRE_VOOS_EVENT_ID)) &&
               String.isNotBlank(e.WhatId) && !e.ByPassDeleteRules__c
              )
            {
                e.addError(Label.ErroExclusaoVooEntreVooComVooExistente);
            }
            else if (String.isNotBlank(e.RecordTypeId) && e.RecordTypeId.equals(RECORD_TYPE_MANUTENCAO_EVENT_ID))
            {
                posts.add(createFeedItem(e));
            }
        }
        
        insert posts;
    }
    
    private FeedItem createFeedItem(Event e)
    {
        return new FeedItem(
            ParentId = ConfiguracoesGerais__c.getOrgDefaults().IdChatterGrupoComercial__c,
            Body = Label.ChatterManutencaoExcluidaCorpo,
            Title = e.OwnerName__c,
            LinkUrl = '/lightning/r/Aeronave__c/' + e.WhatId + '/view'
        );
    }
    
    public override void onBeforeInsert()
    {
        //System.debug('Events - Before Insert');
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Integer IntervaloEmDiasBuscaEventos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().IntervaloEmDiasBuscaEventos__c);
        Datetime smallerDate = retrieveSmallerDateFromRecords();
        smallerDate = smallerDate != null ? Datetime.newInstance(smallerDate.date(), Time.newInstance(0, 0, 0, 0)).addDays(-IntervaloEmDiasBuscaEventos) : null;
        Datetime biggerDate = retrieveBiggerDateFromRecords();
        biggerDate = biggerDate != null ? Datetime.newInstance(biggerDate.date(), Time.newInstance(23, 59, 0, 0)).addDays(IntervaloEmDiasBuscaEventos) : null;
        
        Set<Id> calendarSetId = Utils.getSetIds(records, 'OwnerId');
        List<Event> calendarEvents = EventsSelector.newInstance().selectEventsByOwnerId(calendarSetId, smallerDate, biggerDate);
        List<Aeronave__c> aeronaves = AeronavesSelector.newInstance().selectAll();
        Map<String, Aeronave__c> aeronaveMapByName = new Map<String, Aeronave__c>();
        for(Aeronave__c a : aeronaves) aeronaveMapByName.put(a.Name, a);
        
        for(Event event : (List<Event>) records)
        {
            // Se possui Tipo de Registro, e é do tipo Manutenção
            if(checkIfEventIsManutencao(event))
            {
                if(!validateEventManutencao(event, calendarEvents))
                {
                    event.StartDateTime.addError(Label.ErroConflitoHorarioEvento);
                }
                fillWhatIdInEventManutencao(event, aeronaveMapByName);
            }
        }
        
        uow.commitWork();
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        //System.debug('Events - Before Update');
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Datetime smallerDate = retrieveSmallerDateFromRecords();
        smallerDate = smallerDate != null ? Datetime.newInstance(smallerDate.date(), Time.newInstance(0, 0, 0, 0)).addDays(-15) : null;
        Datetime biggerDate = retrieveBiggerDateFromRecords();
        biggerDate = biggerDate != null ? Datetime.newInstance(biggerDate.date(), Time.newInstance(23, 59, 0, 0)).addDays(15) : null;
        
        Set<Id> calendarSetId = Utils.getSetIds(records, 'OwnerId');
        List<Event> calendarEvents = EventsSelector.newInstance().selectEventsByOwnerId(calendarSetId, smallerDate, biggerDate);
        
        for(Event event : (List<Event>) records)
        {
            // Se possui Tipo de Registro, e é do tipo Manutenção
            if(checkIfEventIsManutencao(event))
            {
                if(!validateEventManutencao(event, calendarEvents) &&
                   (!event.Cancelado__c || (event.Cancelado__c && ((Event)existingRecords.get(event.Id)).Cancelado__c)))
                {
                    event.StartDateTime.addError(Label.ErroConflitoHorarioEvento);
                } else if(event.Cancelado__c && validateEventManutencao(event, calendarEvents))
                {
                    event.Cancelado__c = false;
                }
            }
        }
        uow.commitWork();
    }
    
    public override void handleAfterInsert()
    {
    	/*if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isCreateable()) 
    	   throw new DomainException('Permission to create an ' + SObjectDescribe.getName() + ' denied.');*/
    	   
    	onValidate();
    	onAfterInsert(); 
    }
    public override void handleAfterDelete() 
    {
    	/*if(Configuration.EnforcingTriggerCRUDSecurity && !SObjectDescribe.isDeletable())
    	   throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' denied.');*/
    	   
    	onAfterDelete();
    }
    
    @InvocableMethod(label='Event - Deleta Eventos do Tipo Voo/Entre Voos' description='Deleta eventos do tipo Voo e Entre Voos que forem definidos com ByPassValidationRule__c = true')
    public static void deleteEventsByDeleteByPassValidationRule(List<Id> eventsIdList)
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Event> eventsToDelete = new List<Event>();
        for(Id i : eventsIdList)
        {
            Event event = new Event(Id=i);
            eventsToDelete.add(event);
        }
        uow.registerDeleted(eventsToDelete);
        uow.commitWork();
    }
    
    public Datetime retrieveSmallerDateFromRecords() {
        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo('');
        Integer tempoPlanejamentoPre = entreVoos.entreVoosPre;
        Datetime smallerDate = null;
        for(Event e : (List<Event>) records) {
            if(smallerDate == null && e.StartDateTime != null) smallerDate = e.StartDateTime.addMinutes(-tempoPlanejamentoPre);
            else if(e.StartDateTime != null && e.StartDateTime < smallerDate) smallerDate = e.StartDateTime.addMinutes(-tempoPlanejamentoPre);
        }
        return smallerDate;
    }
    
    public Datetime retrieveBiggerDateFromRecords() {
        ConfiguracaoTempoSelector.ConfiguracaoTempo entreVoos = new ConfiguracaoTempoSelector().getEntrevoosPorTipoVoo('');
        Integer tempoPlanejamentoPos = entreVoos.entreVoosPos;
        Datetime biggerDate = null;
        for(Event e : (List<Event>) records) {
            if(biggerDate == null && e.EndDateTime != null) biggerDate = e.EndDateTime.addMinutes(tempoPlanejamentoPos);
            else if(e.EndDateTime != null && e.EndDateTime > biggerDate) biggerDate = e.EndDateTime.addMinutes(tempoPlanejamentoPos);
        }
        return biggerDate;
    }
    
    private void fillWhatIdInEventManutencao(Event e, Map<String, Aeronave__c> aeronaveMapByName)
    {
        if(checkIfEventIsManutencao(e) && String.isNotBlank(e.OwnerName__c))
        {
            e.WhatId = aeronaveMapByName.get(e.OwnerName__c).Id;
        }
    }
}