@isTest
public class InteressadosConclusaoVooInvocableTest {
    @testSetup
    public static void setup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVooComTrechoEPassageiro('nome', 'email@email.com', 'Rascunho', 'Não Iniciado');
        // Assegure que TestUtil.createAccount preenche BillingCountry, BillingCity, BillingPostalCode e CNPJCPF__c
    }
    
    @isTest
    static void conclusaoVooTest()
    {
        Try
        {
            List<Id> voosIds = Utils.getListIds((List<SObject>) [SELECT Id FROM Voo__c ORDER BY Id DESC LIMIT 1], 'Id');
            InteressadosConclusaoVooInvocable.conclusaoVoo(voosIds);
            System.assert(true);
        } catch(Exception e)
        {
			System.assert(false, 'Something goes wrong with conclusaoVooTest' +
                         '\nMessage: ' + e.getMessage() + '\nCause: ' + e.getCause() + '\nStacktrace: ' + e.getStackTraceString());
        }
    }
}