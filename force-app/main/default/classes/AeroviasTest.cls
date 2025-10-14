@isTest
public class AeroviasTest 
{
    
    @testSetup
    public static void setup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Local__c> locais = TestUtil.criarLocais(uow, 5);
        uow.commitWork();
    }
    
    @isTest
    public static void test1()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        List<Local__c> locais = [SELECT Id FROM Local__c];
        
        List<Aerovia__c> aerovias = new List<Aerovia__c>();
        
        Aerovia__c aerovia1 = new Aerovia__c();
        aerovia1.Origem__c = locais.get(0).Id;
        aerovia1.Destino__c = locais.get(1).Id;
        aerovia1.Tipo__c = 'Bidirecional';
        aerovias.add(aerovia1);
        
        Aerovia__c aerovia2 = new Aerovia__c();
        aerovia2.Origem__c = locais.get(1).Id;
        aerovia2.Destino__c = locais.get(2).Id;
        aerovia2.Tipo__c = 'Unidirecional';
        aerovias.add(aerovia2);
        
        Aerovia__c aerovia3 = new Aerovia__c();
        aerovia3.Origem__c = locais.get(2).Id;
        aerovia3.Destino__c = locais.get(1).Id;
        aerovia3.Tipo__c = 'Unidirecional';
        aerovias.add(aerovia3); 
        
        uow.registerNew(aerovias);
        
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
        
        List<Aerovia__c> aeroviasList = [SELECT Id FROM Aerovia__c];
        
        System.assertEquals(4, aeroviasList.size());
    }
    
    @isTest
    public static void testDuplicado()
    {
        List<Local__c> locais = [SELECT Id FROM Local__c];
        
        Aerovia__c aerovia1 = new Aerovia__c();
        aerovia1.Origem__c = locais.get(0).Id;
        aerovia1.Destino__c = locais.get(1).Id;
        aerovia1.Tipo__c = 'Bidirecional';
        insert aerovia1;
        
        Test.startTest();
        try
        {
            Aerovia__c aerovia2 = new Aerovia__c();
            aerovia2.Origem__c = locais.get(1).Id;
            aerovia2.Destino__c = locais.get(0).Id;
            aerovia2.Tipo__c = 'Unidirecional';
            insert aerovia2;            
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains(Label.AeroviaDuplicada));
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testBiParaUni()
    {
        List<Local__c> locais = [SELECT Id FROM Local__c];
        
        Aerovia__c aerovia1 = new Aerovia__c();
        aerovia1.Origem__c = locais.get(0).Id;
        aerovia1.Destino__c = locais.get(1).Id;
        aerovia1.Tipo__c = 'Bidirecional';
        insert aerovia1;
        
        Test.startTest();
        aerovia1.Tipo__c = 'Unidirecional';           
        update aerovia1;
        Test.stopTest();
        
        List<Aerovia__c> aerovias = [SELECT Id FROM Aerovia__c];
        
        System.assertEquals(1, aerovias.size());
    }
    
    @isTest
    public static void testBiParaUni2()
    {
        String msgErro = '';
        List<Local__c> locais = [SELECT Id FROM Local__c];
        
        Aerovia__c aerovia1 = new Aerovia__c();
        aerovia1.Origem__c = locais.get(0).Id;
        aerovia1.Destino__c = locais.get(1).Id;
        aerovia1.Tipo__c = 'Bidirecional';
        insert aerovia1;
        
        Test.startTest();
        List<Aerovia__c> aerovias = [SELECT Id, Tipo__c FROM Aerovia__c];
        aerovias.get(0).Tipo__c = 'Unidirecional';
        aerovias.get(1).Tipo__c = 'Unidirecional';           
        try
        {
            update aerovias;
        }
        catch (Exception e)
        {
            msgErro = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(msgErro.contains(Label.MsgErroAeroviasConflito));
    }
    
    @isTest
    public static void testUniParaBi()
    {
        String msgErro = '';
        List<Local__c> locais = [SELECT Id FROM Local__c];
        
        Aerovia__c aerovia1 = new Aerovia__c();
        aerovia1.Origem__c = locais.get(0).Id;
        aerovia1.Destino__c = locais.get(1).Id;
        aerovia1.Tipo__c = 'Unidirecional';
        insert aerovia1;
        
        Test.startTest();
        List<Aerovia__c> aerovias = [SELECT Id, Tipo__c FROM Aerovia__c];
        aerovias.get(0).Tipo__c = 'Bidirecional';
        update aerovias;
        Test.stopTest();
        
        aerovias = [SELECT Id, Tipo__c, Volta__c FROM Aerovia__c];
        
        System.assert(aerovias.size() == 2);
        System.assert(aerovias.get(0).Tipo__c.equals('Bidirecional'));
        System.assert(aerovias.get(1).Tipo__c.equals('Bidirecional'));
        System.assert(aerovias.get(0).Volta__c.equals(aerovias.get(1).Id));
        System.assert(aerovias.get(1).Volta__c.equals(aerovias.get(0).Id));
    }
    
    @isTest
    public static void testNewInstance()
    {
        Test.startTest();
        IAerovias i = Aerovias.newInstance(new List<Aerovia__c>());
        Test.stopTest();
        
        System.assert(i != null);
    }

}