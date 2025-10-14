public class RegraProduto extends fflib_SObjectDomain {

    public RegraProduto(List<RegraProduto__c> sObjectList)
	{
		super(sObjectList);
	}
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new RegraProduto(sObjectList);
		}
	}

    public static RegraProdutoResult trechoValidoParaServico(Id origemId, Id destinoId, DateTime previsaoDecolagem, String quem, List<RegraProduto__c> regras) {
        return trechoValido(true, origemId, destinoId, previsaoDecolagem, quem, regras);
    }

    public static RegraProdutoResult trechoValidoParaVoo(DateTime previsaoDecolagem, String quem, List<RegraProduto__c> regras) {
        return trechoValido(false, null, null, previsaoDecolagem, quem, regras);
    }
    
    public static RegraProdutoResult trechoValido(Boolean servicoValidaLocal, Id origemId, Id destinoId, DateTime previsaoDecolagem, String quem, List<RegraProduto__c> regras) {

        Boolean produtoValido = false;
        Boolean permissaoRestrita = false;

        Long diferencaMinutos = (previsaoDecolagem.getTime() - Datetime.now().getTime()) / (1000 * 60);

        if (regras.isEmpty()) return new RegraProdutoResult(true);

        for (RegraProduto__c regraPositiva : regras) {
            if (!regraPositiva.Ativo__c) continue;
            if (regraPositiva.Acao__c != 'Permitir') continue;

            permissaoRestrita = true;

            if (servicoValidaLocal) { 
                if (RegraProduto.localTrechoInvalido(regraPositiva, origemId, destinoId)) {
                    continue;
                } 
            }

            if (!regraPositiva.DisponivelPara__c.contains(quem)) {
                continue;
            }

            if (RegraProduto.horaTrechoPositiva(regraPositiva, previsaoDecolagem)) {
                continue;
            }
            
            produtoValido = true;
        }
        
        if (!produtoValido && permissaoRestrita) {
            return new RegraProdutoResult(false);
        }

        produtoValido = true;

        for (RegraProduto__c regraNegativa : regras) {
            if (!regraNegativa.Ativo__c) continue;
            if (regraNegativa.Acao__c != 'Restringir') continue;

            if (servicoValidaLocal) {             
                if (RegraProduto.localTrechoInvalido(regraNegativa, origemId, destinoId)) {
                    continue;
                }
            }

            if (!regraNegativa.DisponivelPara__c.contains(quem)) {
                continue;
            }

            if (RegraProduto.horaTrechoNegativa(regraNegativa, previsaoDecolagem)) {
                produtoValido = false;
            }

            if (regraNegativa.MinutosAntecedencia__c > diferencaMinutos) {
                produtoValido = false;
            }
        }
        //SETA REGRAS COM PARAMETROS FIXOS
        RegraProdutoResult regraProdutoResult = new RegraProdutoResult(produtoValido);

        for (RegraProduto__c regraNegativa : regras) {

            if (!regraNegativa.Ativo__c) continue;
            if (regraNegativa.Acao__c != 'RestringirNumeroAssentos') continue;

            if (servicoValidaLocal) {             
                if (RegraProduto.localTrechoInvalido(regraNegativa, origemId, destinoId)) {
                    continue;
                }
            }

            if (!regraNegativa.DisponivelPara__c.contains(quem)) {
                continue;
            }
            
            if (RegraProduto.horaTrechoNegativa(regraNegativa, previsaoDecolagem)) {
                regraProdutoResult.numeroAssentos = regraNegativa.NumeroAssentos__c.intValue();
            }

            if (regraNegativa.MinutosAntecedencia__c > diferencaMinutos) {
                regraProdutoResult.numeroAssentos = regraNegativa.NumeroAssentos__c.intValue();
            }
        }        

        return regraProdutoResult;
    }
    

    private static Boolean horaTrechoPositiva(RegraProduto__c regra, DateTime previsaoDecolagem) {
        return (regra.HorarioInicial__c > previsaoDecolagem.time())
            || (regra.HorarioFinal__c < previsaoDecolagem.time());
    }

    private static Boolean horaTrechoNegativa(RegraProduto__c regra, DateTime previsaoDecolagem) {
        return (regra.HorarioInicial__c <= previsaoDecolagem.time())
            && (regra.HorarioFinal__c >= previsaoDecolagem.time());
    }

    private static Boolean localTrechoInvalido(RegraProduto__c regra, Id origemId, Id destinoId) {
        return (regra.LocalOrigem__c != null && regra.LocalOrigem__c != origemId)
            || (regra.LocalDestino__c != null && regra.LocalDestino__c != destinoId);
    }

    public class RegraProdutoResult {
        public RegraProdutoResult(Boolean valido) {
            this.valido = valido;
        }

        public Boolean valido;
        public Integer numeroAssentos;
    }
}