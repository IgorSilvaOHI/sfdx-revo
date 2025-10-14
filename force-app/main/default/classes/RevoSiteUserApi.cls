@RestResource(urlMapping='/revosite/v1/siteuser/*')
global without sharing class RevoSiteUserApi {

    @HttpPost
    global static void insertUpdate(RevoSiteUser siteUser) {
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            UsuarioSite__c usuario = UsuarioSiteSelector.newInstance().encontraPeloIdUsuarioSite(siteUser.webSiteUserId);
            
            Id leadid = usuario == null ? null : usuario.Lead__c;
            Id accountId = usuario == null ? null : usuario.Conta__c;
            Id usuarioId = usuario == null ? null : usuario.Id;

            Account conta = null;

            usuario = UsuarioSite.atualizaUsuarioSite(uow, usuarioId, siteUser.fullName, siteUser.webSiteUserId);

            if (accountId == null) {
                conta = procuraContaUsuarioSite(siteUser);
                accountId = conta == null ? null : conta.Id;
            }

            if (conta != null) {
                uow.registerRelationship(usuario, UsuarioSite__c.Conta__c, conta);
            }

            atualizaContaUsuarioSite(uow, siteUser, usuario, accountId, leadid);

            uow.commitWork();
        } catch (Exception e) {
            RevoSiteApi.standardBadResult(e);
        }
    }

    private static void atualizaContaUsuarioSite(fflib_ISObjectUnitOfWork uow, RevoSiteUser siteUser, UsuarioSite__c usuario, Id accountId, Id leadid){

        if (accountId != null && String.isNotBlank(siteUser.document) && String.isNotBlank(siteUser.documentType)) {
            Account conta = Accounts.atualizaContaUsuarioSite(
                uow, accountId, siteUser.fullName, siteUser.gender, siteUser.birthDate, siteUser.documentType, siteUser.document, 
                siteUser.cpf, siteUser.emergencyContactName, siteUser.emergencyContactPhone, siteUser.hasSpecialNeeds, siteUser.specialNeeds, 
                siteUser.address , siteUser.city, siteUser.state, siteUser.zipcode, siteUser.country, siteUser.addressLine2, 
                siteUser.nationality, siteUser.language, siteUser.email, siteUser.phone, siteUser.title
            );

            uow.registerRelationship(usuario, UsuarioSite__c.Conta__c, conta);
        } else {
            Lead dica = Leads.atualizaLeadUsuarioSite(
                uow, leadid, siteUser.fullName, siteUser.gender, siteUser.birthDate, siteUser.documentType, siteUser.document,
                siteUser.cpf, siteUser.emergencyContactName, siteUser.emergencyContactPhone, siteUser.hasSpecialNeeds, siteUser.specialNeeds, 
                siteUser.address , siteUser.city, siteUser.state, siteUser.zipcode, siteUser.country, siteUser.addressLine2, 
                siteUser.nationality, siteUser.language, 'WebSite', siteUser.email, siteUser.phone, siteUser.title
            );

            uow.registerRelationship(usuario, UsuarioSite__c.Lead__c, dica);
        }     
    }

    private static Account procuraContaUsuarioSite(RevoSiteUser siteUser){

        List<Account> contasSf = AccountsSelector.newInstance().selectAccountsByPersonEmail(
            new Set<String> { siteUser.email }
        );

        return contasSf.isEmpty() ? null : contasSf[0];
    }

    global class RevoSiteUser {

        public String webSiteUserId { get; set; }

        public String fullName { get; set; }
        public String title { get; set; }
        public String gender { get; set; }
        public Date birthDate { get; set; }
        public String nationality { get; set; }

        public String documentType { get; set; }
        public String document { get; set; }
        public String cpf { get; set; }

        public String emergencyContactName { get; set; }
        public String emergencyContactPhone { get; set; }
        public Boolean hasSpecialNeeds { get; set; }
        public String specialNeeds { get; set; }        

        public String address { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String zipcode { get; set; }
        public String country { get; set; }
        public String addressLine2 { get; set; }        

        public String language { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
    }

}