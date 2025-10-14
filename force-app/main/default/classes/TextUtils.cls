public class TextUtils {
    @testVisible
    private static final String ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    private static final String NUMBERS = '0123456789';
    private static final String SYMBOLS = ALPHABET + NUMBERS;

    public static String generateRandomText(Integer textLength) {
        String randomText = '';
        while (randomText.length() < textLength) {
            randomText += generateRandomSymbol();
        }
        return randomText;
    }

    public static String generateRandomEmail() {
        return generateRandomText(30) + '@dummy.dummy';
    }

    public static Integer generateRandomIndex(Integer maxValue) {
        return Math.mod(Math.abs(Crypto.getRandomInteger()), maxValue);
    }

    public static String generateRandomCharacter() {
        Integer randomIndex = generateRandomIndex(ALPHABET.length());
        return ALPHABET.substring(randomIndex, randomIndex + 1);
    }

    public static String generateRandomSymbol() {
        Integer randomIndex = generateRandomIndex(SYMBOLS.length());
        return SYMBOLS.substring(randomIndex, randomIndex + 1);
    }

    public static String generateBookingCode(Integer codeLength) {
        String randomText = generateRandomText(codeLength);
        if (randomText.isNumeric()) {
            Integer randomIndex = generateRandomIndex(codeLength);
            randomText = randomText.left(randomIndex) + generateRandomCharacter() + randomText.substring(randomIndex + 1, codeLength);
        }
        return randomText.toUpperCase();
    }
}