public class ConsultaReceitaSocio {
	@AuraEnabled public String cpf_cnpj_socio;
	@AuraEnabled public String nome;
	@AuraEnabled public String tipo;
	@AuraEnabled public String data_entrada;
	@AuraEnabled public String cpf_representante_legal;
	@AuraEnabled public String nome_representante;
	@AuraEnabled public String faixa_etaria;
	@AuraEnabled public String atualizado_em;
	@AuraEnabled public String pais_id;
	@AuraEnabled public ConsultaReceitaQualificacao qualificacao_socio;
	@AuraEnabled public ConsultaReceitaQualificacao qualificacao_representante;
}