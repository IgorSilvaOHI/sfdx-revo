public class Contacts extends fflib_SObjectDomain implements IContacts {

    public Contacts(List<Contact> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IContacts newInstance(List<Contact> sObjectList)
    {
        return (IContacts) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Contacts(sObjectList);
        }
    }
    
    public String fullName { get; set; }
    public Date birthDate { get; set; }
    public String documentType { get; set; }
    public String document { get; set; }


    public static Contact criaContatoPassageiro(
        fflib_ISObjectUnitOfWork uow, String nacionalidade, String tipoDocumento, String documento, String nome, Date nascimento, 
        String email, String phone, String contatoEmergencia, String telefoneEmergencia, Boolean temEspecialidade, String especialidade
    ) {

        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Contact').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id Passageiro = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'Passageiro') {
                Passageiro = rtInfo.getRecordTypeId();
            }
        }

        List<String> nomes = nome.split(' ');

        Contact contato = new Contact();

        contato.RecordTypeId = Passageiro;
        contato.FirstName = nomes.size() > 1 ? nomes[0] : '';
        contato.LastName = nome.replace(nomes[0] + ' ', '');
        contato.Nacionalidade__c = nacionalidade;
        contato.TipoDocumento__c = tipoDocumento;
        contato.NumeroDocumento__c = documento;
        contato.Birthdate = nascimento;
        contato.Email = email;
        contato.Phone = phone;

        contato.AssistantName = contatoEmergencia;
        contato.AssistantPhone = telefoneEmergencia;
        contato.PossuiNecessidadesEspeciais__c = temEspecialidade;
        contato.NecessidadesEspeciais__c = especialidade;

        uow.registerNew(contato);

        return contato;
    }    

}