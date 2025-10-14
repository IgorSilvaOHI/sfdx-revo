public class AccountsSelector extends fflib_SObjectSelector 
	implements IAccountsSelector
{

    public static IAccountsSelector newInstance()
	{
		return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
	}
    
    public AccountsSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
        
    }
    
    public AccountsSelector()
    {
        super(true);
        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);        
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet> 
        {	
            SobjectType.Account.FieldSets.SelectFieldList	
		};
	}
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Account.Id,
                Account.BillingState,
                Account.Name,
                Account.ParentId,
               	Account.OwnerId,
                Account.Parent.Name,
                Account.Parent.Id
		};
	}

    public Schema.SObjectType getSObjectType()
	{
		return Account.sObjectType;
	}
    
    public List<Account> selectById(Set<ID> idSet)
	{
		return (List<Account>) selectSObjectsById(idSet);
	}

    public Account selectById(Id id)
	{
        List<Account> accounts = (List<Account>) selectSObjectsById(new Set<Id> { id });
        
		return accounts.size() > 0 ? accounts[0] : null;
	}
    
    public List<Account> selectAll()
    {
        fflib_QueryFactory query = newQueryFactory();
        return (List<Account>) Database.query(query.toSOQL());
    }

    public List<Account> selectAccountsByCNPJ(Set<String> cnpjs) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('RecordType.DeveloperName = \'ClientePJ\' And ' +
                           'CNPJCPF__c IN :cnpjs');
        
        return (List<Account>) Database.query(query.toSOQL());
    }
    
    public List<Account> selectAccountsByPersonEmail(Set<String> emails) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('RecordType.DeveloperName = \'ClientePF\' And ' +
                           'PersonEmail IN :emails');
        
        return (List<Account>) Database.query(query.toSOQL());
    }    

    public List<Account> selectPersonsByDocuments(Set<String> tipoDocumentos, Set<String> documentos) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('RecordType.DeveloperName = \'ClientePF\' And ' +
                           'TipoDocumento__pc IN :tipoDocumentos AND NumeroDocumento__pc IN :documentos');
        
        return (List<Account>) Database.query(query.toSOQL());
    }

    public List<Account> selectByIdWithRelatedContacts(Id accountId, Set<Id> contactsToRemove)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id = :accountId');
        query
            .subselectQuery('AccountContactRelations')
            .setCondition('ContactId NOT IN :contactsToRemove')
            .selectField('ContactId')
            .selectField('Contact.Name')
            .setOrdering('Contact.Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Account>) Database.query(query.toSOQL());
    }
    
    public List<Account> selectByParentIdWithRelatedContacts(Set<Id> parentIds, Set<Id> contactsToRemove)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('ParentId IN :parentIds');
        query
            .subselectQuery('AccountContactRelations')
            .setCondition('ContactId NOT IN :contactsToRemove')
            .selectField('ContactId')
            .selectField('Contact.Name')
            .setOrdering('Contact.Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Account>) Database.query(query.toSOQL());
    }
    
    public List<Account> selectByName(Set<String> names)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name IN :names');
        
        return (List<Account>) Database.query(query.toSOQL());
    }
}