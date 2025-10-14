public class InteressadosConclusaoVooInvocable 
{
    @InvocableMethod(label='Interessados - Conclusão do Voo' description='Envia email aos interessados com a opção Conclusão do Voo selecionada.')
	public static void conclusaoVoo(List<Id> voosIds)
    {
        InteressadosFactory.newInstance(InteresseEnum.CONCLUSAOVOO).registerEmails(Utils.getSetIdsByListIds(voosIds));
    }    
}