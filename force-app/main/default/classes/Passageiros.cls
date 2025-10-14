public class Passageiros extends fflib_SObjectDomain
	implements IPassageiros
{   
    public static IPassageiros newInstance(List<Passageiro__c> sObjectList)
	{
		return (IPassageiros) Application.Domain.newInstance(sObjectList);
	}
    
    public override void onBeforeDelete()
    {
        Map<Id, Passageiro__c> passageirosDeletadosJaIniciados = 
            new Map<Id, Passageiro__c>(PassageirosSelector.newInstance().selectByIdWithTrechosIniciados(Trigger.oldMap.keyset()));
        for (Passageiro__c passageiro : (List<Passageiro__c>)Records)
        {
            Utils.addErrorIfMapContainsObject(passageirosDeletadosJaIniciados, passageiro, System.Label.ErroRemoverPassageiro);
        }        
    }
    
    /*todo domain possui o construtor padrão com a lista de objetos*/
    public Passageiros(List<Passageiro__c> sObjectList)
	{
		// Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
	}
    
    /*todo domain deve ter sua classe constructor*/
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Passageiros(sObjectList);
		}
	}
    
    public override void onAfterInsert()
    {
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
    }
    
    public override void onAfterDelete()
    { 
        EmailPassageiroRemovido.sendEmail();
    } 
}