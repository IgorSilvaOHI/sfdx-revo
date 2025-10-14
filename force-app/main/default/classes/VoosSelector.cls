public class VoosSelector extends fflib_SObjectSelector
    implements IVoosSelector
{

    public static IVoosSelector newInstance()
    {
        return (IVoosSelector) Application.Selector.newInstance(Voo__c.SObjectType);
    }
    
    public VoosSelector(Boolean includeFieldSetFields) 
    {
        super(includeFieldSetFields);
    }
    
    public VoosSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>    
        {   SobjectType.Voo__c.FieldSets.SelectFieldList    };
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Voo__c.Id,
            Voo__c.Status__c,
            Voo__c.Rota__c,
            Voo__c.RotaCompleta__c,
            Voo__c.DataVoo__c,
            Voo__c.Observacoes__c,    
            Voo__c.CreatedDate,
            Voo__c.Name,
            Voo__c.Comandante__c,
            Voo__c.Copiloto__c,
            Voo__c.Comissario__c,
            Voo__c.Prefixo__c,
            Voo__c.Prefixo__r.Name, 
            Voo__c.PrefixoTexto__c,
            Voo__c.Cliente__c.Name,
            Voo__c.QtdTrechosOrigemOffshore__c,
            Voo__c.PAD__c,    
            Voo__c.TipoPAD__c,
            Voo__c.RelatorioVoo__c,
            Voo__c.DiaVoo__c,
            Voo__c.MEDVAC__c,
            Voo__c.SAR2__c,
            Voo__c.Spot__c,
            Voo__c.ReceitaVoo__c
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Voo__c.sObjectType;
    }
    
    public List<Voo__c> selectById(Set<ID> idSet)
    {
        return (List<Voo__c>) selectSObjectsById(idSet);
    }
    
    public List<Voo__c> selectDeletedById(Set<Id> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('IsDeleted = true AND Id IN :idSet');
        return (List<Voo__c>) Database.query(query.toSOQL() + ' ALL ROWS');
    }
    
    public List<Voo__c> selectWithTrechosById(Set<Id> vooId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :vooId');
        
        fflib_SObjectSelector aeronaves = new AeronavesSelector();
        aeronaves.configureQueryFactoryFields(query, 'Prefixo__r');
        
        new TrechosSelector().addQueryFactorySubselect(query, 'Trechos__r')
            .selectField('Origem__r.Name')
            .selectField('Origem__r.CodigoLocal__c')
            .selectField('Destino__r.Name')
            .selectField('Destino__r.CodigoLocal__c')
            .selectField('PrimeiroTrechoFixo__c')
            .selectField('TrechoAnterior__c')
            .selectField('Tipo__c')
            .selectField('PrimeiroTrechoFixo__c')
            .selectField('PousoTrechoAnterior__c')
            .selectField('TipoHoraFaturamento__c')
            .setOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectWithPrimeiroTrechoById(Set<Id> vooId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :vooId');
        
        new TrechosSelector().addQueryFactorySubselect(query, 'Trechos__r')
            .setCondition('PrimeiroTrecho__c = TRUE');
        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectByIdWithLead(Set<Id> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :idSet');
        
        fflib_SObjectSelector leadsSelector = new LeadsSelector();
        leadsSelector.configureQueryFactoryFields(query, 'LeadGerouVoo__r');
        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectRecentsWithTrechos()
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        query.setCondition('QtdTrechos__c > 1');
        query.setLimit(2000);
        
        fflib_QueryFactory trechosQuery = new TrechosSelector().addQueryFactorySubselect(query, 'Trechos__r');
        trechosQuery.setOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> getVoosAmanhaByStatus(String status)
    {
        Time horainicio = Time.newInstance(0, 0, 0, 0);
        Time horafim = Time.newInstance(23, 59, 59, 0);
        Datetime inicioDia = Datetime.newInstance(Date.today().addDays(1), horainicio);
        Datetime fimDia = Datetime.newInstance(Date.today().addDays(1), horafim);
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('DataVoo__c >= :inicioDia AND DataVoo__c <= :fimDia AND Status__c = :status');
        
        fflib_QueryFactory trechosQuery = new TrechosSelector().addQueryFactorySubselect(query, 'Trechos__r');
        trechosQuery.setOrdering('OrdemExecucao__c', fflib_QueryFactory.SortOrder.ASCENDING);
        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectByIdWithCombinedAttachments(Set<Id> ids)
    {        
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :ids');
        
        query.subselectQuery('CombinedAttachments').selectField('Title');

        
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectByIdToInteressadosFaturamento(Set<Id> ids)
    {        
        Boolean enviado = false;
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id IN :ids AND FaturamentoInformado__c = :enviado');
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectWithPrefixosAndBetweenDates(Set<Id> prefixosIds, Date menorData, Date maiorData)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Prefixo__c IN :prefixosIds AND DataVoo__c >= :menorData AND DataVoo__c <= :maiorData');
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
    
    public List<Voo__c> selectRastreaveisBetweenDates(Datetime menorData, Datetime maiorData)
    {
        fflib_QueryFactory query = newQueryFactory();
        Set<String> rastreaveis = new Set<String>{Voos.RESERVADO, Voos.CONFIRMADO, Voos.ROTA};
        query.setCondition('Status__c IN :rastreaveis AND DataVoo__c >= :menorData AND DataVoo__c <= :maiorData');
        query.setOrdering('DataVoo__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
      
    public Voo__c getVoosToOOS(Id vooId)
    { 
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('IdExternoOOs__c');
        query.selectField('Prefixo__r.IdExternoOOs__c');
        query.selectField('Cliente__r.IdExternoOOs__c');
        query.setCondition('Id = :vooId');
        List<Voo__c> voos = (List<Voo__c>) Database.query( query.toSOQL() );
        if(voos.size()>0) return voos[0];
        return null;
    }

    public List<Voo__c> selectByAccountAndBetweenDates(Set<Id> accountIds, Date startDate, Date endDate)
    {
        fflib_QueryFactory query = newQueryFactory();
        String CANCELADO = Voos.CANCELADO;
        query.setCondition('Cliente__c IN :accountIds AND Status__c != :CANCELADO AND DiaVoo__c >= :startDate AND DiaVoo__c <= :endDate');
        query.setOrdering('DataVoo__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Voo__c>) Database.query(query.toSOQL());
    }
}