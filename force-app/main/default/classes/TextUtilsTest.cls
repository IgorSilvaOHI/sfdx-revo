@IsTest
private class TextUtilsTest {
    private static final Integer RECORD_NUMBER = 10;
    private static final Integer MAX_INTEGER = 6;

    @isTest
    static void shouldGenerateRandomTextPositive() {
        Test.startTest();
        for (Integer i = 0; i < RECORD_NUMBER; i++) {
            System.assertEquals(TextUtils.generateRandomText(i).length(), i, 'Generation of random text is broken');
        }
        Test.stopTest();
    }

    @isTest
    static void shouldGenerateRandomEmail() {
        Test.startTest();
        System.assert(String.isNotBlank(TextUtils.generateRandomEmail()));
        Test.stopTest();
    }

    @isTest
    static void shouldGenerateIndexInRange() {
        Test.startTest();
        Integer randomInteger = TextUtils.generateRandomIndex(MAX_INTEGER);
        System.assert(randomInteger < MAX_INTEGER, 'Random integer should not be greater than maxInteger');
        System.assert(randomInteger >= 0, 'Random integer should not be less than zero');
        Test.stopTest();
    }

    @isTest
    static void shouldGenerateRandomCharacter() {
        Test.startTest();
        System.assert(TextUtils.ALPHABET.contains(TextUtils.generateRandomCharacter()), 'Generated invalid character');
        Test.stopTest();
    }
    @isTest
    static void shouldGenerateBookingCode() {
        Test.startTest();
        for (Integer i = 1; i <= RECORD_NUMBER; i++) {
            String bookingCode = TextUtils.generateBookingCode(i);
            System.assertEquals(bookingCode.length(), i, 'Generation of booking code is broken');
            System.assert(!bookingCode.isNumeric(), 'Booking code cannot be numeric');
        }
        Test.stopTest();
    }
}