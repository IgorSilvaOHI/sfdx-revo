public class CaseTrabalhoDomain extends SObjectDomain {

    protected override Schema.SObjectType getSObjectType(){
        return Case.sObjectType;
    }
    
    protected override Map<Id, Schema.RecordTypeInfo> getRecordTypeInfosById(){
        Map<Id, Schema.RecordTypeInfo> types = new Map<Id, Schema.RecordTypeInfo>();
        
        Schema.RecordTypeInfo trabalhoType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Trabalho');
        types.put(trabalhoType.getRecordTypeId(), trabalhoType);
        
        return types;
    }    

    public CaseTrabalhoDomain() {
        
    }    
        
    protected override void onBeforeInsert(){
        System.debug('context CaseTrabalhoDomain Operation: ' + context.Operation);
        if (context.News != null)
	        System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
	        System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    protected override void onBeforeUpdate(){
        System.debug('context CaseTrabalhoDomain Operation: ' + context.Operation);
        if (context.News != null)
	        System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
	        System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    protected override void onAfterInsert(){
        System.debug('context CaseTrabalhoDomain Operation: ' + context.Operation);
        if (context.News != null)
	        System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
	        System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    protected override void onAfterUpdate(){
        System.debug('context CaseTrabalhoDomain Operation: ' + context.Operation);
        if (context.News != null)
	        System.debug('context CaseDomain News: ' + context.News.Size());
        if (context.Olds != null)
	        System.debug('context CaseDomain Olds: ' + context.Olds.Size());
    }
    
}