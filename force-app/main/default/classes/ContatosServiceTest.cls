@isTest public class ContatosServiceTest 
{
    
    @testSetup
    public static void setup()
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Account acc = TestUtil2.createAccount('Conta', true, uow);
        Contact con = TestUtil2.createContact(acc, 'Contato', uow);
        
        uow.commitWork();
    }
    
    @isTest
    public static void test1()
    {
        List<Contact> conts = [SELECT Id FROM Contact];
        List<Id> contatosIds = Utils.getListIds(conts, 'Id');
        
        Test.startTest();
        
        ContatosService.getContatosNaoInclusos(contatosIds, '' );
        
        Test.stopTest();
    }
    
}