@IsTest
public with sharing class LocalVooWrapperTest {
    
    @IsTest
    public static void testLocalVooWrapper() {
        LocalVooWrapper localVooWrapper = new LocalVooWrapper();
        localVooWrapper.Value = '123';
        localVooWrapper.FormattedValue = '123';
        localVooWrapper.IsCoordenada = true;
        System.assertEquals(localVooWrapper.Value, '123');
        System.assertEquals(localVooWrapper.FormattedValue, '123');
        System.assertEquals(localVooWrapper.IsCoordenada, true);
    }
}