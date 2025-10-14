public class InteresseFaturamento implements IInteresse
{
    
    @future
    public static void registerEmails(Set<Id> ids)
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        List<Interessado__c> interessadosList = InteressadosSelector.newInstance().selectFaturamentoByVoo(ids);        
        List<TemplateEmail__mdt> template = TemplateEmailSelector.newInstance().selectByDeveloperName(InteresseEnum.FATURAMENTO.name());
        
        if (template.size() > 0) Interessados.newInstance(interessadosList).registerEmails(uow, template.get(0), InteresseEnum.FATURAMENTO);
        
        uow.commitWork();
    }

}