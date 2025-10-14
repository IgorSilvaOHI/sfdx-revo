trigger PassageiroOportunidadeTrigger on PassageiroOportunidade__c (before delete) {

    fflib_SObjectDomain.triggerHandler(PassageiroOportunidades.class);    
}