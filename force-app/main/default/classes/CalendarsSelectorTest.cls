@isTest
private class CalendarsSelectorTest {
	@TestSetup
    private static void Setup() {
        
    }
    
    @isTest
    private static void getSObjectFieldListTest() {
        Test.startTest();
        List<Schema.SObjectField> fieldList = CalendarsSelector.newInstance().getSObjectFieldList();
        System.assert(fieldList.size() > 0, 'Something goes wrong in getSObjectFieldListTest' + '\nField List: ' + fieldList);
        Test.stopTest();
    }
    
    @isTest
    private static void getSObjectTypeTest() {
        Test.startTest();
        Schema.SObjectType sobjType = CalendarsSelector.newInstance().getSObjectType();
        System.assert(sobjType == Calendar.SObjectType, 'Something goes wrong in getSObjectTypeTest' + '\nSObj. Type: ' + sobjType);
        Test.stopTest();
    }
    
    @isTest
    private static void selectCalendarsByPrefixsSetNameTest() {
        Test.startTest();
        List<Calendar> calendarList =
            CalendarsSelector.newInstance().selectCalendarsByPrefixsSetName(
                Utils.mapByStringField(
                    (List<SObject>) [SELECT Id, Name FROM Calendar WHERE Name in ('PP-MED', 'PP-PRJ', 'PR-BGJ')],Calendar.Name).KeySet());
        System.assert(calendarList.size() == 0, 'Something goes wrong in selectCalendarsByPrefixsSetNameTest' + '\nCalendars: ' + calendarList);
        Test.stopTest();
    }
}