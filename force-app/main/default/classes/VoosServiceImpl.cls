public class VoosServiceImpl implements IVoosService {

    protected Voo__c voo;
    protected List<Voo__c> voosList;
    protected List<Trecho__c> trechosList;
    protected List<Aeronave__c> aeronavesList;
    protected List<Local__c> locaisList;
    protected List<Id> localIdList;
    protected Set<Id> localSetIds;
    protected Set<Id> aeronaveSetIds;
    protected List<Local__c> trajetoLocaisList;
    protected Map<Id, Local__c> locaisMap;

    public VoosServiceImpl(){
        this.voo = new Voo__c();
        this.voosList = new List<Voo__c>();
        this.trechosList = new List<Trecho__c>();
        this.aeronavesList = new List<Aeronave__c>();
        this.locaisList = new List<Local__c>();
        this.localIdList = new List<Id>();
        this.localSetIds = new Set<Id>();
        this.aeronaveSetIds = new Set<Id>();
        this.trajetoLocaisList = new List<Local__c>();
        this.locaisMap = new Map<Id, Local__c>();
    }
    
    
    public List<Voo__c> getVoos(Set<Id> voosId) {
        return VoosSelector.newInstance().selectWithTrechosById(voosId);
    }
    
    public void undeleteVoos(Set<Id> voosId) {
        List<Voo__c> voosDeletados = VoosSelector.newInstance()
            .selectDeletedById(voosId);
        undelete voosDeletados;
    }
    
    public static void countPassengers(List<Id> vooIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Passageiro__c> passageiros = PassageiroSelector.getPassageirosToSurveyBySetVoosIds(
            Utils.getSetIdsByListIds(vooIds)
        );
        Map<Id, Set<Id>> contatosPorVoo = new Map<Id, Set<Id>>();
        for (Passageiro__c pass : passageiros) {
            if (!contatosPorVoo.containsKey(pass.IdVoo__c)) {
                contatosPorVoo.put(pass.IdVoo__c, new Set<Id>{ pass.Contato__c });
            } else {
                Set<Id> contatosDoVoo = contatosPorVoo.get(pass.IdVoo__c);
                contatosDoVoo.add(pass.Contato__c);
                contatosPorVoo.put(pass.IdVoo__c, contatosDoVoo);
            }
        }
        
        for (Id vooId : contatosPorVoo.keySet()) {
            Set<Id> quantidade = contatosPorVoo.get(vooId);
            Integer numeroContatos = quantidade.size();
            Voo__c novo = new Voo__c();
            novo.Id = vooId;
            novo.TotalPassageiros__c = numeroContatos;
            uow.registerDirty(novo);
        }
        uow.commitWork();
    }
}