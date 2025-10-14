@IsTest
public class ProtocoloSelectorTest {
  @IsTest
  static void test() {
    Protocolo__c newProtocolo = new Protocolo__c();
    insert newProtocolo;

    ProtocoloSelector selector = new ProtocoloSelector();

    Test.startTest();

    Protocolo__c protocolo = (Protocolo__c) selector.SelectId(newProtocolo.Id);
    Assert.areNotEqual(null, protocolo);

    Test.stopTest();
  }
}