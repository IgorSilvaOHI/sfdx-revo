public without sharing class CalculoMissaoHelper 
{
    public static Map<id, CalculoMissaoResult> CalcularMissoes (List<Local__c> trajeto, date data)
    {
        return CalculoMissaoHelper.CalcularMissoes(trajeto, data, CalculoMissaoSingleton.getInstance().aeronaves.values(), true);        
    }
    public static Map<id, CalculoMissaoResult> CalcularMissoes (List<Local__c> trajeto, date data, List<Aeronave__c> aeronaves)
    {
        return CalculoMissaoHelper.CalcularMissoes(trajeto, data, CalculoMissaoSingleton.getInstance().aeronaves.values(), true);        
    }
    public static Map<Id, CalculoMissaoResult> getCalculosViaveis(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId)
    {
        Map<Id, CalculoMissaoResult> calculosViaveis = new Map<Id, CalculoMissaoResult>();
        for(Id aeronaveId : cmrsMapByAeronaveId.keySet())
        {
            CalculoMissaoResult calculo = cmrsMapByAeronaveId.get(aeronaveId);
            //system.debug('viabilidade: ' + calculo.viabilidade);
            if(calculo.viabilidade){
                calculosViaveis.put(aeronaveId, calculo);
            }
        }
        return calculosViaveis;
    }
    
    public static Map<Id, CalculoMissaoResult> getCalculosDeAeronaves(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId, Set<Id> aeronavesSet)
    {
        Map<Id, CalculoMissaoResult> calculosValidos = new Map<Id, CalculoMissaoResult>();
        for(Id aeronaveId : cmrsMapByAeronaveId.keySet())
        {
            if(aeronavesSet.contains(aeronaveId))
            {
                calculosValidos.put(aeronaveId, cmrsMapByAeronaveId.get(aeronaveId));
            }
        }
        return calculosValidos;
    }
    
    public static List<Aeronave__c> getAeronavesDosCalculos(Map<Id, CalculoMissaoResult> cmrsMapByAeronaveId)
    {
        List<Aeronave__c> aeronavesDoCalculo = new List<Aeronave__c>();
        for(CalculoMissaoResult calculo : cmrsMapByAeronaveId.values())
        {
            aeronavesDoCalculo.add(calculo.aeronave);
        }
        return aeronavesDoCalculo;
    }
    
    public static Map<id, CalculoMissaoResult> CalcularMissoes (List<Local__c> trajeto, date data, list<Aeronave__c> aeronaves, Boolean calculaTranslado)
    {
        Map <id, CalculoMissaoResult> resultMap = new Map <id, CalculoMissaoResult>();
        for(aeronave__c aeronave : aeronaves)
        {
            CalculoMissaoResult calc = new CalculoMissaoResult();
            System.debug('antes de executar o cálculo de missão');
            System.debug('aeronave: ' + aeronave);
            System.debug('trajeto: ' + trajeto);
            System.debug('data: ' + data);
            System.debug('Produto: ' + aeronave.ModeloAeronave__r);
            calc.calculaTranslado = calculaTranslado;
            calc.ExecutarCalculoMissao(aeronave, trajeto, data);
            resultMap.put(aeronave.id, calc);
            System.debug('AERONAVE: '  + calc.aeronave.Name);
            System.debug('TEMPO: '  + calc.tempoMissao);
            System.debug('TEMPO Cruzeiro: '  + calc.tempoCruzeiro);
            System.debug('TEMPO SOLO: '  + calc.tempoSolo);
            System.debug('PESO: '  + calc.pesoMaximo);
            System.debug('TRANSLADO IDA: '  + calc.tempoTransladoIda);
            System.debug('TRANSLADO RETORNO: '  + calc.tempoTransladoRetorno);        
            System.debug('CALCULO: ' + calc);
        }
        return resultMap;
        
    }
    
}