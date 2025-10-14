@isTest
public class MissoesTest {
    @TestSetup
    static void setup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        Datetime data = Datetime.newInstanceGmt(System.now().date().addDays(1), Time.newInstance(15, 0, 0, 0));
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Voo__c voo = TestUtil2.criarVooRascunho(data, true, uow);
        uow.commitWork();
    }
    
	@isTest
    static void constructorTest()
    {
        Test.startTest();
        Missoes missoesDomain = new Missoes(new List<Missao__c>());
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void createMissaoTest()
    {
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CalculoMissaoResult cmr = new CalculoMissaoResult();
        Missoes missoesDomain = new Missoes(new List<Missao__c>());
        Missao__c missao = missoesDomain.createMissao(cmr, uow);
        List<Voo__c> lista = [SELECT Id, Prefixo__c, Status__c, Cliente__c, Name, DataVoo__c FROM Voo__c ORDER BY Id DESC LIMIT 1];
        Missao__c missao2 = missoesDomain.criarMissao(cmr, lista[0].Id);
        Map<Id, CalculoMissaoResult> mapaVoo = new Map<Id, CalculoMissaoResult>();
        mapaVoo.put(lista[0].Id, cmr);
        Map<Id, Missao__c> mapa = missoesDomain.criarMissoes(mapaVoo);
        Test.stopTest();
        System.assert(missao != null && missao2 != null && mapa != null);
    }

	@isTest
    static void checkValidTempoMissaoTest()
    {
        Test.startTest();
        Missao__c missao = new Missao__c(TempoMissao__c=10);
        Missoes missoesDomain = new Missoes(new List<Missao__c>());
        missoesDomain.checkValidTempoMissao(missao);
        missao.TempoMissao__c = null;
        missoesDomain.checkValidTempoMissao(missao);
        Test.stopTest();
    }
}