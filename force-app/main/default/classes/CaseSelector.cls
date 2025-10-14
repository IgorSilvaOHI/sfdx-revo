public class CaseSelector extends SObjectSelector {

    protected override Schema.SObjectType getSObjectType(){
        return Case.sObjectType;
    }
        
    protected override string allFieldList() {
        List<String> strList = Super.allFieldList().Split(',');
        strList.add('Account.RecordTypeId');
        strList.add('RecordType.DeveloperName');
        return STRING.join(strList,',');
    }
}