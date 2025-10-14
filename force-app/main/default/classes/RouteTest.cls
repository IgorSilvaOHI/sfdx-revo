@isTest
public class RouteTest 
{
    @isTest
    public static void test1()
    {        
        List<FlightNode> nodes = new List<FlightNode>();
        
        FlightNode sbrj = new FlightNode();
        //SBRJ
        sbrj.name = 'SBRJ';
        sbrj.geolocation = Location.newInstance(-22.911469, -43.164130);        
        FlightNode sbjr = new FlightNode();
        //SBJR
        sbjr.name = 'SBJR';
        sbjr.geolocation = Location.newInstance(-22.987642, -43.370421);
        
        FlightNode sbme = new FlightNode();
        //SBME
        sbme.name = 'SBME';
        sbme.geolocation = Location.newInstance(-22.343324, -41.765774);
        
        FlightNode sbcb = new FlightNode();
        //SBCB
        sbcb.name = 'SBCB';
        sbcb.geolocation = Location.newInstance(-22.925176, -42.079336);
        
        FlightNode sbnf = new FlightNode();
        sbnf.name = 'SBNF';
        sbnf.geolocation = Location.newInstance(-26.879193, -48.650192);
        
        //sbme.addNeighbor(sbcb);
        //sbme.addNeighbor(sbjr);
        //sbme.addNeighbor(sbnf);

        sbcb.addNeighbor(sbrj);
        sbcb.addNeighbor(sbnf);
		sbcb.addNeighbor(sbjr);

		//sbrj.addNeighbor(sbnf);  
        sbrj.addNeighbor(sbjr);
        sbrj.addNeighbor(sbme);
        sbrj.addNeighbor(sbcb);
        
        sbjr.addNeighbor(sbrj);
        //sbjr.addNeighbor(sbnf); 
        
        nodes.add(sbrj);
        nodes.add(sbjr);
        nodes.add(sbme);
        nodes.add(sbcb);
        nodes.add(sbnf);
        
        Test.startTest();
        List<FlightNode> route = (new Route(nodes, sbjr, sbnf)).CalculateRoute();
        Test.stopTest();
        
        if (!route.isEmpty())
        {
            String routeStr = '';
            for (FlightNode n : route)
            {
                routeStr += n.name + ' - ';
            }
            
            System.debug('rota: ' + routeStr);            
        }
        else
        {
            System.debug('NÃO EXISTE CAMINHO');
        }
    }
    
}