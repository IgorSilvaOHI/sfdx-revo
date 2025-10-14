@IsTest
public class FlowUtilSplitStringTest {
  @IsTest
  static void test() {
    FlowUtilSplitString.FlowUtilSplitStringChamada chamada = new FlowUtilSplitString.FlowUtilSplitStringChamada();

    chamada.StringToSplit = '1;2;3;4;5';
    chamada.Delimiter = ';';

    Test.startTest();

    List<FlowUtilSplitString.FlowUtilSplitStringResultado> resultados = FlowUtilSplitString.executar(
      new List<FlowUtilSplitString.FlowUtilSplitStringChamada>{ chamada }
    );

    Test.stopTest();

    Assert.areEqual(1, resultados.size());
    Assert.areEqual(5, resultados[0].StringSplitted.size());
  }
}