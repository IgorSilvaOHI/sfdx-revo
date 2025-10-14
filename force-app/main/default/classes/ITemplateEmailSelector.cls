public interface ITemplateEmailSelector 
{
    List<TemplateEmail__mdt> selectAll();
    List<TemplateEmail__mdt> selectByDeveloperName(String developerName);
}