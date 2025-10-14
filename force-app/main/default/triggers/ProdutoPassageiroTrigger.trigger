trigger ProdutoPassageiroTrigger on ProdutoPassageiro__c (after delete) {
    fflib_SObjectDomain.triggerHandler(ProdutoPassageiros.class);
}