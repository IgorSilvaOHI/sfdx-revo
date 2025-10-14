public class InteresseConclusaoTrecho implements IInteresse
{
    
    @future
    public static void registerEmails(Set<Id> ids)
    {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        List<Trecho__c> trechos = [SELECT Id, Voo__c FROM Trecho__c WHERE Id IN :ids];        
        Map<Id, Voo__c> voos = new Map<Id, Voo__c>([SELECT Id, (SELECT Id, Voo__c FROM Trechos__r WHERE Id IN :ids) FROM Voo__c WHERE Id IN :Utils.getSetIds(trechos, 'Voo__c')]);
        List<Interessado__c> interessadosList = InteressadosSelector.newInstance().selectConclusaoTrechoByVoo(voos.keySet());        
        List<TemplateEmail__mdt> template = TemplateEmailSelector.newInstance().selectByDeveloperName(InteresseEnum.CONCLUSAOTRECHO.name());
        
        if (template.size() > 0) Interessados.newInstance(interessadosList).registerEmails(uow, template.get(0), voos, InteresseEnum.CONCLUSAOTRECHO);
        
        uow.commitWork();
    }

}