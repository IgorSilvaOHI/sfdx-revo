public class Utils
{
    public static Map<String, String> getMapDevLabelFromPicklist(Schema.DescribeFieldResult fieldResult)
    {
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();
        Map<String, String> devNameToLabel = new Map<String, String>();
        for(Schema.PicklistEntry ple : ples)
        {
            devNameToLabel.put(ple.getValue(), ple.getLabel());
        }
        return devNameToLabel;
    }
    
    public static Set<Id> getSetIds(List<SObject> sObjs, String fieldName)
    {
        Set<Id> ids = new Set<Id>();
        
        for (SObject sObj : sObjs)
        {   
            if (sObj.get(fieldName) != null) ids.add( (Id) sObj.get(fieldName) );
        }
        return ids;
    }
    
    public static Set<Object> getSetOfField(List<SObject> sObjs, Schema.SObjectField field)
    {
        Set<Object> setField = new Set<Object>();
        
        for (SObject sObj : sObjs)
        {   
            setField.add( sObj.get(field) );
        }
        return setField;
    }
    
    public static Set<String> getSetOfField(List<SObject> sObjs, String fieldName)
    {
        Set<String> setField = new Set<String>();
        
        for (SObject sObj : sObjs)
        {   
            setField.add( (String) sObj.get(fieldName) );
        }
        return setField;
    }
    
    public static Map<String, SObject>  mapByStringField(List<SObject> sObjs, Schema.SObjectField fieldName)
    {
        Map<String, SObject> mapRelated = new Map<String, SObject>();
        
        if(fieldName != null)
        {
            for(SOBject sObj : sObjs)
            {
                mapRelated.put((String)SObj.get(fieldName), sObj);
            }
        }
        return mapRelated;
    }
    
    public static Map<Id, List<SObject>> groupByRelatedTo(List<SObject> SObjs, Schema.SObjectField fieldName, String sObjFieldName)
    {
        Map<Id, List<SObject>> relatedToMap = new Map<Id, List<SObject>>();
        Id fieldId;
        for (SOBject SObj : SObjs)
        {
            if(String.isNotBlank(sObjFieldName))
            {
                fieldId = SObj.getSObject(SObjFieldName) != null ? (Id)SObj.getSObject(SObjFieldName).get(fieldName) : null;
            }else
            {
                fieldId = (Id)SObj.get(fieldName);
            }
            if(relatedToMap.containsKey(fieldId))
            {
                List<SObject> SObjsList = relatedToMap.get(fieldId);
                SObjsList.add(SObj);
                relatedToMap.put(fieldId, SObjsList);
            }
            else
            {
                List<SObject> SObjsList = new List<SOBject>();
                SObjsList.add(SObj);
                relatedToMap.put(fieldId, SObjsList);
            }
        }
        
        return relatedToMap;
    }
    
    public static void addErrorIfMapContainsObject(Map<Id, SObject> objetosMap, SObject objeto, String error)
    {
        if (objetosMap.containsKey(objeto.Id))
        {
            objeto.addError(new fflib_SObjectDomain.DomainException(error));
        }
    }
    
    public static List<Id> getListIds(List<SObject> sObjs, String fieldName)
    {
        List<Id> ids = new List<Id>();
        
        for (SObject sObj : sObjs)
        {   
            ids.add( (Id) sObj.get(fieldName) );
        }
        return ids;
    }
    
    public static Set<Id> getSetIdsByListIds(List<Id> ids)
    {
        Set<Id> setIds = new Set<Id>();
        setIds.addAll(ids);
        return setIds;
    }
    
    public static Map<String, Estado> nameToEstado
    {
        get
        {
            Map<String, Estado> estadoValues = new Map<String, Estado>();
            if (nameToEstado == null)
            {
                for (Estado enumValue : Estado.values())
                {
                    estadoValues.put(String.valueOf(enumValue).toUpperCase(), enumValue);
                }
            }
            return estadoValues;
        }
        private set;
    }
    
    public static Estado getEstado(String name)
    {        
        return String.isBlank(name) ? null : nameToEstado.get(name.toUpperCase());
    }
    
    public static Integer getProximaDezena(Integer numero)
    {
        numero += 10;
        if (Math.mod(numero,10) != 0)
        {
            Integer resto;
            while (resto == null || resto != 0)
            {
                numero--;
                resto = Math.mod(numero, 10);
            }
        }
        return numero;
    } 
    
    public static Datetime getDatetimeGmt(Datetime value)
    {
        return 
            Datetime.newInstanceGmt(
                value.date(),
                value.time()
            );
    }

    public class SchedulableException extends Exception {}
}