public class EmailPassageiroRemovido 
{
    public static void sendEmail()
    {
        Set<Id> idsVoo = new Set<Id>();
        Set<Id> idsContato = new Set<Id>();
        List<id> idsTrechosLista = new List<Id>();
        
        for (Passageiro__c passageiro : (List<Passageiro__c>)Trigger.old)
        {
            if(passageiro.EmailEnviado__c)
            {
                idsVoo.add(passageiro.idVoo__c);
                idsContato.add(passageiro.Contato__c);   
            }
        }
        List<Passageiro__c> passageiros = PassageirosSelector.newInstance().selectByVooId(idsVoo);
        
        Map<Id, Map<Id, List<Passageiro__c>>> vooContatoPassageiro = new Map<Id, Map<Id, List<Passageiro__c>>>();
        
        for(Id idVoo : idsVoo)
        {
            //System.debug(passageiros);
            vooContatoPassageiro.put(idVoo, montarMapContato(idVoo, idsContato, passageiros));
        }
        if (!idsVoo.isEmpty())
        {
            Messaging.sendEmail(montarEmail(vooContatoPassageiro, ConfiguracoesGerais__c.getOrgDefaults().IdTemplateEmailPassageiroRemovido__c));
        }
    }
    public static List<Messaging.SingleEmailMessage> montarEmail(Map<Id, Map<Id, List<Passageiro__c>>> vooContatoPassageiro, Id templateId)
    {
        Id idOrgWideEmailAddres = ConfiguracoesGerais__c.getOrgDefaults().IdRemetentePassageiroRemovido__c;
        Map<Id, Messaging.SingleEmailMessage> mails = new Map<Id, Messaging.SingleEmailMessage>();
        
        for (Passageiro__c passageiro : (List<Passageiro__c>)Trigger.old)
        {
            if(vooContatoPassageiro.get(passageiro.IdVoo__c).get(passageiro.Contato__c).size() == 0 &&
              !mails.containsKey(passageiro.Contato__c))
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setTemplateId(templateId);
                mail.setTargetobjectid(passageiro.Contato__c);
                mail.setWhatid(passageiro.IdVoo__c);
                mail.setOrgWideEmailAddressId(idOrgWideEmailAddres);
                //mail.setSenderDisplayName(Label.RemetenteEmail);
                mails.put(passageiro.Contato__c, mail);
            }
        }
        return mails.values();
    }
    public static Map<Id, List<Passageiro__c>> montarMapContato(Id idVoo, Set<Id> idsContato, List<Passageiro__c> passageiros)
    {
        Map<Id, List<Passageiro__c>> contatoComPassageiros = new Map<Id, List<Passageiro__c>>();
        
        for (Id idContato : idsContato)
        {
            List<Passageiro__c> passageirosPorContato = new List<Passageiro__c>();
            for(Passageiro__c passageiro : passageiros)
            {
                if(passageiro.Contato__c == idContato && passageiro.IdVoo__c == idVoo && 
                   !passageirosPorContato.contains(passageiro))
                {
                    passageirosPorContato.add(passageiro);
                }
            }
            contatoComPassageiros.put(idContato, passageirosPorContato);
        }
        return contatoComPassageiros;
    }
}