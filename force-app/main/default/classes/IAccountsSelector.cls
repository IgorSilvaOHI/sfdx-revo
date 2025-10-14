public interface IAccountsSelector extends fflib_ISObjectSelector
{
    Account selectById(Id id);
    List<Account> selectById(Set<ID> idSet);
    List<Account> selectAll();
    
    List<Account> selectAccountsByCNPJ(Set<String> cnpjs);
    List<Account> selectAccountsByPersonEmail(Set<String> emails);
    List<Account> selectPersonsByDocuments(Set<String> tipoDocumentos, Set<String> documentos);
    List<Account> selectByIdWithRelatedContacts(Id accountsIds, Set<Id> contactsToRemove);
    List<Account> selectByParentIdWithRelatedContacts(Set<Id> parentIds, Set<Id> contactsToRemove);
    List<Account> selectByName(Set<String> names);
}