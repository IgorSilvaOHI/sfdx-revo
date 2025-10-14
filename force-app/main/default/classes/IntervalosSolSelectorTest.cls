@isTest
public class IntervalosSolSelectorTest {
    @TestSetup
    static void setup()
    {
        TestUtil.SetupStandardPricebook();
        
        Datetime data = Datetime.newInstance(System.now().date().addDays(2), Time.newInstance(15, 0, 0, 0));
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        TestUtil2.criarVooRascunho(data, true, uow);
        uow.commitWork();
    }
    
    @isTest
    static void constructorTest()
    {
        Test.startTest();
        IntervalosSolSelector is = new IntervalosSolSelector(true);
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    static void selectByIdTest()
    {
        Test.startTest();
        IntervaloSol__c intervalo = [SELECT Id FROM IntervaloSol__c ORDER BY Id DESC LIMIT 1];
        List<IntervaloSol__c> intervalos = IntervalosSolSelector.newInstance().selectById(new Set<Id> {intervalo.Id});
        Test.stopTest();
        System.assert(intervalos.size() == 1);
    }
    
    @isTest
    static void selectAllFutureTest()
    {
        Test.startTest();
		List<IntervaloSol__c> intervalos = IntervalosSolSelector.newInstance().selectAllFuture();
        Test.stopTest();
        System.assert(intervalos.size() > 0);
    }
    
    @isTest
    static void testeSingleton()
    {
        system.debug(CalculoMissaoSingleton.getInstance().horariosSol);
    }
}