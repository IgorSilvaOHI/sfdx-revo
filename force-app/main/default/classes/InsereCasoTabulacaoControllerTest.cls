@IsTest
public class InsereCasoTabulacaoControllerTest {
  @IsTest
  static void buscaTabulacaoDiferenteDeCaso() {
    Account acc = TestFactory.createBusinessAccount('Account Name');
    acc.BillingCountry = 'Brasil';
    acc.BillingCity = 'São Paulo';
    acc.BillingPostalCode = '12345-678';
    acc.CNPJCPF__c = '11.444.777/0001-61';
    acc.BillingStreet = 'Rua Teste, 123';
    insert acc;

    Contact ct = TestFactory.createContact(acc.Id, 'LastName');
    ct.Email = 'contato@email.com';
    insert ct;

    Protocolo__c protocolo = TestFactory.createProtocolo(acc.Id, ct.Id);
    insert protocolo;

    Tabulacao__c tabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert tabulacao;

    Test.startTest();

    Test.setFixedSearchResults(new List<Id>{ tabulacao.Id });

    List<Tabulacao__c> tabulacoesConta = InsereCasoTabulacaoController.buscaTabulacao(
      'Troca',
      acc.Id,
      false
    );

    Assert.areEqual(1, tabulacoesConta.size());

    List<Tabulacao__c> tabulacoesContato = InsereCasoTabulacaoController.buscaTabulacao(
      'Troca',
      ct.Id,
      false
    );

    Assert.areEqual(1, tabulacoesContato.size());

    List<Tabulacao__c> tabulacoesProtocolo = InsereCasoTabulacaoController.buscaTabulacao(
      'Troca',
      protocolo.Id,
      false
    );

    Assert.areEqual(1, tabulacoesProtocolo.size());

    Test.stopTest();
  }

  @IsTest
  static void insereCaso() {
    Account acc = TestFactory.createBusinessAccount('Account Name');
    acc.BillingCountry = 'Brasil';
    acc.BillingCity = 'São Paulo';
    acc.BillingPostalCode = '12345-678';
    acc.CNPJCPF__c = '11.444.777/0001-61';
    acc.BillingStreet = 'Rua Teste, 123';
    insert acc;

    Contact ct = TestFactory.createContact(acc.Id, 'LastName');
    ct.Email = 'contato@email.com';
    insert ct;

    Tabulacao__c tabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert tabulacao;

    Test.startTest();

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      tabulacao.Id,
      ct.Id
    );

    Assert.areNotEqual(null, newCase);

    Test.setFixedSearchResults(new List<Id>{ tabulacao.Id });

    List<Tabulacao__c> tabulacoesConta = InsereCasoTabulacaoController.buscaTabulacao(
      'Troca',
      newCase.Id,
      false
    );

    Assert.areEqual(1, tabulacoesConta.size());

    Test.stopTest();
  }

  @IsTest
  static void getAccountType() {
    Contact ct = TestFactory.createContact(null, 'LastName');
    ct.Email = 'contato@email.com';
    insert ct;

    Case cs = new Case();
    insert cs;

    Protocolo__c protocolo = TestFactory.createProtocolo(null, null);
    insert protocolo;

    Test.startTest();

    InsereCasoTabulacaoController.getAccountType('005Ha000001i9a5IAA');
    InsereCasoTabulacaoController.getAccountType(ct.Id);
    InsereCasoTabulacaoController.getAccountType(cs.Id);
    InsereCasoTabulacaoController.getAccountType(protocolo.Id);

    Test.stopTest();
  }
}