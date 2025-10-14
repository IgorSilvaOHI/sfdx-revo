@isTest
private class AccountsSelectorTest {
	@TestSetup
    private static void Setup() {
        Account acc = TestUtil.createAccount('A firma', true);
        insert acc;
    }
    
    @isTest
    private static void getSObjectFieldListTest() {
        Test.startTest();
        System.assert(new AccountsSelector().getSObjectFieldList().size() > 0,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'getSObjectFieldList\'\n'
                      + new AccountsSelector().getSObjectFieldList());
        Test.stopTest();
    }
    
    @isTest
    private static void selectByIdTest() {
        List<Account> accountMap = [SELECT Id, Name FROM Account];
        Test.startTest();
        List<Account> accountList = AccountsSelector.newInstance().selectById(new Set<Id> {accountMap[0].id});
        System.assert(accountList.size() > 0,
                      'Algo não correu bem.\nClasse: \'AeronavesSelector\'' + '\nFunção:\'selectById\'\n'
                      + accountList);
        Test.stopTest();
    }
    
    @isTest
    private static void selectAllTest()
    {
        List<Account> accs = [SELECT Id FROM Account];
        Test.startTest();
        List<Account> accs2 = AccountsSelector.newInstance().selectAll();
        Test.stopTest();
        
        System.assertEquals(accs.size(), accs2.size());
    }
    
    @isTest
    private static void selectByNameTest()
    {
        List<Account> accs = [SELECT Id, Name FROM Account];
        Test.startTest();
        List<Account> accs2 = AccountsSelector.newInstance().selectByName(new Set<String>{accs[0].Name});
        Test.stopTest();
        
        System.assertEquals(accs[0].Id, accs2[0].Id);
    }
}