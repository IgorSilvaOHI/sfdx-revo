public without sharing class InteressadosServiceImpl implements IInteressadosService {
    public void criarInteressados(Set<Id> voosSetId)
    {
        Set<Contact> contactSet = new Set<Contact> (ContatosSelector.newInstance().selectContatosByVooId(voosSetId));
        Set<Voo__c> vooSet = new Set<Voo__c> (VoosSelector.newInstance().selectById(voosSetId));
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Interessados.newInstance(new List<Interessado__c>()).criarInteressados(vooSet, contactSet, uow);
        uow.commitWork();
    }
}