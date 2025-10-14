public without sharing class PassageiroOportunidades  extends fflib_SObjectDomain {

    public PassageiroOportunidades(List<PassageiroOportunidade__c> sObjectList)
    {
        super(sObjectList);
    }    

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new PassageiroOportunidades(sObjectList);
        }
    }

    public override void onBeforeDelete()
    {
        fflib_SObjectDomain.getTriggerEvent(ProdutoPassageiros.class).disableAfterDelete();

        System.debug(this.ExistingRecords.keyset());

        List<ProdutoPassageiro__c> outros = [Select Id From ProdutoPassageiro__c Where PassageiroOportunidade__c IN :this.ExistingRecords.keyset()];
        
        System.debug(outros);

        if (!outros.isEmpty()) {
            delete outros;
        }
    }    

}