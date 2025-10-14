public class FlightNode implements Comparable
{
    public enum ShoreTypeEnum {Onshore, Offshore}
    public String name;
    public String nodeType;
    public Location geolocation {get; set;}
    public List<FlightNode> neighbors {get; private set;}
    public Decimal RelativeDistance {get; set;}
    public boolean needInterceptionNode {get; set;}
    public boolean isLinked {get; set;}
    public boolean hasWayIn
    {
        public get;
        private set
        {
            this.hasWayIn = value;
            this.islinked = hasWayIn && hasWayOut!= null && hasWayOut;
        }
    }
    public boolean hasWayOut
    {
        public get;
        private set
        {
            this.hasWayOut = value;
            this.islinked = hasWayIn!=null && hasWayIn && hasWayOut;
        }
    }
    public ShoreTypeEnum shoreType; 
    
    public FlightNode(){
        
    }
    
    public FlightNode(string name, String nodeType, Location geolocation, boolean needInterceptionNode, ShoreTypeEnum shoreType)
    {
        this.name = name;
        this.nodeType = nodeType;
        this.geolocation = geolocation;
        this.needInterceptionNode = needInterceptionNode;
        this.shoreType = shoreType;
        this.hasWayIn = false;
        this.hasWayOut = false;
    }
    
    public FlightNode addNeighbor(FlightNode neighbor)
    {
        return this.addNeighbor(neighbor, true, true);
    }
    
    public FlightNode addNeighbor(FlightNode neighbor, boolean nodeHasWayOut, boolean neighborHasWayIn)
    {
        if(neighbors== null)
        {
            neighbors = new List<FlightNode>();
            neighbors.add(neighbor);
        }
        else
        {
            FlightNode dupe = FlightNode.locateFlightNode(neighbors, neighbor.geolocation);
            if(dupe==null) neighbors.add(neighbor);
            else return dupe;
        }
        neighbor.hasWayIn = neighborHasWayIn;
        this.hasWayOut = nodeHasWayOut; 
        return neighbor;
    }
    
    public static FlightNode locateFlightNode(List<FlightNode> nodes, Location loc)
    {
        for(FlightNode node : nodes)
        {
            if(node.geolocation.getLongitude() == loc.getLongitude() && node.geolocation.getLatitude() == loc.getLatitude()) return node;
        }
        return null;
    }
    
    public Integer compareTo(Object compareTo) 
    {
        FlightNode compareToNode = (FlightNode)compareTo;
        // null should be bigger than anythig and equals to null
        if (this.RelativeDistance == null && compareToNode.RelativeDistance == null) return 0;
        if (this.RelativeDistance == null) return 1;
        if (compareToNode.RelativeDistance == null) return -1;
        
        Decimal comparison =  this.RelativeDistance - compareToNode.RelativeDistance;
        if(comparison>0) return 1;
        if(comparison<0) return -1;
        return 0;
    }
    
    public List<FlightNode> reverseList()
    {
        return null;
    }
}