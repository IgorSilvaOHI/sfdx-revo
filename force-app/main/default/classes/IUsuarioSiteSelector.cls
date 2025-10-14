public interface IUsuarioSiteSelector {

    UsuarioSite__c encontraPeloIdUsuarioSite(String idUsuarioSite);
    UsuarioSite__c encontraPelaConta(Id accountId);

}