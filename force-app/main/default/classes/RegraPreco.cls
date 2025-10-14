public class RegraPreco extends fflib_SObjectDomain {
    
    public RegraPreco(List<RegraPreco__c> sObjectList)
	{
		super(sObjectList);
	}
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new RegraPreco(sObjectList);
		}
	}

    public static RegraPreco__c encontraRegraPrecoServico(List<RegraPreco__c> regras, DateTime previsaoDecolagem, Id modeloId, Id origemId, Id destinoId, String quem) {
        return encontraRegraPreco(true, true, regras, previsaoDecolagem, modeloId, origemId, destinoId, quem);
    }

    public static RegraPreco__c encontraRegraPrecoVoo(List<RegraPreco__c> regras, DateTime previsaoDecolagem, Id modeloId, String quem) {
        return encontraRegraPreco(true, true, regras, previsaoDecolagem, modeloId, null, null, quem);
    }

    public static RegraPreco__c encontraRegraPrecoCharter(List<RegraPreco__c> regras, DateTime previsaoDecolagem, Id modeloId, String quem) {
        return encontraRegraPreco(true, true, regras, previsaoDecolagem, modeloId, null, null, quem);
    }

    public static RegraPreco__c encontraRegraPreco(Boolean servicoValidaLocal, Boolean vooValidaModeloAeronave, List<RegraPreco__c> regras, DateTime previsaoDecolagem, Id modeloId, Id origemId, Id destinoId, String quem) {

        List<String> diasSemana = new List<String>{'Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'};

        String dia = diasSemana.get(Integer.valueOf(previsaoDecolagem.format('u')) - 1);
        Long diferencaMinutos = (previsaoDecolagem.getTime() - Datetime.now().getTime()) / (1000 * 60);

        RegraPreco__c selecionado = null;
        Integer espDatas = 0;
        Boolean aeronave = false;
        Boolean local = false;
        Decimal minutos = 0;

        if (regras.isEmpty()) return null;

        for (RegraPreco__c regra : regras) {
            if (!regra.Ativo__c) continue;

            if (servicoValidaLocal) {
                if (RegraPreco.localInvalido(regra, origemId, destinoId)) {
                    continue;                    
                }
            }

            if (RegraPreco.dataHoraInvalida(regra, previsaoDecolagem)) {
                continue;
            } 

            if (!regra.DiaSemana__c.contains(dia))  {
                continue;
            }

            if (vooValidaModeloAeronave) {
                if (regra.ModeloAeronave__c != null && regra.ModeloAeronave__c != modeloId) {
                    continue;
                } 
            }

            if (regra.MinutosAntecedencia__c > diferencaMinutos) {
                continue;
            } 

            Integer tmpEspDatas = regra.DataFinal__c.daysBetween(regra.DataInicial__c);
            Boolean tmpLocal = servicoValidaLocal && (regra.LocalOrigem__c != null || regra.LocalDestino__c != null);
            Boolean tmpAeronave = vooValidaModeloAeronave && regra.ModeloAeronave__c != null;
            Decimal tmpMinutos = regra.MinutosAntecedencia__c;

            /* 1) Priorizar a Escolha quando for selecionada um modelo de aeronave ou local */
            /* 2) Priorizar a Escolha quando for o menor tempo de minutos de antecedencia */
            /* 3) Priorizar a Escolha quando for a seleção de datas mais específica */

            if (selecionado != null) {
                if (aeronave && !tmpAeronave) continue;
                if (local && !tmpLocal) continue;

                if (tmpAeronave == aeronave) {
                    if (tmpMinutos > minutos) continue;
                    if (tmpEspDatas > espDatas) continue;
                }
            } 

            selecionado = regra;
            espDatas = tmpEspDatas;
            aeronave = tmpAeronave;
            local = tmpLocal;
            minutos = tmpMinutos;
        }

        return selecionado;
    }

    private static Boolean dataHoraInvalida(RegraPreco__c regra, Datetime previsaoDecolagem) {
        return (regra.DataInicial__c > previsaoDecolagem.date())
            || (regra.DataFinal__c < previsaoDecolagem.date())
            || (regra.HorarioInicial__c > previsaoDecolagem.time())
            || (regra.HorarioFinal__c < previsaoDecolagem.time());
    }

    private static Boolean localInvalido(RegraPreco__c regra, Id origemId, Id destinoId) {
        return (regra.LocalOrigem__c != null && regra.LocalOrigem__c != origemId)
            || (regra.LocalDestino__c != null && regra.LocalDestino__c != destinoId);
    }    
}