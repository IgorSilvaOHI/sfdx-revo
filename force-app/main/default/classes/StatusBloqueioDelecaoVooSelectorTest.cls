@isTest
public class StatusBloqueioDelecaoVooSelectorTest {
	
    @isTest
    public static void selectAllTest()
    {
        Test.startTest();
        List<StatusBloqueioDelecaoVoo__mdt> statusBloqueados = StatusBloqueioDelecaoVooSelector.newInstance().selectAll();
        Test.stopTest();
        System.assertEquals(5, statusBloqueados.size());
    }
}