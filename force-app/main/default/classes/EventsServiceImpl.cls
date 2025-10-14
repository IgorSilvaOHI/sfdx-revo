public class EventsServiceImpl implements IEventsService {
    
    static FINAL Id RECORD_TYPE_VOO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.VooRecordTypeName).getRecordTypeId();
    static FINAL Id RECORD_TYPE_MANUTENCAO_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.ManutencaoRecordTypeName).getRecordTypeId();
    static FINAL Id RECORD_TYPE_ENTRE_VOOS_EVENT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(Label.EntreVoosRecordTypeName).getRecordTypeId();
    
    public void createEvent(Voo__c voo, Calendar calendario, CalculoMissaoResult cmr, Account cliente, Aeronave__c aeronave, fflib_ISObjectUnitOfWork uow) {
        Events.newInstance(new List<Event>()).createEvent(voo, calendario, cmr, cliente, aeronave, uow);
    }
    
    public Map<Datetime, List<Event>> getEventosPorData(Set<Datetime> datas, List<Event> eventos)
    {
        Map<Datetime, List<Event>> eventosPorData = new Map<Datetime, List<Event>>();
        for(Datetime data : datas)
        {
            List<Event> eventosData = new List<Event>();            
            for(Event evento : eventos)
            {
                if(evento.StartDateTime <= data && evento.EndDateTime >= data)
                {
                    eventosData.add(evento);
                }
            }
            eventosPorData.put(data, eventosData);
        }
        return eventosPorData;
    }
    
    public void deleteEventRelatedToVoos(List<Voo__c> voos, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow)
    {
        Events.newInstance(new List<Event>(eventSet)).deleteEventRelatedToVoos(voos, uow);
    }
    
    public void deleteEventRelatedToVoo(Voo__c voo, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow)
    {
        Events.newInstance(new List<Event>(eventSet)).deleteEventRelatedToVoo(voo, uow);
    }
    
    public void deleteEventRelatedToVoo(Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList, fflib_ISObjectUnitOfWork uow) {
        Events.newInstance(new List<Event>()).deleteEventRelatedToVoo(voo, entreVoosPreEventList, eventList, entreVoosPosEventList, uow);
    }
    
    public Map<Id, List<Event>> getEventosComAeronaves(Map<Id, List<Event>> eventosPorAeronave, Set<Id> aeronavesSet)
    {
        Map<Id, List<Event>> eventosComAeronaves = new Map<Id, List<Event>>();
        for(Id aeronaveId : eventosPorAeronave.keySet())
        {
            if(aeronavesSet.contains(aeronaveId))
            {
                eventosComAeronaves.put(aeronaveId, eventosPorAeronave.get(aeronaveId));
            }
        }
        return eventosComAeronaves;
    }
    
    public Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave) {

        if(eventosDaAeronave == null || eventosDaAeronave.size() == 0)
        {
            return 1;
        }
        Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
        Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
        
        for(Event evento : eventosDaAeronave) {
            Datetime eventoInicio = evento.StartDateTime;
            Datetime eventoFim = evento.EndDateTime;
            Datetime vooInicio = data.addMinutes(-Integer.valueOf(calculo.tempoTransladoIda));
        	Datetime vooFim = data.addMinutes(Integer.valueOf(calculo.TempoMissao));
            
            if(evento.RecordTypeId == RECORD_TYPE_VOO_EVENT_ID || evento.RecordTypeId == RECORD_TYPE_MANUTENCAO_EVENT_ID)
            {
                vooInicio = vooInicio.addMinutes(-tempoPlanejamentoPre);
                vooFim = vooFim.addMinutes(tempoPlanejamentoPos);
            }
            
            Boolean eventoFimMaiorVooInicio = eventoFim > vooInicio;
            Boolean eventoInicioMenorVooFim = eventoInicio < vooFim;

            if(eventoFimMaiorVooInicio && eventoInicioMenorVooFim)
            {
                if(data >= eventoInicio && data < eventoFim)
                {
                    return 0;
                }
                return -1;
            }
        }
            
        return 1;
    }
    
    public List<Event> getEventosSemVoo(List<Event> eventos, Voo__c voo)
    {
        List<Event> eventosFiltrados = new List<Event>();
        for(Event ev : eventos)
        {
            if(ev.WhatId == null || ev.WhatId != voo.Id)
                eventosFiltrados.add(ev);
        }
        return eventosFiltrados;
    }
    
    public Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave, Voo__c voo) {

        eventosDaAeronave = eventosDaAeronave != null ? getEventosSemVoo(eventosDaAeronave, voo) : eventosDaAeronave;
        if(eventosDaAeronave == null || eventosDaAeronave.size() == 0)
        {
            return 1;
        }
        Integer tempoPlanejamentoPre = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPre__c);
        Integer tempoPlanejamentoPos = Integer.valueOf(ConfiguracaoTempo__c.getOrgDefaults().TempoPlanejamentoPos__c);
        
        for(Event evento : eventosDaAeronave) {
            Datetime eventoInicio = evento.StartDateTime;
            Datetime eventoFim = evento.EndDateTime;
            system.debug('calculo dps'+calculo);
            Datetime vooInicio = data.addMinutes(-Integer.valueOf(calculo.tempoTransladoIda));
        	Datetime vooFim = data.addMinutes(Integer.valueOf(calculo.TempoMissao));
            
            if(evento.RecordTypeId == RECORD_TYPE_VOO_EVENT_ID || evento.RecordTypeId == RECORD_TYPE_MANUTENCAO_EVENT_ID)
            {
                vooInicio = vooInicio.addMinutes(-tempoPlanejamentoPre);
                vooFim = vooFim.addMinutes(tempoPlanejamentoPos);
            }
            
            Boolean eventoFimMaiorVooInicio = eventoFim > vooInicio;
            Boolean eventoInicioMenorVooFim = eventoInicio < vooFim;

            if(eventoFimMaiorVooInicio && eventoInicioMenorVooFim)
            {
                if(data >= eventoInicio && data < eventoFim)
                {
                    return 0;
                }
                return -1;
            }
        }
            
        return 1;
    }

    public List<Event> getManutencaoEventTypeByWhatIdsAndDates(List<String> whatIds, Datetime menorData, Datetime maiorData)
    {
        return EventsSelector.newInstance().selectManutencaoEventTypeByWhatIdsAndDates(whatIds, menorData, maiorData);
    }
}