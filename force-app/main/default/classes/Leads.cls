public with sharing class Leads extends fflib_SObjectDomain implements ILeads
{
    
    public Leads(List<Lead> sObjectList)
    {
        super(sObjectList);
    }
    
    public static ILeads newInstance(List<Lead> sObjectList)
    {
        return (ILeads) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Leads(sObjectList);
        }
    }
    
    public List<Lead> getLeads()
    {
        return (List<Lead>)records;
    }


    public String webSiteUserId { get; set; }
    public String fullName { get; set; }
    public String gender { get; set; }
    public String email { get; set; }
    public String phone { get; set; }

    public static Lead qualificaLeadSite(
        fflib_ISObjectUnitOfWork uow, Id leadId
    ) {
        Lead dica = new Lead();
        dica.Id = leadId;
        dica.Status = 'Qualificado';

        uow.registerDirty(dica);

        return dica;
    }    

    public static Lead atualizaLeadUsuarioSite(
        fflib_ISObjectUnitOfWork uow, Id leadId, String nome, String genero, Date nascimento, String tipoDocumento, String documento, String cpf,
        String contatoEmergencia, String telefoneEmergencia, Boolean temEspecialidade, String especialidade, String endereco, String cidade, String estado, String zipcode, String pais, String complemento, 
        String nacionalidade, String linguagem, String leadSource, String email, String celular, string title
    ) {
        List<String> nomes = nome.split(' ');

        Lead dica = new Lead();
        dica.Id = leadId;
        dica.FirstName = nomes.size() > 1 ? nomes[0] : '';
        dica.LastName = nome.replace(nomes[0] + ' ', '');
        dica.Salutation = title;
        dica.GenderIdentity = genero;
        dica.DataNascimento__c = nascimento;
        dica.CNPJCPF__c = tipoDocumento == 'CPF' ? documento : cpf;
        dica.TipoDocumento__c = tipoDocumento;
        dica.NumeroDocumento__c = documento;
        dica.Nacionalidade__c = nacionalidade;

        dica.Idioma__c = linguagem;
        dica.LeadSource = leadSource;
        dica.Email = email;
        dica.Phone = celular;

        dica.Street = endereco;
        dica.City = cidade;
        dica.State = estado;
        dica.PostalCode = zipcode;
        dica.Country = pais;
        dica.Complemento__c = complemento;        

        dica.ContatoEmergencia__c = contatoEmergencia;
        dica.TelefoneEmergencia__c = telefoneEmergencia;
        dica.PossuiNecessidadesEspeciais__c = temEspecialidade;
        dica.NecessidadesEspeciais__c = especialidade;

        if (leadId == null)
        {
            uow.registerNew(dica);
        } else {
            uow.registerDirty(dica);
        }

        return dica;
    }
    
}