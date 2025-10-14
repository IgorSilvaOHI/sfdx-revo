public class ReverseIterator implements Iterator<Object>
{
    public List<Object> listObjs;
    Integer position;
    
    public ReverseIterator(List<Object> listObjs)
    {
        this.listObjs = listObjs;
        position = listObjs.size();
    }
    
    public Boolean hasNext()
    {
        return position > 0;
    }
    
    public Object next()
    {
        return listObjs[--position];
    }
}