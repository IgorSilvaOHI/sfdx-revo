public class UsuarioSite extends fflib_SObjectDomain implements IUsuarioSite {

    public UsuarioSite(List<UsuarioSite__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IUsuarioSite newInstance(List<UsuarioSite__c> sObjectList)
    {
        return (IUsuarioSite) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new UsuarioSite(sObjectList);
        }
    }
    

    public static UsuarioSite__c atualizaUsuarioSite(
        fflib_ISObjectUnitOfWork uow, Id usuarioId, String nome, String idSite
    ) {
        UsuarioSite__c usuario = new UsuarioSite__c();
        usuario.Id = usuarioId;
        usuario.Name = nome;
        usuario.IdSite__c = idSite;

        if (usuarioId == null)
        {
            uow.registerNew(usuario);        
        } else {
            uow.registerDirty(usuario);
        }        

        return usuario;
    }    

}