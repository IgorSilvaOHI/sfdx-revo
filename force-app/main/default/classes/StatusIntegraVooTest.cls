@isTest
public class StatusIntegraVooTest {

    @isTest
    public static void testEnum()
    {
        system.assert(StatusIntegraVoo.CANCELADO != null);
        system.assert(StatusIntegraVoo.RESERVADO != null);
        system.assert(StatusIntegraVoo.CONFIRMADO != null);
        system.assert(StatusIntegraVoo.ROTA != null);
        system.assert(StatusIntegraVoo.EXECUTADO != null);
    }
}