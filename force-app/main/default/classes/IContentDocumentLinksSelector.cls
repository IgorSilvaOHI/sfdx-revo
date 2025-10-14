public interface IContentDocumentLinksSelector extends fflib_ISObjectSelector
{
    List<ContentDocumentLink> selectDeletedByLinkedEntityId(Set<ID> idSet);
}