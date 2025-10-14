@IsTest
public class TabulacaoSelectorTest {
  @IsTest
  static void selectId() {
    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Change Product',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    TabulacaoSelector selector = new TabulacaoSelector();

    Test.startTest();

    Tabulacao__c tabulacao = (Tabulacao__c) selector.SelectId(newTabulacao.Id);
    Assert.areNotEqual(null, newTabulacao);

    Test.stopTest();
  }

  @IsTest
  static void findWorkflow() {
    Tabulacao__c newTabulacao = TestFactory.createTabulacao(
      'Change Product',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert newTabulacao;

    TabulacaoSelector selector = new TabulacaoSelector();

    Test.startTest();

    Test.setFixedSearchResults(new List<Id>{ newTabulacao.Id });

    List<Tabulacao__c> tabulacoes = (List<Tabulacao__c>) selector.FindFluxoDeTrabalho(
      'Product',
      'Cliente - Pessoa Jurídica',
      false
    );
    Assert.areEqual(1, tabulacoes.size());

    Test.stopTest();
  }
}