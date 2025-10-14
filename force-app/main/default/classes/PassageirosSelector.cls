public class PassageirosSelector extends fflib_SObjectSelector
	implements IPassageirosSelector
{
	private FINAL String naoIniciado = 'Não Iniciado';
    
    public static IPassageirosSelector newInstance()
	{
		return (IPassageirosSelector) Application.Selector.newInstance(Passageiro__c.SObjectType);
	}
    
    public PassageirosSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public PassageirosSelector()
    {
        super(true);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Passageiro__c.FieldSets.SelectFieldList	};
    }

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Passageiro__c.Id,
            Passageiro__c.Bagagem__c,
            Passageiro__c.Peso__c,
           	Passageiro__c.Contato__c,
            Passageiro__c.Trecho__c,
            Passageiro__c.StatusVoo__c,
            Passageiro__c.NomeContato__c,
            Passageiro__c.Contato__c
            //Passageiro__c.Contato__r.Name
		};
	}
    
    public Schema.SObjectType getSObjectType()
	{
		return Passageiro__c.sObjectType;
	}
    
    public List<Passageiro__c> selectById(Set<ID> idSet)
	{
		return (List<Passageiro__c>) selectSObjectsById(idSet);
	}
    
    public List<Passageiro__c> selectByIdWithTrechosIniciados(Set<ID> idSet)
	{        
        fflib_QueryFactory passageirosQueryFactory = newQueryFactory();
 
      	fflib_SObjectSelector trechosSelector = new TrechosSelector();
      	trechosSelector.configureQueryFactoryFields(passageirosQueryFactory, 'Trecho__r');
        fflib_SObjectSelector ContatosSelector = new ContatosSelector();
      	trechosSelector.configureQueryFactoryFields(passageirosQueryFactory, 'Contato__r');

		return (List<Passageiro__c>) Database.query(
			passageirosQueryFactory
            .setCondition('Id in :idSet AND Trecho__c != null AND Trecho__r.Status__c != :naoIniciado')
            .toSOQL());
	}
    
    public List<Passageiro__c> selectByVooId(Set<Id> vooId)
    {
        fflib_QueryFactory passageirosQueryFactory = newQueryFactory();

        passageirosQueryFactory.subselectQuery('Servicos__r');    

        return (List<Passageiro__c>) Database.query(
            passageirosQueryFactory
            .setCondition('Trecho__r.Voo__c IN :vooId')
            .toSOQL());
    }
    /*public List<Passageiro__c> getPassageirosByContactIdsAndVooIds(Set<Id> idsContato, Set<Id> idsVoo)
    {
        fflib_QueryFactory passageirosQueryFactory = newQueryFactory();
        
        return (List<Passageiro__c>) Database.query(
            passageirosQueryFactory
            .setCondition('Contato__c IN :idsContato AND IdVoo__c IN :idsVoo')
            .toSOQL());
    }*/
    
    /* não utilizado mas fica de exemplo
    public List<PassageiroInfo> selectPassageiroInfo(Set<Id> idSet)
	{
		List<PassageiroInfo> passageiroInfos = new List<PassageiroInfo>();
		for(Passageiro__c passageiro : Database.query(
				newQueryFactory(false).
					selectField(Passageiro__c.Id).
					selectField(Passageiro__c.Bagagem__c).
            		selectField(Passageiro__c.Peso__c).
					selectField('Contato__r.Name').
					selectField('Contato__r.Email').
					selectField('Trecho__r.Status__c').
					setCondition('id in :idSet').
					toSOQL()))
			passageiroInfos.add(new PassageiroInfo(passageiro));
		return passageiroInfos;	
	}
    
    public class PassageiroInfo
	{		 
		private Passageiro__c passageiro;
		public Id Id { get { return passageiro.Id; } }		
        public Double Bagagem { get { return passageiro.Bagagem__c; } }
        public Double Peso { get { return passageiro.Peso__c; } }
		public String ContatoName { get { return passageiro.Contato__r.Name; } }		
		public String ContatoEmail { get { return passageiro.Contato__r.Email; } }		
		public String TrechoStatusDeveloper { get { return passageiro.Trecho__r.Status__c; } }
        public String TrechoStatus { get { return passageiro.Trecho__r.Status__c; } }
		private PassageiroInfo(Passageiro__c passageiro) { this.passageiro = passageiro; }		 
	}
	*/
}