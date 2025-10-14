public class Product2Selector extends fflib_SObjectSelector 
implements IProduct2Selector {
    
    public static IProduct2Selector newInstance()
    {
        return (IProduct2Selector) Application.Selector.newInstance(Product2.SObjectType);
    }
    
    public Product2Selector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public Product2Selector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.Product2.FieldSets.Product);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Product2.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return Product2.sObjectType;
    }

    public List<Product2> selectById(Set<ID> idSet)
    {
        return (List<Product2>) selectSObjectsById(idSet);
    }        
    
    public Product2 selectSeatProductByRoute(Id origin, Id destiny)
    {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id ShuttleSeat = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'ShuttleSeat') {
                ShuttleSeat = rtInfo.getRecordTypeId();
            }
        }

        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('RecordTypeId = :ShuttleSeat And IsActive = true And LocalOrigem__c = :origin And LocalDestino__c = :destiny');
        
        List<Product2> products = Database.query( query.toSOQL() );

        return products.size() > 0 ? products[0] : null; 
    }
    
    public Product2 selectFullCabinProductByRoute(Id origin, Id destiny)
    {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id FullCabin = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'FullCabin') {
                FullCabin = rtInfo.getRecordTypeId();
            }
        }

        fflib_QueryFactory query = newQueryFactory();

        Local__c origem = [Select Id, DistritoHeliponto__c From Local__c Where Id = :origin];
        Local__c destino = [Select Id, DistritoHeliponto__c From Local__c Where Id = :destiny];

        Id distritoOrigem = origem != null && origem.DistritoHeliponto__c != null ? origem.DistritoHeliponto__c : null;
        Id distritoDestino = destino != null && destino.DistritoHeliponto__c != null ? destino.DistritoHeliponto__c : null;

        String originCond = distritoOrigem != null ? '(LocalOrigem__c = :origin Or DistritoOrigem__c = :distritoOrigem)' : 'LocalOrigem__c = :origin';

        String destinyCond = distritoDestino != null ? '(LocalDestino__c = :destiny Or DistritoDestino__c = :distritoDestino)' : 'LocalDestino__c = :destiny';

        query.setCondition('RecordTypeId = :FullCabin And IsActive = true And ' + originCond + ' And ' + destinyCond);
        
        query.setOrdering('LocalOrigem__r.DistritoHeliponto__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        query.setOrdering('LocalDestino__r.DistritoHeliponto__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        
        List<Product2> products = Database.query( query.toSOQL() );

        
        return products.size() > 0 ? products[0] : null; 
    }

    public Product2 selectCharterProduct() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id CharterFlight = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'CharterFlight') {
                CharterFlight = rtInfo.getRecordTypeId();
            }
        }

        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('RecordTypeId = :CharterFlight And IsActive = true');
        
        List<Product2> products = Database.query( query.toSOQL() );

        
        return products.size() > 0 ? products[0] : null;         
    }
    
    public List<Product2> selectActiveByRecordTypes(Set<String> recordTypeNames) {
        fflib_QueryFactory query = newQueryFactory();
        
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (Schema.RecordTypeInfo rtInfo : Schema.SObjectType.Product2.getRecordTypeInfos()) {
            if (recordTypeNames.contains(rtInfo.getName()) || recordTypeNames.contains(rtInfo.getDeveloperName())) {
                recordTypeMap.put(rtInfo.getName(), rtInfo.getRecordTypeId());
            }
        }
        
        if (recordTypeMap.isEmpty()) {
            return new List<Product2>();
        }
        
        // Bind a Set<Id> instead of calling values() inside the SOQL to avoid parser errors
        Set<Id> recordTypeIds = new Set<Id>(recordTypeMap.values());
        query.setCondition('IsActive = true AND RecordTypeId IN :recordTypeIds');
        query.setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.query(query.toSOQL());
    }
    
    public List<Product2> selectActiveShuttleSeatProducts() {
        fflib_QueryFactory query = newQueryFactory();
        
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (Schema.RecordTypeInfo rtInfo : Schema.SObjectType.Product2.getRecordTypeInfos()) {
            if (rtInfo.getName() == 'Shuttle Seat' || rtInfo.getDeveloperName() == 'ShuttleSeat') {
                recordTypeMap.put(rtInfo.getName(), rtInfo.getRecordTypeId());
            }
        }
        
        if (recordTypeMap.isEmpty()) {
            return new List<Product2>();
        }
        
        // Bind a Set<Id> instead of calling values() inside the SOQL to avoid parser errors
        Set<Id> recordTypeIds = new Set<Id>(recordTypeMap.values());
        query.setCondition('IsActive = true AND RecordTypeId IN :recordTypeIds');
        query.setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.query(query.toSOQL());
    }
}