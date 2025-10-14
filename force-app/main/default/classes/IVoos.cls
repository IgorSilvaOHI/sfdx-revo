public interface IVoos extends fflib_ISObjectDomain
{   
    Map<Id, Account> retrieveAccountMapFromVooList(List<Voo__c> records);
    Set<Id> retrieveAeronaveSetIdFromRecords(List<Voo__c> records);
    Map<String, Aeronave__c> retrieveNameAeronaveMapFromAeronaveList(List<Aeronave__c> aeronaveList);
    Datetime retrieveSmallerDateFromRecords();
    Datetime retrieveBiggerDateFromRecords();
    Map<Id, Calendar> retrieveCalendarMapByRecords(Set<String> aeronaveSetName, Map<Id, Aeronave__c> aeronaveMap);
    Calendar retrieveCalendarByVooAndCalendarMap(Voo__c voo, Map<Id, Aeronave__c> aeronaveMap, Map<Id, Calendar> calendarMap);
    Boolean verifyExistingEventForVoo(Voo__c voo, List<Event> eventList);
    Boolean checkIfVooStatusIsPreReservado(Voo__c voo);
    Boolean checkIfVooStatusIsReservado(Voo__c voo);
    Boolean checkIfVooStatusIsConfirmado(Voo__c voo);
    
    Boolean checkIfVooHasStatusToCreateUpdateEvent(Voo__c voo);
    Boolean checkVooDataToValidPlanning(Voo__c voo, Voo__c vooOld);
    
    List<Voo__c> validaDelecao(List<Voo__c> voos);
    void handleEventsOnBeforeDelete(List<Voo__c> voos, fflib_ISObjectUnitOfWork uow);
}