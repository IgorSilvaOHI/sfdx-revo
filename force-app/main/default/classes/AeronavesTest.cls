@isTest
public class AeronavesTest {
        
    @testSetup
    public static void setup()
    {
        Id standardPricebookId = TestUtil.SetupStandardPricebook();

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();       
        
        Local__c baseMae = TestUtil.carregaLocais(1)[0];
        uow.registerNew(baseMae);

        //SObject type Product2 is not supported by this unit of work
        List<Product2> modelos = new List<Product2>{TestUtil.createProduct('Modelo'), TestUtil.createProduct('Modelo2')};
        insert modelos;
        //uow.registerNew(modelos);
        
        Integer j = 1;
        for(Product2 modelo : modelos)
        {
            for(Integer i = 1; i < 5; i++)
            {
                Aeronave__c aeronave = TestUtil.carregaAeronave('Aeronave ' + i + '-' + j);
                uow.registerRelationship(aeronave, Aeronave__c.BaseMae__c, baseMae);
                uow.registerNew(aeronave, Aeronave__c.ModeloAeronave__c, modelo);
            }
            j++;
        }        
        
        uow.commitWork();
    }
    
    @isTest
    public static void getPorModeloTest()
    {
        List<Product2> modelos = [select id from product2];
        List<Aeronave__c> aeronavesList = [select id, modeloAeronave__c from aeronave__c];
        IAeronaves ae = Aeronaves.newInstance(aeronavesList);
        Test.startTest();
        Map<Id, List<Aeronave__c>> aeronavesPorModelo = ae.getPorModelo();
        Test.stopTest();
        System.assert(modelos.size() > 0);
        for(Product2 modelo : modelos)
        {
            System.assertEquals(4, aeronavesPorModelo.get(modelo.Id).size());
        }
    }
    
    @isTest
    public static void getPorPrefixoTest()
    {
        List<Aeronave__c> aeronavesList = [select id, Name from aeronave__c];
        IAeronaves ae = Aeronaves.newInstance(aeronavesList);
        Test.startTest();
        Map<String, Aeronave__c> aeronavesPorPrefixo = ae.getPorPrefixo();
        Test.stopTest();
        System.assert(aeronavesList.size() > 0);
        for(Aeronave__c aeronave : aeronavesList)
        {
            String prefixo = aeronave.Name;
            System.assertEquals(prefixo, aeronavesPorPrefixo.get(prefixo).Name);
        }
    }   

}