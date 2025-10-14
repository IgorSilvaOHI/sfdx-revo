public class ConversorGeolocation 
{
    //Estrutura da Classe
    public class CoordenadaGraus
    {
        public Integer grau;
        public Integer minuto;
        public Decimal segundo;
        public String direcao;
        
        public CoordenadaGraus(){}
        
        public CoordenadaGraus(Integer gr, Integer min, Decimal seg, String dir)
        {
            this.grau = gr;
            this.minuto = min;
            this.segundo = seg;
            this.direcao = dir;
        }
    }
    
    public class LocalGraus
    {
        public CoordenadaGraus latitude;
        public CoordenadaGraus longitude;
        
        public LocalGraus(){}
        
        public LocalGraus(CoordenadaGraus lati, CoordenadaGraus longi)
        {
            this.latitude = lati;
            this.longitude = longi;
        }
    }
    
    public class LocalDecimais
    {
        public Decimal latitude;
        public Decimal longitude;
        
        public LocalDecimais(){}
        
        public LocalDecimais(Decimal lati, Decimal longi)
        {
            this.latitude = lati;
            this.longitude = longi;
        }
    }
    
    //Conversão de Decimal para Graus
    public static LocalGraus convertLocalDecimalParaGrau(Decimal latitude, Decimal longitude)
    {
        LocalGraus localEmGrau = new LocalGraus(convertLatitudeParaGrau(latitude), convertLongitudeParaGrau(longitude));
        return localEmGrau;
    }

    public static CoordenadaGraus convertLatitudeParaGrau(Decimal latitude)
    {
        CoordenadaGraus newlati = convertDecimalParaGrau(latitude);
        
        if(newlati != null)
        {
            newlati.direcao = (latitude < 0) ? 'S' : 'N';
        }
        
        return newlati;
    }

    public static CoordenadaGraus convertLongitudeParaGrau(Decimal longitude)
    {
        CoordenadaGraus newlongi = convertDecimalParaGrau(longitude);
        
        if(newlongi != null)
        {
            newlongi.direcao = (longitude < 0) ? 'O' : 'L';
        }
        
        return newlongi;
    }
    
    private static CoordenadaGraus convertDecimalParaGrau(Decimal numero)
    {
		if(numero == null)
        {
            return null;
        }
        /*TODO Edgar
        return new CoordenadaGraus(
            grau = getGrau(numero),
            minuto = getMinuto(numero),
            segundo = getSegundo(numero)
        );
        */
        
        CoordenadaGraus coord = new CoordenadaGraus();
        
        numero = numero.abs();
        Integer i;
        //Grau
        i = numero.intValue();
        coord.grau = i;
        //Minuto
        numero = numero - i;
        numero = numero * 60;
        i = numero.intValue();
        coord.minuto = i;
        //Segundo
        numero = numero - i;
        numero = numero * 60;
        coord.segundo = numero;
        
        return coord;        
    }
        
    public static LocalDecimais convertLocalGrauParaDecimal(CoordenadaGraus lati, CoordenadaGraus longi)
    {
        LocalDecimais localResult = new LocalDecimais(
        	convertGrauParaDecimal(lati.grau, lati.minuto, lati.segundo, lati.direcao),
            convertGrauParaDecimal(longi.grau, longi.minuto, longi.segundo, longi.direcao)
        	);
        return localResult;
    }
    
    private static Decimal convertGrauParaDecimal(Integer gr, Integer min, Decimal seg, String dir)
    {
        gr = gr == null ? 0 : gr;
        min = min == null ? 0 : min;
        seg = seg == null ? 0 : seg;
        dir = dir == null ? 'S' : dir;
        Decimal fracao = ((min * 60) + seg) / 3600;
        Decimal result = (Math.abs(gr) + fracao);
        return (defineDirecao(dir) * result).setScale(6);
    }
    
    private static Decimal defineDirecao(String dir)
    {
        return (dir == 'S' || dir == 'O' || dir == 'W') ? -1 : 1;
    }
 
}