public class InteressadosConclusaoTrechoInvocable 
{
    @InvocableMethod(label='Interessados - Conclusão do Trecho' description='Envia email aos interessados com a opção Conclusão do Trecho selecionada.')
	public static void conclusaoTrecho(List<Id> trechosIds)
    {
        InteressadosFactory.newInstance(InteresseEnum.CONCLUSAOTRECHO).registerEmails(Utils.getSetIdsByListIds(trechosIds));
    }    
}