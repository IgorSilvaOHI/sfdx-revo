public interface IPrioridadeMalhaSelector {

    List<PrioridadeMalha__c> aeronavesPorPriridadeMalha(Id malhaId);
    Map<Id,List<PrioridadeMalha__c>> aeronavesPorPriridadeMalhas(Set<Id> malhaIds);

}