@isTest
public with sharing class EnvelopeAeronaveControllerTest 
{
    @TestSetup
    static void makeData()
    {
        TestUtil.SetupStandardPricebook();
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();       
        
        Local__c baseMae = TestUtil.carregaLocais(1)[0];
        uow.registerNew(baseMae);
        List<Product2> modelos = new List<Product2>{TestUtil.createProduct('Modelo'), TestUtil.createProduct('Modelo2')};
        insert modelos;
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
        Aeronave__c aeronave = [SELECT Id FROM Aeronave__c LIMIT 1];
        EnvelopeAeronave__c envelope = new EnvelopeAeronave__c(Aeronave__c = aeronave.Id, Peso__c = 17300, balanceamento__c = 360);
        insert envelope;
    }
    @IsTest
    static void pageTest()
    {
        EnvelopeAeronaveController envelope = new EnvelopeAeronaveController();
        Test.startTest();
        PageReference pageRef = Page.envelopeAeronave;
        Aeronave__c aeronave = [SELECT Id FROM Aeronave__c LIMIT 1];
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',aeronave.Id);
        pageRef.getParameters().put('atualValue1', '500');
        pageRef.getParameters().put('atualValue2', '500');
        pageRef.getParameters().put('zeroValue1', '500');
        pageRef.getParameters().put('zeroValue2', '500');
        ApexPages.StandardController sc = new ApexPages.standardController(aeronave);
        EnvelopeAeronaveController controller = new EnvelopeAeronaveController(sc);
        
        Test.stopTest();
        
    }
    @IsTest
    static void atributtesTest()
    {
        EnvelopeAeronaveController envelope = new EnvelopeAeronaveController();
        System.assertEquals(System.Label.Braco, envelope.braco, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
        System.assertEquals(System.Label.PesoEnvelope, envelope.peso, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
        System.assertEquals(System.Label.EnvelopeCG, envelope.envelope, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
        System.assertEquals(System.Label.PasseioCG, envelope.passeio, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
        System.assertEquals(System.Label.CGAtual, envelope.cgAtual, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
        System.assertEquals(System.Label.CGZeroComb, envelope.cgZeroComb, 'Algo deu errado - atributtesTest() - EnvelopeAeronaveController');
    }
}