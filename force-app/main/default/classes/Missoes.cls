public class Missoes extends fflib_SObjectDomain implements IMissoes
{
    
    public Missoes(List<Missao__c> sObjectList)
    {
        super(sObjectList);

        Configuration.disableTriggerCRUDSecurity();        
    }
    
    public static IMissoes newInstance(List<Missao__c> sObjectList)
    {        
        return (IMissoes) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Missoes(sObjectList);
        }
    }
    
    public Missao__c createMissao(CalculoMissaoResult cmr, fflib_ISObjectUnitOfWork uow)
    {
        Missao__c missao = new Missao__c();
        missao.Aeronave__c = cmr.aeronave != null ? cmr.aeronave.Id : null;
        missao.BaseOrigem__c = cmr.baseOrigem != null ? cmr.baseOrigem.Id : null;
        missao.DataMissao__c = cmr.dataMissao;
        missao.HorarioMaximoDecolagem__c = cmr.hrMaximoDecolagem;
        missao.TempoMissao__c = cmr.tempoMissao;
        missao.PesoMaximo__c = cmr.pesoMaximo;
        missao.TempoTransladoIda__c = cmr.tempoTransladoIda;
        missao.TempoTransladoRetorno__c = cmr.tempoTransladoRetorno;
        missao.TempoCruzeiro__c = cmr.tempoCruzeiro;
        missao.TempoSolo__c = cmr.tempoSolo;
        missao.Viabilidade__c = cmr.viabilidade;
        
        uow.registerNew(missao);
        //uow.registerRelationship(missao, Missao__c.Voo__c, vooId);
        return missao;
    }
    
    @TestVisible
    private Missao__c criarMissao(CalculoMissaoResult cmr, Id vooId)
    {
        Missao__c missao = new Missao__c();
        missao.Aeronave__c = cmr.aeronave != null ? cmr.aeronave.Id : null;
        missao.BaseOrigem__c = cmr.baseOrigem != null ? cmr.baseOrigem.Id : null;
        missao.DataMissao__c = cmr.dataMissao;
        missao.HorarioMaximoDecolagem__c = cmr.hrMaximoDecolagem;
        missao.TempoMissao__c = cmr.tempoMissao;
        missao.PesoMaximo__c = cmr.pesoMaximo;
        missao.TempoTransladoIda__c = cmr.tempoTransladoIda;
        missao.TempoTransladoRetorno__c = cmr.tempoTransladoRetorno;
        missao.TempoCruzeiro__c = cmr.tempoCruzeiro;
        missao.TempoSolo__c = cmr.tempoSolo;
        missao.Viabilidade__c = cmr.viabilidade;
        missao.Voo__c = vooId;
        
        return missao;
    }
    
    public Map<Id, Missao__c> criarMissoes(Map<Id, CalculoMissaoResult> mapVooCMR)
    {
        Map<Id, Missao__c> mapVooMissao = new Map<Id, Missao__c>();
        for (Id vooId : mapVooCMR.keySet())
        {
            mapVooMissao.put(vooId, criarMissao(mapVooCMR.get(vooId), vooId));            
        }
        return mapVooMissao;
    }
    
    public Boolean checkValidTempoMissao(Missao__c missao)
    {
        Boolean valid = false;
        if(missao.TempoMissao__c != null && missao.TempoMissao__c > 0) valid = true;
        else missao.TempoMissao__c.addError(Label.ErroTempoMissaoVazio);
        return valid;
    }
}