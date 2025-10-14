public class InteressadosReservaInvocable 
{
    @InvocableMethod(label='Interessados - Reserva' description='Envia email aos interessados com a opção Reserva selecionada.')
	public static void reserva(List<Id> voosIds)
    {
        InteressadosFactory.newInstance(InteresseEnum.RESERVA).registerEmails(Utils.getSetIdsByListIds(voosIds));
    }    
}