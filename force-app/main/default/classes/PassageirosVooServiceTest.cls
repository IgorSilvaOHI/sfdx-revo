@IsTest
public class PassageirosVooServiceTest {
    
    @isTest
	public static void getPassageirosVooTest()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.create1Voo2Locais2Trechos2Passageiros();
        List<Contact> contatos = [SELECT Id FROM Contact];
        List<Voo__c> voo = [SELECT Id FROM Voo__c];
        PassageiroVoo__c passageiro = new PassageiroVoo__c(Contato__c = contatos.get(0).Id, Voo__c = voo.get(0).Id);
        insert passageiro;
        
        Test.startTest();
        String serviceResult = PassageirosVooService.getPassageirosVoo(voo.get(0).Id);
        system.assert(serviceResult.length() > 0);
        Test.stopTest();
        //inserir conta
        ////inserir voo
        //inserir contato
        //inserir passageiros voo
    }
}