public class Route 
{
    List<FlightNode> nodes;
    FlightNode fromLoc;
    FlightNode toLoc;
    
    List<FlightNode> unvisited;
    Map<FlightNode, FlightNode> prev;
    Map<FlightNode, Decimal> distance;
    
    private static FINAL String unit = 'km';
    private static FINAL Decimal divisor = 1.852;
    
    public Route(List<FlightNode> nodes, FlightNode fromLoc, FlightNode toLoc)
    {
        this.nodes = nodes;
        this.fromLoc = flightNode.locateFlightNode(this.nodes, fromLoc.geolocation);
        this.toLoc = flightNode.locateFlightNode(this.nodes, toLoc.geolocation);
        
        this.unvisited = nodes.clone();
        initializeMaps();     
    }
    
    //inicializa variáveis importantes para o algoritmo
    private void initializeMaps()
    {
        this.prev = new Map<FlightNode, FlightNode>();
        this.distance = new Map<FlightNode, Decimal>();
        
        if (this.nodes != null)
        {
            for (FlightNode node : this.nodes)
            {
                //TODO: descobrir se os nós do grafo serão de fato identicos aos nós from e to
                //Caso negativo, talvez a comparação deva ser node.geolocation === fromLoc.geolocation
                Decimal distance = (node === fromLoc) ? 0 : Math.pow(2,1023);
                this.prev.put(node, null);
                this.distance.put(node, distance);                
            }            
        }
    }
    
    public List<FlightNode> CalculateRoute()
    {
        //inicializa a lista do caminho percorrido para retornar uma lista vazia, caso o caminho não seja encontrado
        List<FlightNode> routeList = new List<FlightNode>();
        ClosestWrapper closest = getClosest();
        
        do
        {            
            //Removo o closest da lista de não visitados, pois ele será visitado nesse momento
            this.unvisited.remove(closest.index);
            
            if (closest.node == this.toLoc)
            {
                routeList = buildRouteList();
            }
            else
            {
                //Itera em todos os vizinhos
                if (closest.node.neighbors != null)
                {
                    for (FlightNode neighbor : closest.node.neighbors)
                    {
                        //Pega a distância da origem até ele e soma com a distâcia dele até o vizinho
                        Decimal totalDistance = this.distance.get(closest.node) + getDistance(closest.node, neighbor);
                        
                        //Se a distância calculada for menor do que a distância previamente calculada (ou inicializada com infinito)
                        if (totalDistance < this.distance.get(neighbor))
                        {
                            //atualiza a distância
                            this.distance.put(neighbor, totalDistance);
                            //atualiza qual nó foi utilizado para chegar até ele
                            this.prev.put(neighbor, closest.node);
                        }
                    } 
                }
            }
            closest = getClosest();
        }
        while (!this.unvisited.isEmpty() && closest.node != null);
        
        return routeList;
    }
    
    //retorna um vértice não visitado de menor custo
    private ClosestWrapper getClosest()
    {
        //Caso o algoritmo esteja começando, retorna o nó de origem
        FlightNode closest = (this.unvisited.size() == this.nodes.size()) ? this.fromLoc : null;
        Integer index = this.unvisited.indexOf(closest);
        
        //Se não for a origem
        if ( (closest != this.fromLoc) )
        {
            //TODO: gera um número decimal muito grande
            //O ideal era fazer igual java... algo do tipo Double.MAX_VALUE
            //É possível gerar Infinity no apex, mas apenas com Double
            Decimal distance = Math.pow(2,1023);
            
            //Busca o nó não visitado de menor custo
            for (Integer i = 0; i < this.unvisited.size(); i++)
            {
                FlightNode unvisitedNode = this.unvisited.get(i);
                Decimal distanceUnvisitedNode = this.distance.get(unvisitedNode);
                
                //Se a distância até o nó não visitado for menor que a distância atual
                if (distanceUnvisitedNode < distance)
                {
                    distance = distanceUnvisitedNode; 
                    closest = unvisitedNode;
                    index = i;
                }
            }
        }
        
        return new ClosestWrapper(index, closest);
    }
    
    private Decimal getDistance(FlightNode fromNode, FlightNode toNode)
    {
        //Retorna a distância entre os 2 pontos
        return (Location.getDistance(fromNode.geolocation, toNode.geolocation, unit))/divisor;
    }
    
    private List<FlightNode> buildRouteList()
    {
        List<FlightNode> route = new List<FlightNode>();
        
        //Se existe caminho
        //Esse if verifica se o destino possui um prev
        if (this.prev.get(this.toLoc) != null)
        {
            //Inicia pelo nó de destino
            FlightNode node = this.toLoc;
            
            while (node != null)
            {
                route.add(node);
                node = this.prev.get(node);
            }
        }            
        
        return reverse(route);
    }
    
    private List<FlightNode> reverse(List<FlightNode> nodes)
    {
        List<FlightNode> reverseList = new List<FlightNode>();
        
        ReverseIterator revIt = new ReverseIterator(nodes);
        while (revIt.hasNext())
        {
            reverseList.add((FlightNode)revIt.next());
        }
        
        return reverseList;
    }
    
    private class ClosestWrapper
    {
        Integer index;
        FlightNode node;
        
        public ClosestWrapper(Integer i, FlightNode n)
        {
            index = i;
            node = n;
        }
    }
    
}