global with sharing class EventsService {
    @TestVisible
    private static IEventsService service()
    {
        return (IEventsService) Application.Service.newInstance(IEventsService.class);
    }
    
    public static Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave) {
        return service().podeExecutarVoo(calculo, data, eventosDaAeronave);
    }
    
    public static Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave, Voo__c voo) {
        return service().podeExecutarVoo(calculo, data, eventosDaAeronave, voo);
    }
    
    public static Map<Datetime, List<Event>> getEventosPorData(Set<Datetime> datas, List<Event> eventos) {
        return service().getEventosPorData(datas, eventos);
    }
    
    public static void createEvent(
        Voo__c voo, Calendar calendario, CalculoMissaoResult cmr, Account cliente, Aeronave__c aeronave, fflib_ISObjectUnitOfWork uow)
    {
        service().createEvent(voo, calendario, cmr, cliente, aeronave, uow);
    }
    
    public static Map<Id, List<Event>> getEventosComAeronaves(Map<Id, List<Event>> eventosPorAeronave, Set<Id> aeronavesSet)
    {
        return service().getEventosComAeronaves(eventosPorAeronave, aeronavesSet);
    }
    
    public static void deleteEventRelatedToVoos(List<Voo__c> voos, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow)
    {
        service().deleteEventRelatedToVoos(voos, eventSet, uow);
    }
    
    public static void deleteEventRelatedToVoo(Voo__c voo, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow)
    {
        service().deleteEventRelatedToVoo(voo, eventSet, uow);
    }
    
    public static void deleteEventRelatedToVoo(
        Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList, fflib_ISObjectUnitOfWork uow)
    {
        service().deleteEventRelatedToVoo(voo, entreVoosPreEventList, eventList, entreVoosPosEventList, uow);
    }
    @AuraEnabled
    public static List<Event> getManutencaoEventTypeByWhatIdsAndDates(List<String> whatIds, String reportDate)
    {
        Datetime menorData = Datetime.valueof(reportDate+' 00:00:00.000');
        Datetime maiorData = menorData.addDays(7).addHours(24);
        return service().getManutencaoEventTypeByWhatIdsAndDates(whatIds, menorData, maiorData);
    }
}