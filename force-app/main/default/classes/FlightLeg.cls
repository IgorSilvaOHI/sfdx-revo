public class FlightLeg 
{
    //TODO: Renato mexeu aqui
    public String codOrigem;
    public String codDestino;
    public String aeronaveName;
    
    public Location origin {get; set;}
    public Location destination {get; set;}
    public boolean fuelDiponibilityOnOrigin;
    public boolean fuelDiponibilityOnDestination;
    public List<FlightNode> route;
    public Decimal distance {get; set;}
    public Decimal disponibilidadePeso;
    public Decimal tempoDecorrido;// Tempo decorrido de missão até o início do trecho. 
    public boolean viabilidade;
    public Decimal tempoCruzeiro 
    {
        get; 
        set 
        {
            this.tempoCruzeiro = value;
            if(this.tempoSolo != null)
            	this.tempoMissao = this.tempoSolo + this.tempoCruzeiro;
        }
    }
    public Decimal tempoSolo 
    {
        get; 
        set 
        {
            this.tempoSolo = value;
            if(this.tempoCruzeiro != null)
            	this.tempoMissao = this.tempoSolo + this.tempoCruzeiro;
        }
    }
    public Decimal tempoMissao {get; set;}
    
    public FlightLeg (String aeronaveName, String codOrigem, Location origin, String codDestino, Location destination, boolean fuelDiponibilityOnOrigin, boolean fuelDiponibilityOnDestination)
    {
        this.aeronaveName = aeronaveName;
        this.codOrigem = codOrigem;
        this.codDestino = codDestino;
        this.origin = origin;
        this.destination = destination;
        this.fuelDiponibilityOnOrigin = fuelDiponibilityOnOrigin;
        this.fuelDiponibilityOnDestination = fuelDiponibilityOnDestination;
    }
    
    public FlightLeg (Location origin, Location destination, boolean fuelDiponibilityOnOrigin, boolean fuelDiponibilityOnDestination)
    {
        this.origin = origin;
        this.destination = destination;
        this.fuelDiponibilityOnOrigin = fuelDiponibilityOnOrigin;
        this.fuelDiponibilityOnDestination = fuelDiponibilityOnDestination;
    }
    
    public List<FlightNode> CalculateRoute(List<FlightNode> nodes)
    {
        FlightNode origin = this.locateNode(nodes, this.origin);
        FlightNode destination = this.locateNode(nodes, this.destination);
        if(origin.needInterceptionNode) this.linkFlightNode(origin, nodes);
        if(destination.needInterceptionNode) this.linkFlightNode(destination, nodes);
        
        system.debug('origin.hasWayOut: '+origin.hasWayOut);
        system.debug('destination.hasWayIn: '+destination.hasWayIn);
        system.debug('origin.shoreType: '+ origin.shoreType);
        system.debug('origin.hasWayOut: '+ origin.hasWayOut);
        system.debug('origin '+ origin);
        system.debug('destination: '+ destination);
        
        if((origin.shoreType == FlightNode.ShoreTypeEnum.Offshore && destination.shoreType ==FlightNode.ShoreTypeEnum.Offshore)|| !(origin.hasWayOut && destination.hasWayIn))
        {
           system.Debug('PASSOU AQUI ROUTE');
            this.route = new List<FlightNode> {origin, destination};
            return this.route;
        }
        
        /*Route RouteCalc = new Route();
		this.route = RouteCalc.CalculateRoute(nodes, origin, destination);*/
        Route RouteCalc = new Route(nodes, origin, destination);
        this.route = RouteCalc.CalculateRoute();
        if(this.route == null || this.route.size()==0)
        {
            this.route = new List<FlightNode> {origin, destination};
        }
        system.debug('this.route: '+ this.route);
        
        //TODO: Pode excluir... Renato fez para imprimir a rota do trecho
        /*System.debug('======INÍCIO======');
		System.debug('AERONAVE: ' + this.aeronaveName);
		System.debug('TRECHO: ' + this.codOrigem + ' -> ' + this.codDestino);
		System.debug('ROTA ABAIXO:');
		for (FlightNode node : this.route)
		{
			System.debug('Node: ' + node);
		}
		System.debug('=======FIM=========');*/
        
        
        return this.route;        
    }
    
    private FlightNode locateNode(List<FlightNode> nodes, Location loc)
    {
        for(FlightNode node : nodes)
        {
            System.debug('Compare 1: ' + node.geolocation + ' Compare 2: ' + loc);
            System.debug('Result: ' + (node.geolocation == loc));

            if(node.geolocation == loc) return node;
        }
        FlightNode newNode = new FlightNode('Unknow Node', 'Padrão', loc, true, FlightNode.ShoreTypeEnum.Offshore);
        nodes.add(newNode);
        return newNode;
    }
    
    @TestVisible 
    private void linkFlightNode(FlightNode node, List<FlightNode> nodes) // Cria rotas para um node desgarrado da malha
    {
        integer countFlag= 0;
        List<FlightNode> closestNodes = this.locateClosestNodes(node, nodes, 6);
        for(FlightNode cnode : closestNodes) system.debug('closestNode: '+cnode.name);
        List<FlightNode> closestOrigins = new List<FlightNode>();
        for(FlightNode origem : nodes)
        {
            if (closestNodes.contains(origem)) continue;
            if(origem.neighbors!= null)
            {
                for(FlightNode neighbor: origem.neighbors)
                {
                    if(closestNodes.contains(neighbor)) closestOrigins.add(origem);
                }
            }
        }
        closestNodes.addAll(closestOrigins);
        system.debug('closestNodes.size(): '+closestNodes.size());
        
        for(FlightNode closeNode: closestNodes)
        {
            system.debug('closeNode.name: ' + closeNode.name);
            List<FlightNode> newNeigbors = new List<FlightNode>();
            if(closeNode.neighbors != null)
            {
                for(FlightNode neighbor : closeNode.neighbors)
                {
                    System.debug('closeNode.neighbor.name: '+neighbor.name);
                }
                system.debug('CLOSENODE: '+closeNode.name);
                for(FlightNode neighbor : closeNode.neighbors)
                {
                    if(closestOrigins.contains(closeNode) && !closestNodes.contains(neighbor))continue;
                    if(neighbor.nodeType != 'InterceptionNode')
                    {
                        newNeigbors.add(this.addInterceptionNode(nodes, node, closeNode, neighbor));
                        countFlag++;
                    }
                }
            }
            for(FlightNode nn : newNeigbors)
            {
                nn = closeNode.addneighbor(nn);
                System.debug('Node name: '+nn.name);
                system.debug('Coordenadas: '+nn.geolocation);
                System.debug('Distancia: '+ Location.getDistance(node.geolocation, nn.geolocation, 'mi')*0.868976);
                for(FlightNode rota : nn.neighbors)
                {
                    System.debug('--->rota: '+rota.name);
                }
            }
            
        }
        System.debug('countFlag: '+countFlag);
        if(countFlag==0)
        {
            closestNodes[0].addNeighbor(node); 
            node.addNeighbor(closestNodes[0]);
        }
        node.needInterceptionNode = false;
    }
    
    private boolean validateInterceptionPoint(Location loc, Location fromLoc, Location toLoc)//para que faça sentido um node de interceção meu ponto tem que estar no dominio e na imagem do meu trajeto
    {
        return true; //isBetween(loc.getLatitude(), fromLoc.getLatitude(), toloc.getLatitude()) || isBetween(loc.getLongitude(), fromLoc.getLongitude(), toloc.getLongitude());   
    }
    
    private boolean isBetween(double reference, double fromNumber, double toNumber)
    {
        if(fromNumber == toNumber) return reference == fromNumber;
        if (fromNumber < toNumber) return reference >= fromNumber && reference <= toNumber;
        return reference <= fromNumber && reference >= toNumber;
    }
    
    private FlightNode addInterceptionNode(List<FlightNode> nodes, FlightNode loc, FlightNode fromLoc, FlightNode toLoc)
    {
        Location newLoc = this.CalculateInterceptionNodeLocation(loc, fromLoc, toLoc);
        FlightNode newNode = FlightNode.locateFlightNode(nodes, newLoc);
        if(newNode == null)
        {
            newNode = new FlightNode(fromloc.name+'->'+toLoc.name+' - '+loc.name, 'InterceptionNode', newLoc, false, FlightNode.ShoreTypeEnum.Offshore);
            system.debug('NodeCriado = '+newNode.name);
        }
        toLoc = newNode.addneighbor(toLoc);
        loc = newNode.addneighbor(loc);
        loc.addneighbor(newNode);
        nodes.add(newNode);
        System.debug('passou');
        return newNode;
    }
    
    private Location CalculateInterceptionNodeLocation(FlightNode loc, FlightNode fromLoc, FlightNode toLoc)
    {
        
        double a = fromLoc.geolocation.getLatitude();
        double b = toLoc.geolocation.getLatitude();
        double c = loc.geolocation.getLatitude();
        double k = fromLoc.geolocation.getLongitude();
        double l = toLoc.geolocation.getLongitude(); 
        double m = loc.geolocation.getLongitude();   

        System.debug('fromLoc: '+fromLoc.name);
        System.debug('toLoc: '+toLoc.name);
        System.debug('loc: '+loc.name);

        
        System.debug('fromLoc: '+a);
        System.debug('toLoc: '+b);
        System.debug('loc: '+c);
        System.debug('fromLoc: '+k);
        System.debug('toLoc: '+l);
        System.debug('loc: '+m);


        Decimal newNodeLat = (-c*(b-a)*(-b+a)+(l-k)*(a*l-b*k)-m*(l-k)*(a-b))/(math.pow(l-k, 2)+math.pow(b-a, 2));
        double x = newNodeLat;
        Decimal newNodeLong = 0;
        if(a != b)
        {
            newNodeLong = (x*(l-k) - a*l + k*b)/(b-a);
        }
        else
        {
            newNodeLong = ((-b+a)/(l-k))*(x-c)+m;
        }
       
        
        /*// Triangulo maior
        double t1CO = fromLoc.geolocation.getLongitude() -  toLoc.geolocation.getLongitude();//cateto oposto
        double t1CA = fromLoc.geolocation.getLatitude() -  toLoc.geolocation.getLatitude();//cateto adjacente
        
        // Triangulo menor
        double t2CO = fromLoc.geolocation.getLongitude() -  loc.geolocation.getLongitude();//cateto oposto
        double t2CA = fromLoc.geolocation.getLatitude() -  loc.geolocation.getLatitude();//cateto adjacente
        
        newNodeLat = fromLoc.geolocation.getLatitude() + Math.cos(math.atan(t1CO/t1CA))*Math.cos(Math.atan(t1CO/t1CA)-Math.atan(t2CO/t2CA))*Math.sqrt(Math.pow(t2CO,2)+Math.pow(t2CA, 2));
        newNodeLong = fromLoc.geolocation.getLongitude() + Math.sin(math.atan(t1CO/t1CA))*Math.cos(Math.atan(t1CO/t1CA)-Math.atan(t2CO/t2CA))*Math.sqrt(Math.pow(t2CO,2)+Math.pow(t2CA, 2));
        */
		Location newLoc = Location.newInstance(newNodeLat, newNodeLong);
        return newLoc;
        
    }
    
    private List<FlightNode> locateClosestNodes(FlightNode compareNode, List<FlightNode> nodes, Integer qty) //localiza uma certa quantidade de nós mais próximos a um outro determinado nó 
    {
        for(FlightNode node : nodes)
        {
            if(node.nodeType == 'Waypoint')
            {
            	node.RelativeDistance = compareNode.geolocation.getDistance(node.geolocation ,'mi')*0.868976;
            }
        }
        nodes.sort();
        List<FlightNode> result = new List<FlightNode>();
        for (integer i=0; i<qty; i++)
        {
            result.add(nodes[i]);
            if(i+1 == nodes.size()) break;
        }
        clearNodesRelativeDistance(nodes);
        return result;
    }
    
    private void clearNodesRelativeDistance(List<FlightNode> nodes)
    {
        for(FlightNode node: nodes)
        {
            node.RelativeDistance = null;
        }
    }
}