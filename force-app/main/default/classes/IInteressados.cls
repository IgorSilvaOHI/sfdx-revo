public interface IInteressados extends fflib_ISObjectDomain
{    
    void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template);
    void criarInteressados(Set<Voo__c> vooSet, Set<Contact> contactSet, fflib_ISObjectUnitOfWork uow);
    void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template, Map<Id, Voo__c> voos, InteresseEnum interesse);
    void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template, InteresseEnum interesse);
}