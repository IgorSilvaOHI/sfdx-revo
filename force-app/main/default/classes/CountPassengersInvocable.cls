public class CountPassengersInvocable 
{
    @InvocableMethod(label='Voo - Conta Passageiros' description='Conta os passageiros que estiveram no voo e popula o campo')
	public static void countPassengers(List<Id> vooIds)
    {
        VoosService.countPassengers(vooIds);
    }
}