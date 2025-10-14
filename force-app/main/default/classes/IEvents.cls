public interface IEvents extends fflib_ISObjectDomain
{
    List<Event> getEventByDeveloperName(String recordTypeName);
    List<Event> getEventByDeveloperName(String recordTypeName, String tipo);
    List<Event> getEntreVoos();
    List<Event> getEntreVoos(String tipo);
    List<Event> getManutencao();
    List<Event> getVoo();
    List<Event> groupEventsList(List<List<Event>> eventsToGroup);
    Datetime calculeDatetimeStartEvent(Voo__c voo, CalculoMissaoResult cmr);
    Datetime calculeDatetimeStartEvent(Datetime dataVoo, Integer TransladoIda);
    Datetime calculeDatetimeEndEvent(Voo__c voo, CalculoMissaoResult cmr);
    Datetime calculeDatetimeEndEvent(Datetime dataVoo, Integer TransladoIda, Integer TempoMissao, Integer TempoCorteCliente);
    void createEvent(Voo__c voo,  Calendar calendario, CalculoMissaoResult cmr, Account cliente, Aeronave__c aeronave, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoos(List<Voo__c> voos, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoo(Voo__c voo, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoo(Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList, fflib_ISObjectUnitOfWork uow);
    Event createEntreVoosEvent(Id calendarId, Datetime data, Voo__c voo, String tipo);
    Map<Id, List<Event>> getPorAeronave(Map<String, Aeronave__c> aeronavePorNome);
    Boolean validateIfDateOfEventEntersInDateOfAnotherEvent(Datetime eventStart, Datetime eventEnd, Datetime anotherEventStart, Datetime anotherEventEnd);
    Boolean validateIfEventEntersInAnother(Event eventToValidate, Event existingEvent);
    Boolean checkIfEventIsManutencao(Event event);
    Boolean validateEventManutencao(Event event, List<Event> calendarEvents);
}