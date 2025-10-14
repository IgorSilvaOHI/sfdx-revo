public class InsereCasoTabulacaoController {
    @AuraEnabled
    public static List<Tabulacao__c> buscaTabulacao(
        String textParam,
        Id recordId,
        Boolean flgInterno
    ) {
        TabulacaoSelector selector = new TabulacaoSelector();
        
        return selector.FindFluxoDeTrabalho(
            textParam,
            getAccountType(recordId),
            flgInterno
        );
    }
    
    @AuraEnabled
    public static Case insereCasoTabulacao(Id idTabulacao, Id recordId) {
        CaseSelector seletorCaso = new CaseSelector();
        List<Id> idTabulacoes = new List<Id>();
        List<Id> idRecords = new List<Id>();
        List<Id> lastIdCase = new List<Id>();

        CaseDomain domain = new CaseDomain();

        Boolean fluxoNaoTabulado = false;
        Case casoResult = null;

        String objectType = recordId.getSObjectType().getDescribe().getName();

        if (objectType == 'Case') {
            casoResult = (Case) seletorCaso.SelectId(recordId);

            if (casoResult.Tabulacao__c == null) {
                fluxoNaoTabulado = true;
            }
        }

        if (!fluxoNaoTabulado) {
            
            idTabulacoes.add(idTabulacao);
            idRecords.add(recordId);
            lastIdCase.add(null);
            
            List<Case> casos = domain.newInstance(idTabulacoes, idRecords, lastIdCase);
            domain.applyAssignmentRule(casos);
            
            casoResult = casos.get(0);

            insert casos;
        } else {
            casoResult.Tabulacao__c = idTabulacao;
            domain.applyAssignmentRule(new List<Case> { casoResult });
            
            update casoResult;
        }
        
        return casoResult;
    }
    
    @TestVisible
    private static string getAccountType(Id recordId) {
        AccountSelector seletorConta = new AccountSelector();
        ContactSelector seletorContato = new ContactSelector();
        CaseSelector seletorCaso = new CaseSelector();
        ProtocoloSelector seletorProtocolo = new ProtocoloSelector();
        
        String objectType = recordId.getSObjectType().getDescribe().getName();
        
        if (objectType == 'Account') {
            Account conta = (Account) seletorConta.SelectId(recordId);
            
            return Schema.getGlobalDescribe()
                .get('Account')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(conta.RecordTypeId)
                .getName();
        } else if (objectType == 'Contact') {
            Contact contato = (Contact) seletorContato.SelectId(recordId);
            
            if (contato.Account == null)
                return '';
            
            return Schema.getGlobalDescribe()
                .get('Account')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(contato.Account.RecordTypeId)
                .getName();
        } else if (objectType == 'Case') {
            Case caso = (Case) seletorCaso.SelectId(recordId);
            
            if (caso.Account == null)
                return '';
            
            return Schema.getGlobalDescribe()
                .get('Account')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(caso.Account.RecordTypeId)
                .getName();
        } else if (objectType == 'Protocolo__c') {
            Protocolo__c protocolo = (Protocolo__c) seletorProtocolo.SelectId(
                recordId
            );
            
            if (protocolo.Conta__r == null)
                return '';
            
            return Schema.getGlobalDescribe()
                .get('Account')
                .getDescribe()
                .getRecordTypeInfosById()
                .get(protocolo.Conta__r.RecordTypeId)
                .getName();
        }
        
        return '';
    }
}