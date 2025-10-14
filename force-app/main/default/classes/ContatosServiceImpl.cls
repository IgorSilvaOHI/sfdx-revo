public class ContatosServiceImpl implements IContatosService{
    
    public String getContatosNaoInclusos(List<Id> contatosId, String filtro)
    {
        Set<Id> contatosIdSet = Utils.getSetIdsByListIds(contatosId);
        List<Contact> contatos = ContatosSelector.newInstance().selectNaoInclusos(contatosIdSet, filtro);
        Map<Id, Contact> mapContatos = new Map<Id, Contact>(contatos);
        return JSON.serialize(mapContatos);
    }
}