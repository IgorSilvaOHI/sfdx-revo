trigger VoosTrigger on Voo__c (
	after delete, after insert, after update, before delete, before insert, before update) 
{
    // Instancia a domain e chama o método overridable de acordo com o estado da trigger
	fflib_SObjectDomain.triggerHandler(Voos.class);
}