@isTest
public class FlightLegTest 
{
    public static List<FlightNode> gerarMalhaAerea()
    {
        FlightNode SP = new FlightNode();
        SP.name = 'São Paulo';
        SP.geolocation = location.newInstance(-23.553992, -46.633485);
        
        FlightNode BH = new FlightNode();
        BH.name = 'Belo Horizonte';
        BH.geolocation = location.newInstance(-19.926243, -43.936201);
        
        FlightNode RJ = new FlightNode();
        RJ.name = 'Rio de Janeiro';
        RJ.geolocation = location.newInstance(-22.930683, -43.179854);
        
        FlightNode VIX = new FlightNode();
        VIX.name = 'Vitória';
        VIX.geolocation = location.newInstance(-20.264076, -40.83413);
        
        FlightNode DF = new FlightNode();
        DF.name = 'Distrito Federal';
        DF.geolocation = location.newInstance(-15.803569, -47.885030);
        
        SP.addNeighbor(BH);
        SP.addNeighbor(RJ);
        SP.addNeighbor(VIX);
        SP.addNeighbor(DF);
        
        BH.addNeighbor(SP);
        BH.addNeighbor(RJ);
        BH.addNeighbor(VIX);
        BH.addNeighbor(DF);
        
        RJ.addNeighbor(BH);
        RJ.addNeighbor(SP);
        RJ.addNeighbor(VIX);
        RJ.addNeighbor(DF);
        
        VIX.addNeighbor(BH);
        VIX.addNeighbor(RJ);
        VIX.addNeighbor(SP);
        VIX.addNeighbor(DF);
        
        DF.addNeighbor(BH);
        DF.addNeighbor(RJ);
        DF.addNeighbor(VIX);
        DF.addNeighbor(SP);
        
        list<FlightNode> malha = new list<FlightNode>{SP, BH, RJ, VIX, DF};
            
        return malha;
    }
    
    public static void removeRoute(string origin, string destination, list<FlightNode> malha)
    {
        for(FlightNode fn : malha)
        {
            if(fn.name == origin)
            {
                for(integer i = 0; i< fn.neighbors.size(); i++)
                {
                    if(fn.neighbors[i].name == destination) fn.neighbors.remove(i);
                }
            }
        }
    }
    public static FlightNode locateFlightNode(string name, list<FlightNode> malha)
    {
        for(FlightNode fn : malha)
        {
            if(fn.name == name) return fn;
       	}
        return null;
    }
    /*
    @isTest static void calculateRouteTest()
    {
        list<FlightNode> malha = FlightLegtest.gerarMalhaAerea();
        FlightLegtest.removeRoute('Distrito Federal', 'Vitória', malha);        
        FlightNode origem = FlightLegtest.locateFlightNode('Distrito Federal', malha);
        //for(FlightNode fn : origem.neighbors) system.debug(fn.name);
        FlightNode destino = FlightLegtest.locateFlightNode('Vitória', malha);
        FlightLeg DfVix = new FlightLeg('AW139', origem.name, origem.geolocation, destino.name, destino.geolocation, true, true);
        test.startTest();
        List<Flightnode> rota = DfVix.CalculateRoute(malha);
        test.stopTest();
        system.debug(rota);
        system.assertEquals(3, rota.size());
        system.assertEquals(rota[0].name, 'Distrito Federal');
        system.assertEquals(rota[1].name, 'Belo Horizonte');
        system.assertEquals(rota[2].name, 'Vitória');
    }
    */
    @isTest static void LinkFlightNodeTest1()
    {
        list<FlightNode> malha = FlightLegtest.gerarMalhaAerea();
        
        FlightNode JF = new FlightNode();
        JF.name = 'Juiz de fora';
        JF.geolocation = location.newInstance(-21.764579, -43.344248);
        
        FlightNode origem = FlightLegtest.locateFlightNode('Belo Horizonte', malha);
        FlightNode destino = JF;
        FlightLeg BhJf = new FlightLeg('AW139', origem.name, origem.geolocation, destino.name, destino.geolocation, true, true);
        
        test.startTest();
        BhJf.linkFlightNode(JF, malha);
        test.stopTest();
        
        for(FlightNode fn : JF.neighbors)
        {
            system.debug(fn.geolocation);
            system.debug(fn.name);
            system.debug(fn.geolocation.getDistance(JF.geolocation,'km')); 
        }
        
        
    }
    
    
    @isTest static void LinkFlightNodeTest2()
    {
        list<FlightNode> malha = FlightLegtest.gerarMalhaAerea();
        
        FlightNode PA = new FlightNode();
        PA.name = 'Porto Alegre';
        PA.geolocation = location.newInstance(-29.936525, -51.199004);        
        
        FlightNode origem = FlightLegtest.locateFlightNode('Belo Horizonte', malha);
        FlightNode destino = PA;
        FlightLeg BhJf = new FlightLeg('AW139', origem.name, origem.geolocation, destino.name, destino.geolocation, true, true);
        
        test.startTest();
        BhJf.linkFlightNode(PA, malha);
        test.stopTest();
        
        for(FlightNode fn : PA.neighbors)
        {
            system.debug(fn.geolocation);
            system.debug(fn.name);
            system.debug(fn.geolocation.getDistance(PA.geolocation,'km')); 
        }
        
        
    }
    
    
    @isTest static void testCompareTo()
    {
        FlightNode fn1 = new FlightNode();
        fn1.RelativeDistance = 1;
        FlightNode fn2 = new FlightNode();
        List<FlightNode> fns = new List<FlightNode>();
        fns.add(fn1);
        fns.add(fn2);
        Test.startTest();
        fns.sort();
        
        fn2.RelativeDistance = 2;
        fns.sort();
        
        fn2.RelativeDistance = 1;
        fns.sort();
        
        List<FlightNode> fnR = fn1.reverseList();
        Test.stopTest();        
        
        System.assertEquals(null, fnR);
    }
    
    
    @isTest static void testConstructor()
    {
        Test.startTest();
        FlightLeg fl = new FlightLeg(null, null, null, null);
        fl.tempoCruzeiro = 10;
        fl.distance = 20;
        fl.tempoSolo = 30;
        fl.tempoMissao = 40;
        Test.stopTest();
        
        System.assertEquals(10, fl.tempoCruzeiro);
        System.assertEquals(20, fl.distance);
        System.assertEquals(30, fl.tempoSolo);
        System.assertEquals(40, fl.tempoMissao);
    }
	
}