public class EmailMessageSelector extends fflib_SObjectSelector 
	implements IEmailMessageSelector{
    
    public static IEmailMessageSelector newInstance()
    {
        return (IEmailMessageSelector) Application.Selector.newInstance(EmailMessage.SObjectType);
    }
    
    public EmailMessageSelector()
    {
        super(true);
    }
    
    public Schema.SObjectType getSObjectType()
    {
        return EmailMessage.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() 
    {
        return new List<Schema.SObjectField> {
				EmailMessage.Id
		};
    }
    
    public List<EmailMessage> selectByRelatedToIdEmailTemplateId(Id relatedToId, Id emailTemplateId)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('EmailTemplateId =:emailTemplateId AND RelatedToId =:relatedToId');
        return (List<EmailMessage>) Database.query(query.toSOQL());
    }     
}