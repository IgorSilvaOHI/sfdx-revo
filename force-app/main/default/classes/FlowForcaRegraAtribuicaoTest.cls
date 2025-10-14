@IsTest
public class FlowForcaRegraAtribuicaoTest {
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

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      tabulacao.Id,
      acc.Id
    );

    Test.startTest();

    FlowForcaRegraAtribuicao.executar(new List<Id>{ newCase.Id });

    Test.stopTest();
  }
}