public without sharing class ProdutoPassageiros  extends fflib_SObjectDomain {

    public ProdutoPassageiros(List<ProdutoPassageiro__c> sObjectList)
    {
        super(sObjectList);
    }    

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new ProdutoPassageiros(sObjectList);
        }
    }

    public override void onAfterDelete()
    {
        fflib_SObjectDomain.getTriggerEvent(PassageiroOportunidades.class).disableBeforeDelete();

        Set<Id> passageirosIds = new Set<Id>();
        Set<Id> exclusoesIds = new Set<Id>();

        for (SObject pp : this.ExistingRecords.values()) {
            passageirosIds.add(((ProdutoPassageiro__c)pp).PassageiroOportunidade__c);
        }

        List<ProdutoPassageiro__c> outros = [Select Id, PassageiroOportunidade__c From ProdutoPassageiro__c Where PassageiroOportunidade__c IN :passageirosIds And Id Not In :this.ExistingRecords.keyset()];
        
        for (Id passId : passageirosIds) {

            Boolean encontrou = false;

            for (ProdutoPassageiro__c pp : outros) {
                if (pp.PassageiroOportunidade__c == passId) {
                    encontrou = true;
                }
            }

            if (!encontrou) {
                exclusoesIds.add(passId);
            }
        }

        if (!exclusoesIds.isEmpty()) {
            delete [Select Id From PassageiroOportunidade__c Where Id In :exclusoesIds];
        }
    }    

}