public class UsuarioSiteSelector extends fflib_SObjectSelector implements IUsuarioSiteSelector {

    public static IUsuarioSiteSelector newInstance()
    {
        return (IUsuarioSiteSelector) Application.Selector.newInstance(UsuarioSite__c.SObjectType);
    }
    
    public UsuarioSiteSelector(Boolean includeFieldSetFields)
    {
        super(includeFieldSetFields);
    }
    
    public UsuarioSiteSelector()
    {
        super(true);
    }
    
    public override List<Schema.FieldSet> getSObjectFieldSetList()
    {
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        
        fieldSets.add(SobjectType.UsuarioSite__c.FieldSets.SelectFieldList);
        
        return fieldSets;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            UsuarioSite__c.Id
        };
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return UsuarioSite__c.sObjectType;
    }
        
    
    public UsuarioSite__c encontraPeloIdUsuarioSite(String idUsuarioSite) {

        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('IdSite__c = :idUsuarioSite');
        
        List<UsuarioSite__c> usuarios = Database.query( query.toSOQL() );

        return usuarios.size() > 0 ? usuarios[0] : null;         
    }

    public UsuarioSite__c encontraPelaConta(Id accountId) {

        fflib_QueryFactory query = newQueryFactory();

        query.setCondition('Conta__c = :accountId');
        
        List<UsuarioSite__c> usuarios = Database.query( query.toSOQL() );

        return usuarios.size() > 0 ? usuarios[0] : null;         
    }

}