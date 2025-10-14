@isTest
private class VooSelectorTest {
    @TestSetup
    static void Setup(){
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVoo('Fernando', 'test@gmail.com', 'Rascunho');
    }

    @isTest
    static void getVooByIdTest() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();

        voo = VooSelector.getVooById(voo.Id);
        System.assert(
            voo.Status__c == 'Rascunho' && voo.DataVoo__c != null && voo.Cliente__c == acc.Id,
            'Algo não correu bem.\nClasse: \'VooSelector\''
            + '\nFunção:\'getVooById\'\n'
            + acc + '\n' + contact + '\n' + voo);
        Test.stopTest();
    }
}