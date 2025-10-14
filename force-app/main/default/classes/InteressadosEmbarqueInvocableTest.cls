@isTest
public class InteressadosEmbarqueInvocableTest {
    @testSetup
    public static void setup()
    {
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVooComTrechoEPassageiro('nome', 'email@email.com', 'Rascunho', 'Não Iniciado');
    }
    
    @isTest
    static void embarqueTest()
    {
        Try
        {
            List<Id> voosIds = Utils.getListIds((List<SObject>) [SELECT Id FROM Voo__c ORDER BY Id DESC LIMIT 1], 'Id');
            InteressadosEmbarqueInvocable.embarque(voosIds);
            System.assert(true);
        } catch(Exception e)
        {
			System.assert(false, 'Something goes wrong with reservaTest' +
                         '\nMessage: ' + e.getMessage() + '\nCause: ' + e.getCause() + '\nStacktrace: ' + e.getStackTraceString());
        }
    }
}