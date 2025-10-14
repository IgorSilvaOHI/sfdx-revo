public class ContatosSelector extends fflib_SObjectSelector implements IContatosSelector
{    
    public ContatosSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public ContatosSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Contact.FieldSets.SelectFieldList	};
    }
    
    public static IContatosSelector newInstance()
    {
        return (IContatosSelector) Application.Selector.newInstance(Contact.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
				Contact.Id,
				Contact.LastName,
                Contact.Email,
                Contact.Idioma__c,
                Contact.FirstName,
                Contact.Nacionalidade__c,
                Contact.NumeroDocumento__c,
                Contact.Name,
                Contact.PossuiInteresse__c,
                Contact.Account.Name,
                Contact.TakeoffReport__c
		};
	}                  
    
    public Schema.SObjectType getSObjectType()
    {
        return Contact.sObjectType;
    }
    
    public List<Contact> selectById(Set<ID> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :idSet');
        //query.selectFieldSet(SObjectType.Contact.fieldSets.SelectFieldList);
        return (List<Contact>) Database.query(query.toSOQL());
    }
    
    public List<Contact> selectContatosByVooId(Set<Id> voosId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId in (SELECT Cliente__c FROM Voo__c WHERE Id in :voosId)');
        return (List<Contact>) Database.query(query.toSOQL());
    }
    
    public List<Contact> selectNaoInclusos(
        Set<Id> contatosId,
        String filtro
    ) {

        String passageiroRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Passageiro').getRecordTypeId();
        String clientePFRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ClientePF').getRecordTypeId();
        
        // Cria a QueryFactory com seu comportamento padrão (fields, ORDER BY padrão, etc.)
        fflib_QueryFactory query = newQueryFactory();

        // Monta o filtro dinâmico com curingas, evitando SOQL Injection
        if (String.isNotBlank(filtro)) {
            String filtroLike = '%' + String.escapeSingleQuotes(filtro) + '%';
            query.setCondition(
                '(RecordTypeId = :passageiroRecordTypeId OR Account.RecordTypeId = :clientePFRecordTypeId) ' +
                'AND Id NOT IN :contatosId ' +
                'AND (NumeroDocumento__c LIKE :filtroLike ' +
                '     OR Name               LIKE :filtroLike)'
            );
        } else {
            query.setCondition('(RecordTypeId = :passageiroRecordTypeId OR Account.RecordTypeId = :clientePFRecordTypeId) AND Id NOT IN :contatosId');
        }

        // Ordena pelo CreatedDate em ordem decrescente
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        query.setLimit(50);

        // Executa o SOQL dinâmico; os binds :contatosId e :filtroLike são resolvidos
        return (List<Contact>) Database.query(query.toSOQL());
    }

    public List<Contact> selectInteresseDailyReportFromAccounts(Set<Id> accountsId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('AccountId IN :accountsId AND DailyOperationsReport__c = true');        
        return (List<Contact>) Database.query(query.toSOQL());
    }
    
    public List<Contact> selectContactsByDocuments(Set<String> tipoDocumentos, Set<String> documentos) {
        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('TipoDocumento__c IN :tipoDocumentos AND NumeroDocumento__c IN :documentos');
        
        return (List<Contact>) Database.query(query.toSOQL());        
    }

    /*
    public List<Contact> selectContatosNaoInclusos(Set<Id> voosId)
    {
        fflib_QueryFactory query = newQueryFactory();
        //query.setCondition('Id NOT IN (SELECT Contato__c FROM Passageiro__c WHERE Trecho__r.Voo__c IN :voosId)');
        query.setLimit(20);
        
        return (List<Contact>) Database.query(query.toSOQL());
    }
*/
    
}