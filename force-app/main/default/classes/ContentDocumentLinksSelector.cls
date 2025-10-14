public class ContentDocumentLinksSelector extends fflib_SObjectSelector 
	implements IContentDocumentLinksSelector
{

    public static IContentDocumentLinksSelector newInstance()
	{
		return (IContentDocumentLinksSelector) Application.Selector.newInstance(ContentDocumentLink.SObjectType);
	}
    
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			ContentDocumentLink.Id,
            ContentDocumentLink.LinkedEntityId,
            ContentDocumentLink.ContentDocumentId
		};
	}
    
    // não é possível consultar ContentDocumentLink deletado diretamente, tem que pegar por subQuery
    public List<ContentDocumentLink> selectDeletedByLinkedEntityId(Set<ID> idSet)
    {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('LinkedEntityId in :idSet');
		return (List<ContentDocumentLink>) Database.query(query.toSOQL());
    }
	
    
    public Schema.SObjectType getSObjectType()
	{
		return ContentDocumentLink.sObjectType;
	}
    
    public List<ContentDocumentLink> selectById(Set<ID> idSet)
	{
		return (List<ContentDocumentLink>) selectSObjectsById(idSet);
	}
}