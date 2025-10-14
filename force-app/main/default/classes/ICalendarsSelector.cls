public interface ICalendarsSelector extends fflib_ISObjectSelector {
    List<Schema.SObjectField> getSObjectFieldList();
    Schema.SObjectType getSObjectType();
    //List<Calendar> selectById(Set<ID> idSet);
    //List<Calendar> selectWithEventsByPrefix(Set<String> prefixs);
    List<Calendar> selectCalendarsByPrefixsSetName(Set<String> prefixs);
}