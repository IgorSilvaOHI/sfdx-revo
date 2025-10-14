public without sharing class CaseHighLightCardController {
    @AuraEnabled
    public static Account getAccountDetails(String recordId) {
        CaseSelector caseSelector = new CaseSelector();
        
        Case caseRecord = (Case) caseSelector.SelectId(recordId);
        String idConta = caseRecord.AccountId;
        
        AccountSelector accountSelector = new AccountSelector();
        
        return (Account) accountSelector.SelectId(idConta);
    }
    
    @AuraEnabled
    public static Contact getContactDetails(String recordId) {
        CaseSelector caseSelector = new CaseSelector();
        AccountSelector accountSelector = new AccountSelector();
        ContactSelector contactSelector = new ContactSelector();
        
        Case caseRecord = (Case) caseSelector.SelectId(recordId);
        Account conta = (Account)accountSelector.SelectId(caseRecord.AccountId);

        if (conta.IsPersonAccount) {
            return (Contact) contactSelector.SelectId(conta.PersonContactId);
        } else {
            return (Contact) contactSelector.SelectId(caseRecord.ContactId);
        }
    }
    
    @AuraEnabled
    public static Case getCase(String recordId) {
        CaseSelector selector = new CaseSelector();
        
        return (Case) selector.SelectId(recordId);
    }
    
    @AuraEnabled
    public static Case saveHumorCliente(String recordId, Decimal nota) {
        CaseSelector caseSelector = new CaseSelector();
        
        Case caseRecord = (Case) caseSelector.SelectId(recordId);
        
        Decimal notaAnterior = caseRecord.Nota__c;
        
        caseRecord.Nota__c = nota;
        caseRecord.DataAlteracaoNivelEstresse__c = DateTime.now();
        
        AccountSelector accountSelector = new AccountSelector();
        
        Account cliente = (Account) accountSelector.SelectIdForUpdate(
            caseRecord.AccountId
        );
        
        if (cliente.SomaNota__c == null) {
            cliente.SomaNota__c = 0;
        }
        
        if (notaAnterior != null) {
            cliente.SomaNota__c -= notaAnterior;
        }
        
        cliente.SomaNota__c += nota;
        
        update cliente;
        update caseRecord;
        
        HumorConta__e evt = new HumorConta__e();
        evt.Conta__c = cliente.Id;
        
        EventBus.publish(evt);
        
        return caseRecord;
    }
    
    @AuraEnabled
    public static Decimal getNota(String recordId) {
        CaseSelector caseSelector = new CaseSelector();
        
        Case caseRecord = (Case) caseSelector.SelectId(recordId);
        
        return caseRecord.Nota__c;
    }
}