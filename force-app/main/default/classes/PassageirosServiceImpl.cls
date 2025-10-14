public class PassageirosServiceImpl implements IPassageirosService
{    
    public String salvarListaPassageiros(List<Id> passageirosVoo, Map<Id,List<Id>> passageirosTrechos, Id vooId){
        List<PassageiroVoo__c> ultimosPassageirosVoo = PassageirosVooSelector.newInstance().selectByVooId(new Set<Id>{vooId});
        Map<Id, PassageiroVoo__c> contatosUltimosPassageirosVoo = getMapPassageirosVooPorContato(ultimosPassageirosVoo);
        Set<Id> setPassageirosVoo = Utils.getSetIdsByListIds(passageirosVoo);
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        handlePassageirosVoo(setPassageirosVoo, contatosUltimosPassageirosVoo, vooId, uow);
        
        List<Passageiro__c> ultimosPassageiros = PassageirosSelector.newInstance().selectByVooId(new Set<Id>{vooId});
        Map<Id, List<Passageiro__c>> ultimosPassageirosPorTrecho = (Map<Id, List<Passageiro__c>>)Utils.groupByRelatedTo(ultimosPassageiros, Passageiro__c.Trecho__c, null);
        
        List<Servico__c> servicos = new ServicosSelector().selectByVooId(new Set<Id>{vooId});

        handlePassageirosTrechos(ultimosPassageirosPorTrecho, passageirosTrechos, servicos, uow);
        
        uow.commitWork();
        return 'sucesso';
    }
    
    private void handlePassageirosTrechos(Map<Id, List<Passageiro__c>> ultimosPassageirosPorTrecho, Map<Id,List<Id>> passageirosTrechos, List<Servico__c> servicos, fflib_ISObjectUnitOfWork uow){
        Map<Id, Map<Id, Passageiro__c>> ultimosPassageirosPorTrechoMap = new Map<Id, Map<Id, Passageiro__c>>();
        
        String codigoReserva = '';
        if(servicos.size() > 0){
            codigoReserva = servicos[0].Oportunidade__r.CodigoReserva__c;
        }

        for(Id trechoId : ultimosPassageirosPorTrecho.keySet())
        {
            List<Passageiro__c> passageiros = ultimosPassageirosPorTrecho.get(trechoId);
            ultimosPassageirosPorTrechoMap.put(trechoId, getMapPassageirosPorContato(passageiros));
        }
        
        for(Id trechoId : passageirosTrechos.keySet())
        {
            List<Id> passageiros = passageirosTrechos.get(trechoId);
            Set<Id> setPassageirosTrecho = Utils.getSetIdsByListIds(passageiros);
            Integer passageiroCount = 0;
            Map<Id, Passageiro__c> passageirosDoTrechoPorContato = ultimosPassageirosPorTrechoMap.get(trechoId);
            for(Id passageiroVoo : setPassageirosTrecho)
            {               
                
                if(passageirosDoTrechoPorContato != null)
                {
                    if(passageirosDoTrechoPorContato.containsKey(passageiroVoo))
                    {
                        passageirosDoTrechoPorContato.remove(passageiroVoo);
                    }else
                    {
                        Passageiro__c novoPassageiro = new Passageiro__c(Trecho__c = trechoId, 
                        Contato__c = passageiroVoo,
                        CodigoReserva__c = codigoReserva);
                        uow.registerNew(novoPassageiro);
                    }
                    
                }else{
                    Passageiro__c novoPassageiro = new Passageiro__c(Trecho__c = trechoId, 
                    Contato__c = passageiroVoo,
                    CodigoReserva__c = codigoReserva);
                    uow.registerNew(novoPassageiro);
                }
            }

            if(passageirosDoTrechoPorContato != null){

                for(Passageiro__c passageiro : passageirosDoTrechoPorContato.values()){
                    
                    if(passageiro.Excluido__c){
                        continue;
                    }

                    if(passageiro.Servicos__r.size() > 0){
                        passageiro.Excluido__c = true;
                        uow.registerDirty(passageiro);
                    }else{
                        uow.registerDeleted(passageiro);
                    }
                }
            }
            	
        }
    }
    
    private void handlePassageirosVoo(Set<Id> setPassageirosVoo, Map<Id, PassageiroVoo__c> contatosUltimosPassageirosVoo, Id vooId, fflib_ISObjectUnitOfWork uow)
    {            
        Voo__c voo = new VoosSelector().selectById(new Set<Id>{vooId})[0];

        
        for(Id passageiroVoo : setPassageirosVoo)
        {
            if(contatosUltimosPassageirosVoo.containsKey(passageiroVoo)){
                contatosUltimosPassageirosVoo.remove(passageiroVoo);
            }else{
                if(voo.Tipo__c == 'ShuttleSeat'){
                    throw new AuraHandledException('Não é possível adicionar passageiros à um voo ShuttleSeat');
                }
                
                PassageiroVoo__c novoPassageiro = new PassageiroVoo__c(Voo__c = vooId, Contato__c = passageiroVoo);
                uow.registerNew(novoPassageiro);
            }
        }
        uow.registerDeleted(contatosUltimosPassageirosVoo.values());
    }
    
    private Map<Id, PassageiroVoo__c> getMapPassageirosVooPorContato(List<PassageiroVoo__c> sObjs){
        Map<Id, PassageiroVoo__c> mapRelated = new Map<Id, PassageiroVoo__c>();

        for(PassageiroVoo__c sObj : sObjs)
        {
            mapRelated.put((Id)SObj.get(PassageiroVoo__c.Contato__c), sObj);
        }
        return mapRelated;
    }
    
    private Map<Id, Passageiro__c> getMapPassageirosPorContato(List<Passageiro__c> sObjs){
        Map<Id, Passageiro__c> mapRelated = new Map<Id, Passageiro__c>();

        for(Passageiro__c sObj : sObjs)
        {
            mapRelated.put((Id)SObj.get(Passageiro__c.Contato__c), sObj);
        }
        return mapRelated;
    }
    public static List<Passageiro__c> getPassageirosByVooId(List<Id> vooIds)
    {
        return PassageirosSelector.newInstance().selectByVooId(Utils.getSetIdsByListIds(vooIds));
    }
    
}