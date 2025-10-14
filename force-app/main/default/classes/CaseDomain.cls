public class CaseDomain extends SObjectDomain {
    protected override Schema.SObjectType getSObjectType() {
        return Case.sObjectType;
    }
    
    protected override Map<Id, Schema.RecordTypeInfo> getRecordTypeInfosById() {
        return Schema.SObjectType.Case.getRecordTypeInfosById();
    }
    
    public CaseDomain() {
    }
    
    public List<Case> newInstance(List<Id> idTabulacoes, List<Id> recordIds, List<Id> lastCaseIds) {
        List<Case> casos = newInstance(idTabulacoes);
        
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        List<Id> protocolIds = new List<Id>();
        
        AccountSelector accountSel = new AccountSelector();
        ContactSelector contactSel = new ContactSelector();
        CaseSelector caseSel = new CaseSelector();
        ProtocoloSelector protocoloSel = new ProtocoloSelector();
        
        for (Id recordId : recordIds) {
            String objectType = recordId.getSObjectType().getDescribe().getName();
            
            if (objectType == 'Account') {
                accountIds.add(recordId);
            } else if (objectType == 'Contact') {
                contactIds.add(recordId);
            } else if (objectType == 'Case') {
                caseIds.add(recordId);
            } else if (objectType == 'Protocolo__c') {
                protocolIds.add(recordId);
            }
        }
        
        Map<Id, Account> accounts = new Map<Id, Account>(
            (List<Account>) accountSel.selectIn(accountIds)
        );
        Map<Id, Contact> contacts = new Map<Id, Contact>(
            (List<Contact>) contactSel.selectIn(contactIds)
        );
        Map<Id, Case> cases = new Map<Id, Case>(
            (List<Case>) caseSel.selectIn(caseIds)
        );
        Map<Id, Protocolo__c> protocols = new Map<Id, Protocolo__c>(
            (List<Protocolo__c>) protocoloSel.selectIn(protocolIds)
        );
        Map<Id, Case> lastCases = new Map<Id, Case>(
            (List<Case>) caseSel.selectIn(lastCaseIds)
        );
        
        for (Integer i = 0; i < casos.size(); i++) {
            Case newCase = casos.get(i);
            Id recordId = recordIds.get(i);
            
            String objectType = recordId.getSObjectType().getDescribe().getName();
            
            if (objectType == 'Account') {
                Account account = accounts.get(recordId);
                newCase.AccountId = account.Id;
                newCase.ContactId = account.PersonContactId;
            } else if (objectType == 'Contact') {
                Contact contact = contacts.get(recordId);
                newCase.AccountId = contact.AccountId;
                newCase.ContactId = contact.Id;
            } else if (objectType == 'Case') {
                Case parentCase = cases.get(recordId);
                newCase.AccountId = parentCase.AccountId;
                newCase.ContactId = parentCase.ContactId;
                newCase.ParentId = parentCase.Id;
                newCase.Origin = parentCase.Origin;
                
                Id lastCaseId = lastCaseIds.size() >= i ? lastCaseIds.get(i) : null;

                newCase.casoAnterior__c = lastCaseId;
                
                Case baseCase = null;
                
                if (lastCases.containsKey(lastCaseId)) {
                    baseCase = lastCases.get(lastCaseId);
                } else {
                    baseCase = parentCase;
                }
                
                newCase.Voo__c = baseCase.Voo__c;
                newCase.Passageiro__c = baseCase.Passageiro__c;
                newCase.Servico__c = baseCase.Servico__c;
                newCase.Pagamento__c = baseCase.Pagamento__c;
                
            } else if (objectType == 'Protocolo__c') {
                Protocolo__c protocolo = protocols.get(recordId);
                newCase.AccountId = protocolo.Conta__c;
                newCase.ContactId = protocolo.Contato__c;
                newCase.Protocolo__c = protocolo.Id;
                newCase.Origin = protocolo.OrigemProtocolo__c;
                newCase.SourceId = protocolo.OrigemProtocoloMessaging__c;
            }
        }
        
        return casos;
    }
    
    public List<Case> newInstance(List<Id> idTabulacoes) {
        TabulacaoSelector seletorTabulacao = new TabulacaoSelector();
        Map<Id, Tabulacao__c> tabulacoes = new Map<Id, Tabulacao__c>(
            (List<Tabulacao__c>) seletorTabulacao.selectIn(idTabulacoes)
        );
        List<Case> newCases = new List<Case>();
        
        for (Id idTabulacao : idTabulacoes) {
            Tabulacao__c tabulacao = tabulacoes.get(idTabulacao);
            Case newCase = new Case();
            
            changeInstance(newCase, tabulacao);
            
            newCases.add(newCase);
        }
        
        return newCases;
    }
    
    public void changeInstance(Case newCase, Tabulacao__c tabulacao) {
        newCase.Subject = tabulacao.Name;
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get(tabulacao.RecordType.DeveloperName)
            .getRecordTypeId();
        newCase.Type = tabulacao.TipoCasoPadrao__c;
        newCase.Priority = tabulacao.PrioridadeCasoPadrao__c;
        newCase.Description = tabulacao.DescricaoCasoPadrao__c;
        newCase.EntitlementId = tabulacao.DireitoPadrao__c;
        newCase.Status = tabulacao.RecordType.DeveloperName == 'FluxoTrabalho'
            ? 'Aberto'
            : 'Em Andamento';
        newCase.Tabulacao__c = tabulacao.Id;
    }
    
    public AssignmentRule standardAssignmentRule() {
        List<AssignmentRule> defaultAr = [
            SELECT id
            FROM AssignmentRule
            WHERE SobjectType = 'Case' AND Active = TRUE
            LIMIT 1
        ];
        return defaultAr.size() > 0 ? defaultAr.get(0) : null;
    }
    
    public void applyAssignmentRule(List<Case> newCases) {

        TabulacaoSelector seletorTabulacao = new TabulacaoSelector();
        AccountSelector seletorContas = new AccountSelector();
        
        Map<Id, Tabulacao__c> tabulacoes = new Map<Id, Tabulacao__c>(
            (List<Tabulacao__c>) seletorTabulacao.selectIn(SObjectSelectorUtil.ExtractIds(newCases, 'Tabulacao__c'))
        );

        Map<Id, Account> contas = new Map<Id, Account>(
            (List<Account>) seletorContas.selectIn(SObjectSelectorUtil.ExtractIds(newCases, 'AccountId'))
        );
        
        List<String> filas = new List<String>();
        
        for (Tabulacao__c tb : tabulacoes.values()) {
            if (tb.TipoAtribuicao__c == 'Fila Salesforce' && !String.IsEmpty(tb.CodigoAtribuicao__c)) 
                filas.add(tb.CodigoAtribuicao__c);
        }
        
        Map<String, List<Group>> filaMap = (Map<String, List<Group>>)SObjectSelectorUtil.BreakByString(
            [Select Id, DeveloperName From Group Where Type = 'Queue' And DeveloperName IN :filas], 'DeveloperName');

        
        AssignmentRule defaultAr = standardAssignmentRule();
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        
        if (defaultAr != null) {
            dmlOpts.assignmentRuleHeader.assignmentRuleId = defaultAr.Id;
        }
            
        for (Case newCase : newCases) {
            Tabulacao__c tabulacao = tabulacoes.get(newCase.Tabulacao__c);
            
            if (tabulacao.TipoAtribuicao__c == 'Criador do Caso') continue;

            if (tabulacao.TipoAtribuicao__c == 'Fila Salesforce' && 
                !String.IsEmpty(tabulacao.CodigoAtribuicao__c) && 
                filaMap.containskey(tabulacao.CodigoAtribuicao__c)) 
            {
                newCase.OwnerId = filaMap.get(tabulacao.CodigoAtribuicao__c)[0].Id;
            }
            
            if (tabulacao.TipoAtribuicao__c == 'Proprietário da Conta') {
                newCase.OwnerId = contas.get(newCase.AccountId).OwnerId;
            }
            
            if (tabulacao.TipoAtribuicao__c == 'Regra de Atribuição' && 
                defaultAr != null && !String.IsEmpty(tabulacao.CodigoAtribuicao__c)) {
                newCase.setOptions(dmlOpts);
            }
        }
        
    }    
    
    @TestVisible
    protected override void onBeforeInsert() {
        super.onBeforeInsert();
        
        System.debug('context CaseDomain Operation: ' + context.Operation);
        if (context.News != null)
            System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
            System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    
    @TestVisible
    protected override void onBeforeUpdate() {
        super.onBeforeUpdate();
        
        System.debug('context CaseDomain Operation: ' + context.Operation);
        if (context.News != null)
            System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
            System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    
    @TestVisible
    protected override void onAfterInsert() {
        super.onAfterInsert();
        
        System.debug('context CaseDomain Operation: ' + context.Operation);
        if (context.News != null)
            System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
            System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    
    @TestVisible
    protected override void onAfterUpdate() {
        super.onAfterUpdate();
        
        System.debug('context CaseDomain Operation: ' + context.Operation);
        if (context.News != null)
            System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
            System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
}