@IsTest
public class AccountSelectorTest {
  @IsTest
  static void selectId() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name ' + System.now().getTime());
    newAccount.BillingCountry = 'Brasil';
    newAccount.BillingCity = 'São Paulo';
    newAccount.BillingPostalCode = '12345-678';
    newAccount.CNPJCPF__c = '11.444.777/0001-61';
    newAccount.BillingStreet = 'Rua Teste, 123';
    newAccount.Email__c = 'teste@email.com';
    insert newAccount;

    AccountSelector selector = new AccountSelector();

    Test.startTest();

    Account acc = (Account) selector.SelectId(newAccount.Id);
    Assert.areNotEqual(null, acc);

    acc = (Account) selector.SelectId('01pHa000000EJ1L');
    Assert.areEqual(null, acc);

    Test.stopTest();
  }

  @IsTest
  static void selectIn() {
    Account newAccount1 = TestFactory.createBusinessAccount('Account Name 1 ' + System.now().getTime());
    newAccount1.BillingCountry = 'Brasil';
    newAccount1.BillingCity = 'São Paulo';
    newAccount1.BillingPostalCode = '12345-678';
    newAccount1.CNPJCPF__c = '11.444.777/0001-61';
    newAccount1.BillingStreet = 'Rua Teste, 123';
    newAccount1.Email__c = 'teste1@email.com';
    insert newAccount1;

    Account newAccount2 = TestFactory.createBusinessAccount('Empresa 2 =D' + System.now().getTime());
    newAccount2.BillingCountry = 'Brasil';
    newAccount2.BillingCity = 'São Paulo';
    newAccount2.BillingPostalCode = '12345-679';
    newAccount2.CNPJCPF__c = '22.444.777/0001-61';
    newAccount2.BillingStreet = 'Rua Teste, 124';
    newAccount2.Email__c = 'teste2@email.com';
    insert newAccount2;

    AccountSelector selector = new AccountSelector();

    Test.startTest();

    List<Account> accs = (List<Account>) selector.SelectIn(
      new List<Id>{ newAccount1.Id, newAccount2.Id }
    );
    Assert.areEqual(2, accs.size());

    Test.stopTest();
  }

  @IsTest
  static void selectWhereIn() {
    Account newAccount1 = TestFactory.createBusinessAccount('Account Name 1');
    insert newAccount1;

    Account newAccount2 = TestFactory.createBusinessAccount('EMPRESA TESTE');
    newAccount2.CNPJCPF__c = '44.360.966/0001-05';
    newAccount2.BillingCity = 'São Paulo';
    newAccount2.BillingState = 'SP';
    newAccount2.BillingPostalCode = '12313-134';
    newAccount2.BillingCountry = 'Brasil';
    newAccount2.Phone = '11999999999';
    newAccount2.Industry = 'Outros';
    newAccount2.Type = 'Cliente';
    newAccount2.BillingStreet = 'Rua Teste, 123123';
    newAccount2.Email__c = 'asdf@teste.com';
    insert newAccount2;

    AccountSelector selector = new AccountSelector();

    Test.startTest();

    List<Account> accs = (List<Account>) selector.SelectWhereIn(
      'Id',
      new List<Id>{ newAccount1.Id, newAccount2.Id }
    );
    Assert.areEqual(2,  accs.size());

    Test.stopTest();
  }

  @IsTest
  static void selectWhereId() {
    Account newAccount = TestFactory.createBusinessAccount('Account Name');
    insert newAccount;

    AccountSelector selector = new AccountSelector();

    Test.startTest();

    List<Account> accs = (List<Account>) selector.SelectWhereId(
      'Id',
      newAccount.Id
    );
    Assert.areEqual(1, accs.size());

    Test.stopTest();
  }

  @IsTest
  static void selectIdForUpdate() {

    Account newAccount = TestFactory.createBusinessAccount('Account Name ' + System.now().getTime());
    newAccount.BillingCountry = 'Brasil';
    newAccount.BillingCity = 'São Paulo';
    newAccount.BillingPostalCode = '12345-678';
    newAccount.CNPJCPF__c = '11.444.777/0001-61';
    newAccount.BillingStreet = 'Rua Teste, 123';
    newAccount.Email__c = 'teste@email.com';
    insert newAccount;

    AccountSelector selector = new AccountSelector();

    Test.startTest();

    Account acc = (Account) selector.SelectIdForUpdate(newAccount.Id);
    Assert.areNotEqual(null, acc);

    Test.stopTest();
    
  }
}