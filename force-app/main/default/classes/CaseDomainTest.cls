@IsTest
public class CaseDomainTest {

    @IsTest
    static void test() {
        Account acc = TestFactory.createBusinessAccount('Account Name');
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

        FlowAdicionaCaso.FlowAdicionaCasoChamada chamada1 = new FlowAdicionaCaso.FlowAdicionaCasoChamada();
        chamada1.recordIds = new List<Id>{ acc.Id };
        chamada1.idTabulacoes = new List<Id>{ tabulacao.Id };
        chamada1.lastCaseIds = new List<Id>{ null };
        chamada1.applyAssignmentRules = true;

        FlowAdicionaCaso.FlowAdicionaCasoResultado resultado1 = FlowAdicionaCaso.executar(
            new List<FlowAdicionaCaso.FlowAdicionaCasoChamada>{ chamada1 }
        )[0];

        System.assertEquals(1, resultado1.idCases.size());

        FlowAdicionaCaso.FlowAdicionaCasoChamada chamada2 = new FlowAdicionaCaso.FlowAdicionaCasoChamada();
        chamada2.recordIds = new List<Id>{ resultado1.idCases[0] };
        chamada2.idTabulacoes = new List<Id>{ tabulacao.Id };
        chamada2.lastCaseIds = new List<Id>{ resultado1.idCases[0] };
        chamada2.applyAssignmentRules = true;

        FlowAdicionaCaso.FlowAdicionaCasoResultado resultado2 = FlowAdicionaCaso.executar(
            new List<FlowAdicionaCaso.FlowAdicionaCasoChamada>{ chamada2 }
        )[0];

        System.assertEquals(1, resultado2.idCases.size());

        Test.stopTest();
  }
}