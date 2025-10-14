@IsTest
public class Case360HighlightCardControllerTest {
  @IsTest
  static void getAccountDetails() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    insert newAccount;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      newAccount.Id,
      null
    );
    insert newProtocolo;

    Test.startTest();

    Account acc = Case360HighlightCardController.getAccountDetails(
      newProtocolo.Id
    );
    Assert.isNotNull(acc);

    Test.stopTest();
  }

  @IsTest
  static void getContactBusinessAccountDetails() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    insert newAccount;

    Contact newContact = TestFactory.createContact(newAccount.Id, 'LastName');
    newContact.Email = 'contato@email.com';
    insert newContact;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      newAccount.Id,
      newContact.Id
    );
    insert newProtocolo;

    Test.startTest();

    Contact ct = Case360HighlightCardController.getContactDetails(
      newProtocolo.Id
    );
    Assert.isNotNull(ct);

    Test.stopTest();
  }

  @IsTest
  static void getContactPersonAccountDetails() {
    Account newAccount = TestFactory.createPersonAccount('Account', 'Name');
    insert newAccount;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      newAccount.Id,
      null
    );
    insert newProtocolo;

    Test.startTest();

    Contact ct = Case360HighlightCardController.getContactDetails(
      newProtocolo.Id
    );
    Assert.isNotNull(ct);

    Test.stopTest();
  }

  @IsTest
  static void getHumorClienteWithoutCases() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    insert newAccount;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      newAccount.Id,
      null
    );
    insert newProtocolo;

    Test.startTest();

    Decimal nota = Case360HighlightCardController.getHumorCliente(
      newProtocolo.Id
    );
    Assert.areEqual(newAccount.SomaNota__c, null);

    Test.stopTest();
  }

  @IsTest
  static void getHumorClienteWithCases() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    insert newAccount;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      newAccount.Id,
      null
    );
    insert newProtocolo;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    Test.startTest();

    Decimal notaAntes = Case360HighlightCardController.getHumorCliente(
      newProtocolo.Id
    );
    Assert.areEqual(newAccount.SomaNota__c, null);

    newCase.DataAlteracaoNivelEstresse__c = DateTime.now();
    newCase.Nota__c = 1;
    update newCase;

    Decimal notaDepois = Case360HighlightCardController.getHumorCliente(
      newProtocolo.Id
    );
    Assert.areEqual(1, newCase.Nota__c);

    Test.stopTest();
  }
}