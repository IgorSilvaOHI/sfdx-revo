@isTest
public class TrechosTest {

    @TestSetup
    static void setup()
    {
        TestUtil.SetupStandardPricebook();
        
        Datetime data = Datetime.newInstance(System.now().date().addDays(1), Time.newInstance(15, 0, 0, 0));
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        TestUtil2.criarVooRascunho(data, true, uow);
        uow.commitWork();
    }
    
    @isTest
    static void insertUpdateDeleteTest()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Test.startTest();
        Voo__c voo = [SELECT Id FROM Voo__c ORDER BY Id DESC LIMIT 1];
        List<Local__c> locais = [SELECT Id FROM Local__c ORDER BY Id DESC LIMIT 2];
       	Trecho__C trecho1 = TestUtil2.createTrecho(voo, locais[0], locais[1], 30, uow);
        Trecho__C trecho2 = TestUtil2.createTrecho(voo, locais[0], locais[1], 40, uow);
        uow.commitWork();
        trecho1.PrevisaoPouso__c = System.now();
        update trecho1;
        delete trecho2;
        
        Test.stopTest();
    }
    
    @isTest
    static void testes()
    {
        Voo__c voo = [SELECT Id FROM Voo__c ORDER BY Id DESC LIMIT 1];
        List<Trecho__c> trechosDoVoo = TrechosSelector.newInstance().selectByVooId(new Set<Id> {voo.Id});
        Trechos trechos = new Trechos(trechosDoVoo);
        trechos.getTrajeto();
        Trecho__c trecho = trechosDoVoo[0];
        trecho.Comentarios__c = null;
        Boolean assert = trechos.existsFieldAndValueIsBlankOrNull(trecho, Trecho__c.Comentarios__c);
        Object o = trechos.getValueByField(Trecho__c.Comentarios__c, new LogVoo__c(), trecho);
        Boolean assert1 = trechos.checkCoordenadas(22, 22, 22, 22);
        Boolean assert2 = trechos.isOffshore(null);
        assert2 = trechos.isOffshore(new Local__c(Tipo__c='Offshore'));
    }
}