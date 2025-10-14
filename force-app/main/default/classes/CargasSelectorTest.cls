@isTest
public class CargasSelectorTest {
    
    @testSetup
    public static void setup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        
        TestUtil.insereConfiguracoesPersonalizadas();
    }

    @IsTest
	private static void testSelectById()
	{
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Integer numCargasTrecho = 2;
        
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Voo__c> voos = TestUtil.criarVoos(uow, 1, contas);
        List<Local__c> locais = TestUtil.criarLocais(uow, 2);
        List<Trecho__c> trechos = TestUtil.criarTrechos(uow, voos, locais.get(0), locais.get(1), 2);
        List<Carga__c> cargas = TestUtil.criarCargas(uow, trechos, numCargasTrecho);
        
        uow.commitWork();
        
		Carga__c carga = [SELECT Id, Trecho__c FROM Carga__c LIMIT 1];		
        
        // Query
        List<Carga__c> cargasSelecionadas = new CargasSelector().selectById(new Set<Id> {carga.Id});
        Carga__c cargaSelecionada = cargasSelecionadas.get(0);
		// Assert
		System.assertEquals(carga.Id, cargaSelecionada.Id);		
		System.assertEquals(carga.Trecho__c, cargaSelecionada.Trecho__c);	
	}
    
    @IsTest
	private static void testSelectByIdWithTrechosIniciados()
	{
		
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Integer numCargasTrecho = 2;
        
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Voo__c> voos = TestUtil.criarVoos(uow, 2, contas);        
        List<Local__c> locais = TestUtil.criarLocais(uow, 2);
        List<Trecho__c> trechos = TestUtil.criarTrechos(uow, voos, locais.get(0), locais.get(1), 2);
        List<Carga__c> cargas = TestUtil.criarCargas(uow, trechos, numCargasTrecho);
        
        Trecho__c trecho3 = trechos.get(2);
        
        uow.commitWork();
        
        Test.startTest();

        Trecho__c trecho1 = trechos.get(0);
        Trecho__c trecho2 = trechos.get(1);
		trecho1.Status__c = 'Em Rota';
        trecho2.Status__c = 'Finalizado';
        
        List<Trecho__c> trechosToUpdate = new List<Trecho__c>();
        trechosToUpdate.add(trecho1);
        trechosToUpdate.add(trecho2);
        update trechosToUpdate;
            
        Set<Id> trechoIds = new Set<Id> {trecho1.Id, trecho2.Id, trecho3.Id};
        List<Trecho__c> trechosAValidar = [SELECT Id, (SELECT Id FROM Cargas__r) FROM Trecho__c WHERE ID IN : trechoIds];
        Set<Id> cargaIds = new Set<Id>();
        for(Trecho__c trecho : trechosAValidar)
        {
            for(Carga__c carga : trecho.Cargas__r)
            {
                cargaIds.add(carga.Id);
            }
        }
        
        Test.stopTest();
        // Query
        List<Carga__c> cargasSelecionadas = new CargasSelector().selectByIdWithTrechosIniciados(cargaIds);
        // Assert
        System.assertEquals(4, cargasSelecionadas.size());	
		
	}
    
    @IsTest
	private static void testQueryLocatorCargasDeletadas()
	{
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        List<Account> contas = TestUtil.criarContas(uow, 1);
        List<Voo__c> voos = TestUtil.criarVoos(uow, 1, contas);
        List<Local__c> locais = TestUtil.criarLocais(uow, 2);
        List<Trecho__c> trechos = TestUtil.criarTrechos(uow, voos, locais.get(0), locais.get(1), 1);
        Carga__c carga = new Carga__c();
        carga.Name = 'Baita carga';
        uow.registerNew(carga, Carga__c.Trecho__c, trechos.get(0));

        uow.commitWork();
        
        fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();
        uow2.registerDeleted(carga);
        uow2.commitWork();
        
		// Query
        Database.QueryLocator queryLocator = 
			new CargasSelector().queryLocatorCargasDeletadas();
			
		// Assert
		Database.QueryLocatorIterator cargasIterator = queryLocator.iterator();
		Carga__c queriedCarga = (Carga__c) cargasIterator.next();
		System.assertEquals('Baita carga', queriedCarga.Name);		
	
	}

    
    @IsTest
    private static void testNewInstance()
	{
		ICargasSelector cargasSelector = CargasSelector.newInstance();
        System.assertNotEquals(cargasSelector, null);
	}
    
    @isTest
    private static void selectByVooIdTest() {  
        Test.startTest();
        List<Carga__c> cargaList = new CargasSelector(true).selectByVooId(new Set<Id>());
        Test.stopTest();
        
        System.assert(cargaList.size() == 0);
    }
}