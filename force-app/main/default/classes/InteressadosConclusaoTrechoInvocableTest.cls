@isTest
public class InteressadosConclusaoTrechoInvocableTest {
    @testSetup
    public static void setup()
    {
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVooComTrechoEPassageiro('nome', 'email@email.com', 'Rascunho', 'Não Iniciado');
    }
    
    @isTest
    static void conclusaoTrechoTest()
    {
        Try
        {
            List<Id> voosIds = Utils.getListIds((List<SObject>) [SELECT Id FROM Voo__c ORDER BY Id DESC LIMIT 1], 'Id');
            InteressadosConclusaoTrechoInvocable.conclusaoTrecho(voosIds);
            System.assert(true);
        } catch(Exception e)
        {
			System.assert(false, 'Something goes wrong with conclusaoTrechoTest' +
                         '\nMessage: ' + e.getMessage() + '\nCause: ' + e.getCause() + '\nStacktrace: ' + e.getStackTraceString());
        }
    }

}