public interface IContatosSelector extends fflib_ISObjectSelector
{
    List<Contact> selectById(Set<ID> idSet);
    List<Contact> selectContatosByVooId(Set<Id> voosId);
    List<Contact> selectNaoInclusos(Set<Id> contatosId, String filtro);
    List<Contact> selectContactsByDocuments(Set<String> tipoDocumentos, Set<String> documentos);    
}