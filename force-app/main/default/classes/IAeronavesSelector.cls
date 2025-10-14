public interface IAeronavesSelector {
    List<Schema.SObjectField> getSObjectFieldList();
    Schema.SObjectType getSObjectType();
	List<Aeronave__c> selectById(Set<Id> idSet);
    List<Aeronave__c> selectAll();
    List<Aeronave__c> selectAeronaveAndModelo(Set<Id> idSet);
    List<Aeronave__c> getPrefixosValidos(Set<Id> prefixosExclusos);
    List<Aeronave__c> selectTodasAtivas();
}