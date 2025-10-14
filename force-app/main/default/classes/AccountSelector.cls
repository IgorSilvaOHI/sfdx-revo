public class AccountSelector extends SObjectSelector {
  protected override Schema.SObjectType getSObjectType() {
    return Account.sObjectType;
  }

  public Account SelectIdForUpdate(Id recordId) {
    String strFields = allFieldList();
    List<String> listFields = strFields.split(',');

    List<String> listFieldsToUpdate = new List<String>();

    for (String field : listFields) {
      if (!field.contains('__pc')) {
        listFieldsToUpdate.add(field);
      }
    }

    String fieldsToUpdate = String.join(listFieldsToUpdate, ',');

    Account acc = (Account) Database.query(
      'SELECT ' + fieldsToUpdate + ' FROM Account WHERE Id = :recordId'
    );

    return acc;
  }

  protected override string allFieldList() {
    List<String> fields = super.allFieldList().split(',');

    fields.add('RecordType.DeveloperName');

    return String.join(fields, ',');
  }
}