public class InteresseConclusaoVoo implements IInteresse
{
    @future
    public static void registerEmails(Set<Id> ids)
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        List<Interessado__c> interessadosList = InteressadosSelector.newInstance().selectConclusaoVooByVoo(ids);        
        List<TemplateEmail__mdt> template = TemplateEmailSelector.newInstance().selectByDeveloperName(InteresseEnum.CONCLUSAOVOO.name());
        
        if (template.size() > 0) Interessados.newInstance(interessadosList).registerEmails(uow, template.get(0), InteresseEnum.CONCLUSAOVOO);
        
        uow.commitWork();
    }

}