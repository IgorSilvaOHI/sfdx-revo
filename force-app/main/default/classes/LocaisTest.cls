@isTest
public class LocaisTest 
{
	@TestSetup()
    private static void testSetup()
    {
        TestUtil.insereConfiguracoesPersonalizadas();
        
        List<Local__c> locaislist = TestUtil.carregaLocais(3);
        locaislist[0].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaislist[0].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        //locaislist[0].Status__c = 'Validado';
        locaislist[1].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaislist[1].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        //locaislist[1].Status__c = 'Validado';
        locaislist[2].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaislist[2].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        insert locaislist;
    }
    
    @isTest
    private static void validaCoordenadasIguais()
    {
        List<Local__c> locaisChegando = TestUtil.carregaLocais(5);
        locaisChegando[0].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaisChegando[0].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        locaisChegando[0].CodigoLocal__c = 'Local001';
        locaisChegando[1].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaisChegando[1].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        locaisChegando[1].CodigoLocal__c = 'Local002';
        locaisChegando[2].CodigoLocal__c = 'Local003';        
        locaisChegando[3].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaisChegando[3].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        locaisChegando[3].CodigoLocal__c = 'Local004';
        locaisChegando[4].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaisChegando[4].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        locaisChegando[4].CodigoLocal__c = 'Local005';
        
        Test.startTest();
        Database.SaveResult[] srList = Database.insert(locaisChegando, false);
        Test.stopTest();
        
        Integer contadorErros = 0;
        Integer contadorSucesso = 0;
        
        for (Database.SaveResult sr : srList)
        {
            System.debug('sr: ' + sr);
            if (!sr.isSuccess()) 
            {
                contadorErros++;
            }
            else
            {
                contadorSucesso++;
            }
        }
        
        System.assertEquals(contadorErros, 0);
        System.assertEquals(contadorSucesso, 5);
        System.assertEquals(srList.size(), locaisChegando.size());
    }
    
    @isTest
    private static void updateTest()
    {
        List<Local__c> locaisChegando = [select id from local__c];
        locaisChegando[0].Coordenadas__Latitude__s = TestUtil.getRandomLatitude();
        locaisChegando[0].Coordenadas__Longitude__s = TestUtil.getRandomLongitude();
        locaisChegando[0].CodigoLocal__c = 'Local001';
        locaisChegando[1].Coordenadas__Latitude__s = null;
        locaisChegando[1].Coordenadas__Longitude__s = null;
        locaisChegando[1].CodigoLocal__c = 'Local002';
     	update locaisChegando;
    }
}