public abstract without sharing class SObjectSelector
{    
    abstract protected Schema.SObjectType getSObjectType();    
    
    public SObjectSelector() { }
    
    public SObject SelectId(Id recordId) {
        List<SObject> objetos = SelectWhereId('Id', recordId);
		if (objetos.isEmpty())
            return null;
        else
	        return objetos.get(0);
    }

    public List<SObject> SelectIn(List<Id> recordsId) {
       	return SelectWhereIn('Id', recordsId);
    }
    
    public List<SObject> SelectWhereIn(String whereIn, List<Id> recordsId) {
        return Database.query('SELECT ' + allFieldList() + ' FROM ' + String.valueOf(getSObjectType()) + ' WHERE ' + whereIn + ' IN :recordsId');
    }

    public List<SObject> SelectWhereId(String whereId, Id recordId) {
       	return Database.query('SELECT ' + allFieldList() + ' FROM ' + String.valueOf(getSObjectType()) + ' WHERE ' + whereId + ' = :recordId');
    }
    
    protected virtual string allFieldList() {
        Set<String> questionFieldList = Schema.getGlobalDescribe().get(String.valueOf(getSObjectType())).getDescribe().fields.getMap().keySet();
        List<String> strList = new List<String>();
        strList.addAll(questionFieldList);
        return STRING.join(strList,',');
    }
}