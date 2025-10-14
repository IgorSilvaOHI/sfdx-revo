public class VooWrapper
{
	Voo__c voo;
	List<Trecho__c> trechos;
	
	public VooWrapper(Voo__c voo, List<Trecho__c> trechos)
	{
		this.voo = voo;
		this.trechos = trechos;
	}
}