@IsTest
public with sharing class CriacaoRapidaOportunidadeControllerTest {
    
    @TestSetup
    static void setup(){
        Id standardPricebookId = TestUtil.SetupStandardPricebook();

        insert TestUtil.createAccount('Pablo');
    }

    @isTest
    static void criarOportunidade(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
        CriacaoRapidaOportunidadeController.CriacaoRapidaWrapper criacaoRapidaWrapper = new CriacaoRapidaOportunidadeController.CriacaoRapidaWrapper();
        criacaoRapidaWrapper.idConta = acc.Id;
        criacaoRapidaWrapper.fullName = 'nome';
        criacaoRapidaWrapper.oppotunityType = 'Oportunidade';
        criacaoRapidaWrapper.idCodigoPromocional = null;

        CriacaoRapidaOportunidadeController.Criar(new List<CriacaoRapidaOportunidadeController.CriacaoRapidaWrapper>{criacaoRapidaWrapper});
        Test.stopTest();

        List<Opportunity> oportunidades = [SELECT Id, Name FROM Opportunity ];
        System.assert(oportunidades.size() == 1, 'Oportunidade não criada');
    }
}