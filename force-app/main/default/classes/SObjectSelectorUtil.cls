public class SObjectSelectorUtil {
    
    public static List<Id> ExtractIds(List<SObject> sobjects, String idToExtract) {
        Set<Id> extract = new Set<Id>();
        
        for (SObject obj : sobjects) {
            if (obj.get(idToExtract) == null) continue;
            
            Id id2 = (String)obj.get(idToExtract);
			
            extract.add(id2);
        }
        
        return new List<Id>(extract);
    }
    
    public static Map<Id, List<SObject>> BreakById(List<SObject> sobjects, String idToBreak) {
        Map<Id, List<SObject>> breakBy = new Map<Id, List<SObject>>();
        
        for (SObject obj : sobjects) {
            if (obj.get(idToBreak) == null) continue;
            
            Id id2 = (String)obj.get(idToBreak);
			
            if (!breakBy.ContainsKey(id2)) 
                breakBy.put(id2, new List<SObject>());
            
            List<SObject> lst = breakBy.get(id2);
            lst.add(obj);
        }
        
        return breakBy;
    }
    
    public static Map<String, List<SObject>> BreakByString(List<SObject> sobjects, String strToBreak) {
        Map<String, List<SObject>> breakBy = new Map<String, List<SObject>>();
        
        for (SObject obj : sobjects) {
            if (obj.get(strToBreak) == null) continue;
            
            String id2 = (String)obj.get(strToBreak);
            
            if (!breakBy.ContainsKey(id2)) 
                breakBy.put(id2, new List<SObject>());
            
            List<SObject> lst = breakBy.get(id2);
            lst.add(obj);
        }
        
        return breakBy;
    }
    
}