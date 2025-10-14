public class ProtocoloSelector extends SObjectSelector {

    protected override Schema.SObjectType getSObjectType(){
        return Protocolo__c.sObjectType;
    }

    protected override string allFieldList() {
        List<String> strList = Super.allFieldList().Split(',');
        strList.add('Conta__r.RecordTypeId');
        return STRING.join(strList,',');
    }
}