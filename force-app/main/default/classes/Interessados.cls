public without sharing class Interessados extends fflib_SObjectDomain implements IInteressados
{   
    public static FINAL String EDITAVEL = 'Editavel'; 
    private List<Trecho__c> trechos;
    private Map<Id, Voo__c> voos;
    private InteresseEnum interesse;
    
    public static FINAL Map<InteresseEnum, Schema.SObjectField> interesseWhatId = 
        new Map<InteresseEnum, Schema.SObjectField> 
    {             
            InteresseEnum.RESERVA => Interessado__c.Voo__c,
            InteresseEnum.CONCLUSAOVOO => Interessado__c.Voo__c,
            InteresseEnum.CONCLUSAOTRECHO => Trecho__c.Id,
            InteresseEnum.EMISSAOEMBARQUE => Interessado__c.Voo__c,
            InteresseEnum.FATURAMENTO => Interessado__c.Voo__c,
            InteresseEnum.TAKEOFFREPORT => Trecho__c.Id                
  	};
    
    public Interessados(List<Interessado__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IInteressados newInstance(List<Interessado__c> sObjectList)
    {
        return (IInteressados) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Interessados(sObjectList);
        }        
    }
    
    public void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template)
    {   
        for (Interessado__c interessado : (List<Interessado__c>)records)
        {
            registerInteresses(interessado, uow, template);            
        }        
    }
    
    public void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template, InteresseEnum interesse)
    {        
        this.interesse = interesse;
        registerEmails(uow, template);  
    }
    
    public void registerEmails(fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template, Map<Id, Voo__c> voos, InteresseEnum interesse)
    {        
        this.voos = voos;
        this.interesse = interesse;
        registerEmails(uow, template);  
    }
    
    //Verifica se o Contato (Interessado) possui INTERESSE em receber esse email específico
    public void registerInteresses(Interessado__c interessado, fflib_ISObjectUnitOfWork uow, TemplateEmail__mdt template)
    {
        String mensagemErro = '';
        
        Boolean condition = false;
        try
        {
            condition = (Boolean)interessado.get(template.APINameInteresse__c);                
        }
        catch (SObjectException e) 
        {
            mensagemErro += '[Ocorreu um erro ao enviar o email com template [' + template.MasterLabel + '], pois o campo [' + template.APINameInteresse__c + '] cadastrado como APINameInteresse__c não existe no objeto Interessado__c.] ';
        }
        catch (TypeException e)
        {
            mensagemErro += '[Ocorreu um erro ao enviar o email com template [' + template.MasterLabel + '], pois o campo [' + template.APINameInteresse__c + '] cadastrado como APINameInteresse__c não é do tipo Boolean no objeto Interessado__c.] ';
        }
        catch (Exception e)
        {
            mensagemErro += '[Ocorreu um erro inesperado ao enviar o email com template [' + template.MasterLabel + ']: ' + e.getMessage() +'] ';
        }
        
        if (condition)
        {
            List<EmailMessage> jaEnviado = EmailMessageSelector.newInstance().selectByRelatedToIdEmailTemplateId(getWhatId(interessado), template.Id__c);
        	if(jaEnviado.size() == 0) uow.registerEmail(createEmail(interessado, template.Id__c));
        } 
        
        interessado.MensagemErro__c = String.isNotBlank(mensagemErro) ? mensagemErro : '';
        
        if (String.isNotBlank(mensagemErro)) uow.registerDirty(interessado);
    }
    
    private Messaging.SingleEmailMessage createEmail(Interessado__c interessado, String templateId)
    {
        Id idOrgWideEmailAddres = ConfiguracoesGerais__c.getOrgDefaults().IdRemetenteInteressados__c;
        List<String> destinatarios = new List<String>();
        destinatarios.add(interessado.Contato__r.Email);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setTargetObjectId(interessado.Contato__c);
        email.setSaveAsActivity(true);
        email.setWhatId(getWhatId(interessado));
        email.setTemplateId(templateId);
        email.setOrgWideEmailAddressId(idOrgWideEmailAddres);
        email.toaddresses = destinatarios;
            
        return email;
    }

    private Id getWhatId(Interessado__c interessado)
    {
        Object value;
        SObject sObj = interessado;
        if (this.interesse == InteresseEnum.CONCLUSAOTRECHO || this.interesse == InteresseEnum.TAKEOFFREPORT)
        {
            Voo__c voo = voos.get(interessado.Voo__c);
            Trecho__c trecho = voo.Trechos__r.size() > 0 ? voo.Trechos__r.get(0) : null;
            sObj = trecho;
        }
        
        if (sObj != null)
        {
        	value = sObj.get(interesseWhatId.get(this.interesse));    
        }        
        
        return value != null ? Id.valueOf(String.valueOf(value)) : null;
    }
    
    public void criarInteressados(Set<Voo__c> vooSet, Set<Contact> contactSet, fflib_ISObjectUnitOfWork uow)
    {
        for(Contact contact : contactSet)
        {
            if(String.isNotBlank(contact.AccountId) && contact.PossuiInteresse__c)
            {
                for(Voo__c voo : vooSet)
                {
                    if(String.isNotBlank(voo.Cliente__c) && voo.Cliente__c.equals(contact.AccountId))
                    {
                        Interessado__c interessado = new Interessado__c();
                        interessado.RecordTypeId = Schema.SObjectType.Interessado__c.getRecordTypeInfosByDeveloperName().get(EDITAVEL).getRecordTypeId();
                        interessado.Reserva__c = contact.Reserva__c;
                        interessado.EmissaoEmbarque__c = contact.EmissaoEmbarque__c;
                        interessado.TakeOffReport__c = contact.TakeOffReport__c;
                        interessado.ConclusaoTrecho__c = contact.ConclusaoTrecho__c;
                        interessado.ConclusaoVoo__c = contact.ConclusaoVoo__c;
                        interessado.Faturamento__c = contact.Faturamento__c;
                        uow.registerNew(interessado);
                        uow.registerRelationship(interessado, Interessado__c.Voo__c, voo);
                        uow.registerRelationship(interessado, Interessado__c.Contato__c, contact);
                    }
                }
            }
        }
    }
}