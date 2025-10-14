public class RegraDesconto extends fflib_SObjectDomain {

    public RegraDesconto(List<RegraDesconto__c> sObjectList)
	{
		super(sObjectList);
	}
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new RegraDesconto(sObjectList);
		}
	}

    public class RegraDescontoResult {
        public Decimal descontoPercMax {get; set;}
        public Decimal descontoValorMax {get; set;}

        public RegraDescontoResult() {
            this.descontoPercMax = 0;
            this.descontoValorMax = 0;
        }
    }

    public class MelhorDescontoResult {
        public Decimal descontoPerc {get; set;}
        public Decimal descontoValor {get; set;}
        public Decimal melhorValorSimulado {get; set;}

        public MelhorDescontoResult() {
            this.descontoPerc = 0;
            this.descontoValor = 0;
            this.melhorValorSimulado = 0;
        }
    }    

    public static RegraDescontoResult encontraRegraDesconto(List<RegraDesconto__c> regras, DateTime previsaoDecolagem, String quem, Id contaId, Decimal quantidade) {

        RegraDescontoResult selecionado = new RegraDescontoResult();

        Decimal descontoPercMax = 0;
        Decimal descontoValorMax = 0;

        if (regras.isEmpty()) {
            return selecionado;
        } 

        for (RegraDesconto__c regra : regras) {
            if (!regra.Ativo__c) {
                continue;
            }

            if ((regra.DataInicial__c > previsaoDecolagem.date()) 
            || (regra.DataFinal__c < previsaoDecolagem.date())) {
                continue;
            }

            if (regra.Conta__c != null && regra.Conta__c != contaId) {
                continue;
            }

            if (regra.Tipo__c == 'Fixo') {

                if (regra.Desconto__c > 0) {
                    descontoPercMax = descontoPercMax < regra.Desconto__c ? regra.Desconto__c : descontoPercMax;
                } else {
                    descontoValorMax = descontoValorMax < regra.ValorDesconto__c ? regra.ValorDesconto__c : descontoValorMax;
                }

            } else if (regra.Tipo__c == 'Faixa') {
                if (regra.Faixas_Regras_de_Desconto__r == null) continue;

                for (FaixaRegraDesconto__c faixa : regra.Faixas_Regras_de_Desconto__r) {
                    
                    if ((faixa.FaixaInicial__c > quantidade) 
                    || (faixa.FaixaFinal__c < quantidade) ) {
                        continue;
                    }

                    if (faixa.Desconto__c > 0) {
                        descontoPercMax = descontoPercMax < faixa.Desconto__c ? faixa.Desconto__c : descontoPercMax;
                    } else {
                        descontoValorMax = descontoValorMax < faixa.ValorDesconto__c ? faixa.ValorDesconto__c : descontoValorMax;
                    }
                }
            }
        }

        selecionado.descontoPercMax = descontoPercMax;
        selecionado.descontoValorMax = descontoValorMax;

        return selecionado;
    }

    public static MelhorDescontoResult qualMelhorDesconto(RegraDescontoResult base, Decimal quantidade, Decimal precoUnitario) {
        MelhorDescontoResult result = new MelhorDescontoResult();

        result.melhorValorSimulado = precoUnitario * (base.descontoPercMax / 100);

        if (result.melhorValorSimulado >= base.descontoValorMax) {
            result.descontoPerc = base.descontoPercMax;
            result.descontoValor = 0;
        } else {
            result.descontoPerc = 0;
            result.descontoValor = base.descontoValorMax;
            result.melhorValorSimulado = base.descontoValorMax;
        }

        return result;
    }


}