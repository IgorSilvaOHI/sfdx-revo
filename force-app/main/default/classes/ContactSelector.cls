public class ContactSelector extends SObjectSelector {

    protected override Schema.SObjectType getSObjectType(){
        return Contact.sObjectType;
    }

    protected override string allFieldList() {
        List<String> strList = Super.allFieldList().Split(',');
        strList.add('Account.RecordTypeId');
        return STRING.join(strList,',');
    }
}