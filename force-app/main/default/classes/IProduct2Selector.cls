public interface IProduct2Selector extends fflib_ISObjectSelector {

    Product2 selectSeatProductByRoute(Id origin, Id destiny);
    Product2 selectFullCabinProductByRoute(Id origin, Id destiny);
    List<Product2> selectById(Set<Id> idSet);
    Product2 selectCharterProduct();
    List<Product2> selectActiveByRecordTypes(Set<String> recordTypeNames);
    List<Product2> selectActiveShuttleSeatProducts();

}