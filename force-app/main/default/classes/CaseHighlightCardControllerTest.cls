@IsTest
public class CaseHighlightCardControllerTest {
  @IsTest
  static void getAccountDetails() {
    Account acc = TestFactory.createBusinessAccount('Test Account');
    // Se necessário, ajuste campos específicos aqui
    insert acc;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      acc.Id,
      null
    );
    insert newProtocolo;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    Test.startTest();

    Account accDetails = CaseHighlightCardController.getAccountDetails(newCase.Id);
    Assert.isNotNull(accDetails);

    Test.stopTest();
  }

  @IsTest
  static void getContactBusinessAccountDetails() {
    Account acc = TestFactory.createBusinessAccount('Test Account');
    // Se necessário, ajuste campos específicos aqui
    insert acc;

    Contact newContact = TestFactory.createContact(acc.Id, 'LastName');
    newContact.Email = 'contato@email.com';
    insert newContact;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      acc.Id,
      newContact.Id
    );
    insert newProtocolo;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    Test.startTest();

    Contact ct = CaseHighlightCardController.getContactDetails(newCase.Id);
    Assert.isNotNull(ct);

    Test.stopTest();
  }

  @IsTest
  static void getCase() {
    Account acc = TestFactory.createBusinessAccount('Test Account');
    // Se necessário, ajuste campos específicos aqui
    insert acc;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      acc.Id,
      null
    );
    insert newProtocolo;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    Test.startTest();

    CaseHighLightCardController.getCase(newCase.Id);

    Test.stopTest();
  }

  @IsTest
  static void saveHumorCliente() {
    Account acc = TestFactory.createBusinessAccount('Test Account');
    // Se necessário, ajuste campos específicos aqui
    insert acc;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      acc.Id,
      null
    );
    insert newProtocolo;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    Test.startTest();

    Case updatedCase = CaseHighLightCardController.saveHumorCliente(
      newCase.Id,
      2
    );
    Assert.areEqual(2, updatedCase.Nota__c);

    Test.stopTest();
  }

  @IsTest
  static void getNota() {
    Account acc = TestFactory.createBusinessAccount('Test Account');
    // Se necessário, ajuste campos específicos aqui
    insert acc;

    Protocolo__c newProtocolo = TestFactory.createProtocolo(
      acc.Id,
      null
    );
    insert newProtocolo;

    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      newTabulacao.Id,
      newProtocolo.Id
    );

    newCase.Nota__c = 1;
    update newCase;

    Test.startTest();

    CaseHighLightCardController.getNota(newCase.Id);

    Test.stopTest();
  }
}