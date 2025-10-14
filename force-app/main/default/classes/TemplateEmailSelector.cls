public class TemplateEmailSelector extends fflib_SObjectSelector implements ITemplateEmailSelector
{
    
    public static ITemplateEmailSelector newInstance()
    {
        return (ITemplateEmailSelector) Application.Selector.newInstance(TemplateEmail__mdt.SObjectType);
    }
    
    public TemplateEmailSelector()
    {
        super(true);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();
        
        fields.add(TemplateEmail__mdt.Id__c);
        fields.add(TemplateEmail__mdt.APINameInteresse__c);
        fields.add(TemplateEmail__mdt.DeveloperName);
        fields.add(TemplateEmail__mdt.MasterLabel);
        
        return fields;
    }
    
    public Schema.SObjectType getSObjectType() 
    {
        return TemplateEmail__mdt.sObjectType;
    }
    
    public List<TemplateEmail__mdt> selectAll()
    {
        fflib_QueryFactory query = newQueryFactory();
        
        return (List<TemplateEmail__mdt>) Database.query(query.toSOQL());
    }
    
    public List<TemplateEmail__mdt> selectByDeveloperName(String developerName)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('DeveloperName = :developerName');
        
        return  (List<TemplateEmail__mdt>) Database.query(query.toSOQL());       
    }
}