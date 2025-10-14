@IsTest
public class CaseSelectorTest {
  @IsTest
  static void test() {
    Case newCase = TestFactory.createCaseWorkflow();
    insert newCase;

    CaseSelector selector = new CaseSelector();

    Test.startTest();

    Case cs = (Case) selector.SelectId(newCase.Id);
    Assert.areNotEqual(null, cs);

    Test.stopTest();
  }
}