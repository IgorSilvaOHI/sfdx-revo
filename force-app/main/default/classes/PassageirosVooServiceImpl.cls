public class PassageirosVooServiceImpl implements IPassageirosVooService {

    public String getPassageirosVoo(Id vooId)
    {
        List<PassageiroVoo__c> passageirosVoo = PassageirosVooSelector.newInstance().selectByVooId(new Set<Id>{vooId});
        List<Passageiro__c> ultimosPassageiros = PassageirosSelector.newInstance().selectByVooId(new Set<Id>{vooId});
        
        Set<Id> setContatosRemovidos = new Set<Id>();
        for(Passageiro__c passageiro : ultimosPassageiros){
            System.debug('excluido? ' + passageiro.Excluido__c + ' - ' + passageiro.Contato__c);
            if(passageiro.Excluido__c){
                setContatosRemovidos.add(passageiro.Contato__c);
            }
        }

        Map<Id, Contact> mapContatos = new Map<Id, Contact>();
        for(PassageiroVoo__c passageiro : passageirosVoo)
        {
            System.debug('Contains? ' + passageiro.Contato__r.Id + ' - ' + setContatosRemovidos.contains(passageiro.Contato__r.Id));
            if(!setContatosRemovidos.contains(passageiro.Contato__r.Id)){
                mapContatos.put(passageiro.Contato__r.Id, passageiro.Contato__r);
            }
        }
        return JSON.serialize(mapContatos);
    }
}