@IsTest
public class TestFactory {
  public static Account createBusinessAccount(String name) {
    Account acc = new Account();

    acc.Name = name;
    acc.RecordTypeId = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get('ClientePJ')
      .getRecordTypeId();
    acc.CNPJCPF__c = '11.444.777/0001-61';
    acc.BillingCity = 'São Paulo';
    acc.BillingState = 'SP';
    acc.BillingPostalCode = '12345-678';
    acc.BillingCountry = 'Brasil';
    acc.Phone = '1133334444';
    acc.Industry = 'Outros';
    acc.Type = 'Cliente';
    acc.BillingStreet = 'Rua Teste, 123';
    acc.Email__c = 'teste@email.com';
    return acc;
  }

  public static Account createPersonAccount(String firstName, String lastName) {
    Account acc = new Account();
    String cpf = GeraCpfCnpj.cpf(true);
    acc.put('FirstName', firstName);
    acc.put('LastName', lastName);
    acc.RecordTypeId = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get('ClientePF')
      .getRecordTypeId();
    acc.BillingCity = 'São Paulo';
    acc.BillingState = 'SP';
    acc.BillingPostalCode = '12345-678';
    acc.BillingCountry = 'Brasil';
    acc.BillingStreet = 'Rua Teste, 123';
    acc.CNPJCPF__c = cpf;
    acc.PersonEmail = firstName + '.' + lastName + '@email.com';
    acc.Phone = '1133334444';
    acc.PersonHomePhone = '1133334444';
    acc.put('TipoDocumento__pc', 'CPF');
    acc.put('NumeroDocumento__pc', cpf);
    acc.put('Email__c', firstName + '.' + lastName + '@email.com');

    return acc;
  }

  public static Case createCaseWorkflow() {
    Case cs = new Case();

    cs.RecordTypeId = Schema.getGlobalDescribe()
      .get('Case')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get('FluxoTrabalho')
      .getRecordTypeId();

    return cs;
  }

  public static Contact createContact(Id accountId, String lastName) {
    Contact ct = new Contact();

    ct.AccountId = accountId;
    ct.LastName = lastName;

    return ct;
  }

  public static Tabulacao__c createTabulacao(
    String name,
    String accountType,
    String recTypeDevName,
    Boolean isTabulacaoOculta,
    Boolean isTabulacaoInterna
  ) {
    Tabulacao__c tabulacao = new Tabulacao__c();

    tabulacao.Name = name;
    tabulacao.CodigoAtribuicao__c = 'Atendimento';
    tabulacao.PermiteAtendimento__c = accountType;
    tabulacao.TabulacaoInterna__c = isTabulacaoInterna;
    tabulacao.TabulacaoOculta__c = isTabulacaoOculta;
    tabulacao.RecordTypeId = Schema.getGlobalDescribe()
      .get('Tabulacao__c')
      .getDescribe()
      .getRecordTypeInfosByDeveloperName()
      .get(recTypeDevName)
      .getRecordTypeId();

    return tabulacao;
  }

  public static Protocolo__c createProtocolo(
    String accountId,
    String contactId
  ) {
    Protocolo__c protocolo = new Protocolo__c();

    protocolo.Conta__c = accountId;
    protocolo.Contato__c = contactId;

    return protocolo;
  }
}