@isTest
public class InteressadosSelectorTest {
    @testSetup
    public static void setup()
    {
        //fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        //TestUtil2.criarVooRascunho(System.today()+1, true, uow);
        //uow.commitWork();
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVooComTrechoEPassageiro('nome', 'email@email.com', 'Rascunho', 'Não Iniciado');
        // Assegure que TestUtil.createAccount preenche BillingCountry, BillingCity, BillingPostalCode e CNPJCPF__c
    }
    
    @isTest
    static void selectorTest()
    {
        Test.startTest();
        Set<Id> idSet = Utils.getSetIds((List<SObject>) [SELECT Id FROM Interessado__c], 'Id');
        Set<Id> voosIds = Utils.getSetIds((List<SObject>) [SELECT Id FROM Voo__c], 'Id');
        System.assert(InteressadosSelector.newInstance().selectById(idSet).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectConclusaoTrechoByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectConclusaoVooByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectEmissaoEmbarqueByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectFaturamentoByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectReservaByVoo(voosIds).size() > 0);
        System.assert(InteressadosSelector.newInstance().selectTakeOffReportByVoo(voosIds).size() > 0);
        Test.stopTest();
    }
}