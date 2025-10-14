public interface IEventsService {
    void createEvent(Voo__c voo,  Calendar calendario, CalculoMissaoResult cmr, Account cliente, Aeronave__c aeronave, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoos(List<Voo__c> voos, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoo(Voo__c voo, Set<Event> eventSet, fflib_ISObjectUnitOfWork uow);
    void deleteEventRelatedToVoo(Voo__c voo, List<Event> entreVoosPreEventList, List<Event> eventList, List<Event> entreVoosPosEventList, fflib_ISObjectUnitOfWork uow);
    Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave);
    Integer podeExecutarVoo(CalculoMissaoResult calculo, Datetime data, List<Event> eventosDaAeronave, Voo__c voo);
    Map<Id, List<Event>> getEventosComAeronaves(Map<Id, List<Event>> eventosPorAeronave, Set<Id> aeronavesSet);
    Map<Datetime, List<Event>> getEventosPorData(Set<Datetime> datas, List<Event> eventos);
    List<Event> getManutencaoEventTypeByWhatIdsAndDates(List<String> whatIds, Datetime menorData, Datetime maiorData);
}