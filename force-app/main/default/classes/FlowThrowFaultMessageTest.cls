@IsTest
public class FlowThrowFaultMessageTest {
  public testMethod static void test() {
    try {
      FlowThrowFaultMessage.throwMessage(new List<String>{ 'Test' });

      Assert.fail();
    } catch (Exception e) {
      Assert.areEqual('Test', e.getMessage());
    }
  }
}