@IsTest
public class CaseTabulationMilestoneAssignmentTest {
  @IsTest
  static void test() {
    Tabulacao__c tabulacao = TestFactory.createTabulacao(
      'Suporte > Troca',
      'Cliente - Pessoa Jurídica',
      'FluxoTrabalho',
      false,
      false
    );
    tabulacao.SLAConclusao__c = 12;
    insert tabulacao;

    Protocolo__c protocolo = TestFactory.createProtocolo(null, null);
    insert protocolo;

    Case newCase = InsereCasoTabulacaoController.insereCasoTabulacao(
      tabulacao.Id,
      protocolo.Id
    );

    Test.startTest();

    new CaseTabulationMilestoneAssignment()
      .calculateMilestoneTriggerTime(newCase.Id, null);

    Test.stopTest();
  }
}