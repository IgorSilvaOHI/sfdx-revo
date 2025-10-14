public class ConsultaReceitaResposta {
    @AuraEnabled public String cnpj_raiz;
	@AuraEnabled public String razao_social;
	@AuraEnabled public String capital_social;
	@AuraEnabled public String responsavel_federativo;
	@AuraEnabled public String atualizado_em;
	@AuraEnabled public ConsultaReceitaPorte porte;
	@AuraEnabled public ConsultaReceitaNaturezaJuridica natureza_juridica;
	@AuraEnabled public ConsultaReceitaQualificacao qualificacao_do_responsavel;
	@AuraEnabled public List<ConsultaReceitaSocio> socios;
	@AuraEnabled public ConsultaReceitaSimples simples;
	@AuraEnabled public ConsultaReceitaEstabelecimento estabelecimento;
}