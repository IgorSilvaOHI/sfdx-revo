@isTest
private class Product2SelectorTest {

    @testSetup
    static void setupData() {
        
        Id standardPricebookId = TestUtil.SetupStandardPricebook();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        insert pb;
        Id shuttleSeatRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('ShuttleSeat').getRecordTypeId();
        Product2 seatProduct = new Product2(
            Name = 'Seat Product',
            IsActive = true,
            RecordTypeId = shuttleSeatRecordTypeId
        );
        insert seatProduct;
        insert new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = seatProduct.Id, UnitPrice = 100, IsActive = true);
    }

    @isTest
    static void testSelectSeatProductByRoute() {
        Id origin = null;
        Id destiny = null;

        Product2Selector selector = new Product2Selector();
        Product2 result = selector.selectSeatProductByRoute(origin, destiny);

        System.assertNotEquals(result, null, 'O produto selecionado não deve ser nulo.');
        System.assertEquals('Seat Product', result.Name, 'O nome do produto selecionado deve ser Seat Product.');
    }

    @isTest
    static void testGetSObjectType() {
        Product2Selector selector = new Product2Selector();
        Schema.SObjectType sObjectType = selector.getSObjectType();

        System.assertEquals(Product2.SObjectType, sObjectType, 'O tipo de objeto deve ser Product2.');
    }
}