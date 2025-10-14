public class InteressadosEmbarqueInvocable 
{
    @InvocableMethod(label='Interessados - Embarque' description='Envia email aos interessados com a opção Embarque do Voo selecionada.')
	public static void embarque(List<Id> voosIds)
    {
        InteressadosFactory.newInstance(InteresseEnum.EMISSAOEMBARQUE).registerEmails(Utils.getSetIdsByListIds(voosIds));
    }    
}