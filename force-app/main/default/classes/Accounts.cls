public with sharing class Accounts extends fflib_SObjectDomain implements IAccounts
{
    public Accounts(List<Account> sObjectList)
    {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Accounts(sObjectList);
        }
    }

    public static Account atualizaContaUsuarioSite(
        fflib_ISObjectUnitOfWork uow, Id contaId, String nome, String genero, Date nascimento, String tipoDocumento, String documento, String cpf,    
        String contatoEmergencia, String telefoneEmergencia, Boolean temEspecialidade, String especialidade, String endereco, String cidade, String estado, String zipcode, String pais, String complemento, 
        String nacionalidade, String linguagem, String email, String telefone, String title
    ) {
        List<String> nomes = nome.split(' ');

        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Account').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id ClientePJ = null;
        Id ClientePF = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'ClientePJ') {
                ClientePJ = rtInfo.getRecordTypeId();
            }

            if (rtInfo.getDeveloperName() == 'ClientePF') {
                ClientePF = rtInfo.getRecordTypeId();
            }
        }

        if(String.isBlank(tipoDocumento)) {
            throw new TipoDocumentoNaoInformadoException(true);
        }

        if(String.isBlank(documento)) {
            throw new DocumentoNaoInformadoException(true);
        }

        Account conta = new Account();

        conta.Id = contaId;
        conta.recordTypeId = tipoDocumento.toUpperCase() == 'CNPJ' ? ClientePJ : ClientePF;
        
        if (conta.recordTypeId == ClientePF) {
            conta.FirstName = nomes.size() > 1 ? nomes[0] : '';
            conta.LastName = nome.replace(nomes[0] + ' ', '');
            conta.CNPJCPF__c = tipoDocumento.toUpperCase() == 'CPF' ? documento : cpf;
            conta.PersonGenderIdentity = genero;
            conta.PersonBirthdate = nascimento;
            conta.TipoDocumento__pc = tipoDocumento;
            conta.NumeroDocumento__pc = documento;
            conta.Nacionalidade__pc = nacionalidade;
            conta.Salutation = title;
            conta.PersonEmail = email;
            conta.PersonAssistantName = contatoEmergencia;
            conta.PersonAssistantPhone = telefoneEmergencia;
            conta.PossuiNecessidadesEspeciais__pc = temEspecialidade;
            conta.NecessidadesEspeciais__pc = especialidade;
        } else {
            conta.name = nome;
            conta.RazaoSocial__c = nome;
            conta.CNPJCPF__c = documento;
            conta.Email__c = email;
        }

        conta.Idioma__c = linguagem;

        conta.Phone = telefone;
        conta.BillingStreet = endereco;
        conta.BillingCity = cidade;
        conta.BillingState = estado;
        conta.BillingPostalCode = zipcode;
        conta.BillingCountry = pais;
        conta.ComplementoCobranca__c = complemento;

        if (contaId == null)
        {
            uow.registerNew(conta);
        } else {
            uow.registerDirty(conta);
        }

        return conta;
    }    
        
    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        for (Account acc : (List<Account>)records)
        {
            validaInscricaoEstadual(acc);
        }        
    }
    
        
    public override void onValidate()
    {
        for (Account acc : (List<Account>)records)
        {
            validaInscricaoEstadual(acc);
        }        
    }
    
    private void validaInscricaoEstadual(Account acc)
    {
        if (String.isNotBlank(acc.ShippingState) && String.isNotBlank(acc.InscricaoEstadual__c) && 
            acc.InscricaoEstadual__c.toUpperCase() <> 'ISENTO')
        {
            try
            {
                Estado e = Utils.getEstado(acc.ShippingState);
                if ( !((ValidadorIEFactory.newInstance(e)).execute(acc.InscricaoEstadual__c)) )
                {
                    acc.InscricaoEstadual__c.addError(Label.InscricaoEstadualInvalida);
                }  
            }
            catch (ValidadorIE.ValidadorException ve)
            {
                acc.InscricaoEstadual__c.addError(ve.getMessage());
            }
            catch (Exception e)
            {
                acc.ShippingState.addError(Label.PreenchaValorValido);
            }
        }
    }    
    
    public class EstadoInexistenteException extends Exception {}

    public class TipoDocumentoNaoInformadoException extends Exception {
        public TipoDocumentoNaoInformadoException(Boolean voidParam) {
            this('CAV-0001: Campo Tipo de Documento do Usuário Obrigatório!');
        }
    }

    public class DocumentoNaoInformadoException extends Exception {
        public DocumentoNaoInformadoException(Boolean voidParam) {
            this('CAV-0002: Campo Documento do Usuário Obrigatório!');
        }
    }
}