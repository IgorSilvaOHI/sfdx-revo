public class Aeronaves extends fflib_SObjectDomain
	implements IAeronaves
{    
    public static IAeronaves newInstance(List<Aeronave__c> sObjectList)
	{
		return (IAeronaves) Application.Domain.newInstance(sObjectList);
	}
    
    /*todo domain possui o contrutor padrão com a lista de objetos*/
    public Aeronaves(List<Aeronave__c> sObjectList)
	{
		super(sObjectList);
	}
    
    /*todo domain deve ter sua classe constructor*/
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Aeronaves(sObjectList);
		}
	}
    
    public Map<Id, List<Aeronave__c>> getPorModelo()
    {
        return (Map<Id, List<Aeronave__c>>)Utils.groupByRelatedTo(
                Records, 
                Aeronave__c.ModeloAeronave__c, 
               	null);
    }
    
    public Map<String, Aeronave__c> getPorPrefixo()
    {
        Map<String, Aeronave__c> mapRelated = new Map<String, Aeronave__c>();

        for(Aeronave__c aeronave : (List<Aeronave__c>)Records)
        {
            mapRelated.put(aeronave.Name, aeronave);
        }
        return mapRelated;
    }
    
    class AeronavesException extends Exception{}
}