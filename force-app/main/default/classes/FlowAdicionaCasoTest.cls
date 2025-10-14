@IsTest
public class FlowAdicionaCasoTest {
  @IsTest
  static void test() {
    Account acc = TestFactory.createBusinessAccount('Account Name');
    acc.BillingCountry = 'Brasil';
    acc.BillingCity = 'São Paulo';
    acc.BillingPostalCode = '12345-678';
    acc.CNPJCPF__c = '11.444.777/0001-61';
    acc.BillingStreet = 'Rua Teste, 123';
    insert acc;

    Tabulacao__c tabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    insert tabulacao;

    Test.startTest();

    FlowAdicionaCaso.FlowAdicionaCasoChamada chamada = new FlowAdicionaCaso.FlowAdicionaCasoChamada();
    chamada.recordIds = new List<Id>{ acc.Id };
    chamada.idTabulacoes = new List<Id>{ tabulacao.Id };
    chamada.lastCaseIds = new List<Id>();
    chamada.applyAssignmentRules = true;

    FlowAdicionaCaso.FlowAdicionaCasoResultado resultado = FlowAdicionaCaso.executar(
      new List<FlowAdicionaCaso.FlowAdicionaCasoChamada>{ chamada }
    )[0];

    Assert.areEqual(1, resultado.idCases.size());

    Test.stopTest();
  }
}