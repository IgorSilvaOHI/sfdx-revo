public class MissoesServiceImpl implements IMissoesService
{
    
    public Map<Id, Missao__c> criarMissoes(fflib_ISObjectUnitOfWork uow, Map<Id, CalculoMissaoResult> mapVooCMR)
    {
        Map<Id, Missao__c> mapVooMissao = Missoes.newInstance(new List<Missao__c>()).criarMissoes(mapVooCMR);
        
        uow.registerNew(mapVooMissao.values());
        
        return mapVooMissao;
    }
    
    private String getTempoMissaoString(CalculoMissaoResult calculo)
    {        
        Decimal tempoSemTraslado = calculo.tempoMissao - (calculo.tempoTransladoIda + calculo.tempoTransladoRetorno);
        Long horas = (tempoSemTraslado/60).round(System.RoundingMode.DOWN);
        Integer minutosInteger = Math.mod(Integer.valueOf(tempoSemTraslado), 60);
        String minutosString = minutosInteger < 10 ? '0'+minutosInteger : String.valueOf(minutosInteger);
        
        return horas + ':' + minutosString;
    }

}