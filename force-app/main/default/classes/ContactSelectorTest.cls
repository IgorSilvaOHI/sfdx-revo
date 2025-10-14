@IsTest
public class ContactSelectorTest {
  @IsTest
  static void test() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    newAccount.BillingCountry = 'Brasil';
    newAccount.BillingCity = 'São Paulo';
    newAccount.BillingPostalCode = '12345-678';
    newAccount.CNPJCPF__c = '11.444.777/0001-61';
    newAccount.BillingStreet = 'Rua Teste, 123';
    newAccount.Email__c = 'teste@email.com';
    insert newAccount;

    Contact newContact = TestFactory.createContact(newAccount.Id, 'Last Name');
    newContact.Email = 'contato@email.com';
    insert newContact;

    ContactSelector selector = new ContactSelector();

    Test.startTest();

    Contact ct = (Contact) selector.SelectId(newContact.Id);
    Assert.areNotEqual(null, ct);

    Test.stopTest();
  }
}