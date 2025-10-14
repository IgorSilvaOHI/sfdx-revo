public class Case360HighlightCardController {
  @AuraEnabled
  public static Account getAccountDetails(String recordId) {
    ProtocoloSelector protocoloSelector = new ProtocoloSelector();

    Id accountId = ((Protocolo__c) protocoloSelector.SelectId(recordId))
      .Conta__c;

    AccountSelector accountSelector = new AccountSelector();

    return (Account) accountSelector.SelectId(accountId);
  }

  @AuraEnabled
  public static Contact getContactDetails(String recordId) {
    ProtocoloSelector protocoloSelector = new ProtocoloSelector();
    Protocolo__c protocolo = (Protocolo__c) protocoloSelector.SelectId(
      recordId
    );

    AccountSelector accountSelector = new AccountSelector();
    Account acc = (Account) accountSelector.SelectId(protocolo.Conta__c);

    Id recTypePJ = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('ClientePJ')
      .getRecordTypeId();

    Id recTypePF = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('ClientePF')
      .getRecordTypeId();

    ContactSelector contactSelector = new ContactSelector();

    if (acc.RecordTypeId == recTypePJ) {
      return (Contact) contactSelector.SelectId(protocolo.Contato__c);
    } else if (acc.RecordTypeId == recTypePF) {
      List<Contact> contacts = (List<Contact>) contactSelector.SelectWhereId(
        'AccountId',
        protocolo.Conta__c
      );

      return !contacts.isEmpty() ? contacts[0] : null;
    }

    return null;
  }

  @AuraEnabled(cacheable=false)
  public static Double getHumorCliente(String recordId) {
    ProtocoloSelector protocoloSelector = new ProtocoloSelector();

    Id accountId = ((Protocolo__c) protocoloSelector.SelectId(recordId))
      .Conta__c;

    AccountSelector accountSelector = new AccountSelector();

    Account cliente = (Account) accountSelector.SelectId(accountId);

    Boolean condicao = verificaDataAlteracaoHumor(accountId);

    if (condicao) {
      return null;
    } else {
      return cliente.SomaNota__c;
    }
  }

  @AuraEnabled
  public static Boolean verificaDataAlteracaoHumor(String accountId) {
    CaseSelector caseSelector = new CaseSelector();

    List<Case> lstCases = (List<Case>) caseSelector.SelectWhereId(
      'AccountId',
      accountId
    );

    Double somaNota = 0;

    for (Case caso : lstCases) {
      if (
        DateTime.now() - 60 > caso.DataAlteracaoNivelEstresse__c ||
        caso.DataAlteracaoNivelEstresse__c == null
      ) {
        caso.Nota__c = null;
      } else {
        if (caso.Nota__c == 0) {
          somaNota += 1;
        } else {
          somaNota += caso.Nota__c;
        }
      }
    }

    if (somaNota > 0 || somaNota < 0) {
      return false;
    } else {
      AccountSelector accountSelector = new AccountSelector();

      Account cliente = (Account) accountSelector.SelectIdForUpdate(accountId);

      cliente.SomaNota__c = null;

      update cliente;

      return true;
    }
  }
}