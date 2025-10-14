public interface IEmailMessageSelector extends fflib_ISObjectSelector {

    List<EmailMessage> selectByRelatedToIdEmailTemplateId(Id relatedToId, Id emailTemplateId);
    
}