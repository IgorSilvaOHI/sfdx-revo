public class CargasSelector extends fflib_SObjectSelector 
	implements ICargasSelector
{

    private static FINAL String naoIniciado = 'Não Iniciado';
    
    public static ICargasSelector newInstance()
	{
		return (ICargasSelector) Application.Selector.newInstance(Carga__c.SObjectType);
	}
    
    public CargasSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public CargasSelector()
    {
        super(true);

        this.setDataAccess(fflib_SObjectSelector.DataAccess.SYSTEM_MODE);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        return new List<Schema.FieldSet>	
        {	SobjectType.Carga__c.FieldSets.SelectFieldList	};
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Carga__c.Id,
            Carga__c.Name,
            Carga__c.Trecho__c,
           	Carga__c.Peso__c
		};
	}
    
    public List<Carga__c> selectByIdWithTrechosIniciados(Set<ID> idSet)
	{
        fflib_QueryFactory cargasQueryFactory = newQueryFactory();
 
      	/*fflib_SObjectSelector trechosSelector = new TrechosSelector();
      	trechosSelector.configureQueryFactoryFields(cargasQueryFactory, 'Trecho__r');*/

		return (List<Carga__c>) Database.query(
			cargasQueryFactory
            .setCondition('Id in :idSet AND Trecho__r.Status__c != :naoIniciado')
            .toSOQL());
	}
    
    public List<Carga__c> selectByVooId(Set<Id> vooId)
    {
        fflib_QueryFactory cargasQueryFactory = newQueryFactory();
        
        return (List<Carga__c>) Database.query(
            cargasQueryFactory
            .setCondition('Trecho__r.Voo__c IN :vooId')
            .toSOQL());
    }
    
    public Database.QueryLocator queryLocatorCargasDeletadas()
	{
        fflib_QueryFactory cargasQueryFactory = newQueryFactory();
 		
        new contentDocumentLinksSelector().
            addQueryFactorySubselect(cargasQueryFactory,'ContentDocumentLinks');
        
		return Database.getQueryLocator(
			cargasQueryFactory.setCondition('IsDeleted = true').toSOQL() + ' ALL ROWS');
	}
    
    public Schema.SObjectType getSObjectType()
	{
		return Carga__c.sObjectType;
	}
    
    public List<Carga__c> selectById(Set<ID> idSet)
	{
		return (List<Carga__c>) selectSObjectsById(idSet);
	}
}