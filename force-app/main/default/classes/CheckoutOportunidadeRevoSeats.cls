public without sharing class CheckoutOportunidadeRevoSeats implements INucleoCheckoutOportunidade {

    // #region Variaveis Privadas

    private Opportunity oportunidade;
    private enum TiposDeProdutos {
        RevoSeats
    }    

    // #endregion

    // #region Construtor    

    public CheckoutOportunidadeRevoSeats(Opportunity oportunidade) {
        if (oportunidade == null) {
            throw new OportunidadeNaoEncontradaException(true);
        }

        this.oportunidade = oportunidade;

        Map<Id, String> mapProductsTypes = productRecordTypesIds();        
        Set<String> OpportunityProducts = enumTiposDeProdutosToSet();

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {
            
            if (!OpportunityProducts.contains(mapProductsTypes.get(item.Product2.RecordTypeId))) {
                throw new ProdutoInvalidoNaOportunidadeException(true);
            }
        }
    }    

    // #endregion

    // #region Métodos Públicos

    public void validaOportunidade() {

        if (oportunidade.StageName != 'Cotação' && oportunidade.StageName != 'Aguardando Validação') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        if (oportunidade.AccountId == null) {
            throw new ContaOportunidadeNaoInformadaException(true);
        }

        if (oportunidade.FaturadoPara__c == null) {
            throw new ContaDeFaturamentoNaoInformadaException(true);
        }

        if (oportunidade.OpportunityLineItems.isEmpty()) {
            throw new OportunidadeSemProdutosException(true);
        }

    }    

    public void validaOsProdutos() {

        Map<Id, String> mapProductsTypes = productRecordTypesIds();

        Map<Id, OpportunityLineItem> mapProdutoOportunidade = new Map<Id, OpportunityLineItem>(oportunidade.OpportunityLineItems);

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {
            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.RevoSeats.name()){
                if (item.Quantity <= 0.00) {
                    throw new QuantidadeInvalidoException(true);
                }
            }
        }               
    }

    public void confirmaCheckout(fflib_ISObjectUnitOfWork uow) {

        Map<Id, String> mapProductsTypes = productRecordTypesIds();

        for (OpportunityLineItem item : oportunidade.OpportunityLineItems) {

            if (mapProductsTypes.get(item.Product2.RecordTypeId) == TiposDeProdutos.RevoSeats.name()){
                Servicos.criarServicoOportunidadeRevoSeats(uow, this.oportunidade, item, item.TotalPrice);
            }
        }            

        if (oportunidade.CodigoPromocional__c != null) {
            Opportunities.criaPromocaoOportunidade(uow, oportunidade, oportunidade.CodigoPromocional__c);
        }
        
        oportunidade.StageName = 'Aguardando Pagamento';
        oportunidade.Sistema__c = true;

        ConfiguracaoTempo__c configuracaoTempo = ConfiguracaoTempo__c.getOrgDefaults();
		Decimal tempoParaResetar = configuracaoTempo.MinutosBloqueioReservarVoo__c;

        this.oportunidade.LimitePagamento__c = System.now();
        this.oportunidade.LimitePagamento__c = this.oportunidade.LimitePagamento__c.addMinutes(Integer.valueOf(tempoParaResetar));        

        uow.registerDirty(oportunidade);
    }    

    public void cancelaOportunidade(fflib_ISObjectUnitOfWork uow) {
        
        if (oportunidade.StageName != 'Cotação' && oportunidade.StageName != 'Aguardando Validação'
        && oportunidade.StageName != 'Aguardando Pagamento') {
            throw new OportunidadeFaseInvalidaException(true);
        }

        this.oportunidade.Sistema__c = true;

        this.oportunidade.StageName = 'Cancelado';

        uow.registerDirty(this.oportunidade);

        if (this.oportunidade.PromocoesOportunidades__r != null && !this.oportunidade.PromocoesOportunidades__r.isEmpty()) {
            uow.registerDeleted(this.oportunidade.PromocoesOportunidades__r);
        }

        if (this.oportunidade.Servicos__r != null && !this.oportunidade.Servicos__r.isEmpty()) {
            uow.registerDeleted(this.oportunidade.Servicos__r);
        }
    }

    public void bloqueiaAlteracoesFase(fflib_ISObjectUnitOfWork uow) {

        oportunidade.Sistema__c = false;

        uow.registerDirty(oportunidade);
    }        

    // #endregion

    // #region Métodos Privados

    private Map<Id, String> productRecordTypesIds() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Map<Id, String> result = new Map<Id, String>();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            result.put(rtInfo.getRecordTypeId(), rtInfo.getDeveloperName());
        }

        return result;
    }    

    private Set<String> enumTiposDeProdutosToSet() {
        Set<String> result = new Set<String>();

        for (TiposDeProdutos tipo : TiposDeProdutos.values()) {
            result.add(tipo.name());
        }

        return result;
    }

    // #endregion

    // #region Catálogo de Erros

    public virtual class OpportunityException extends Exception {
        public String codigo;
    
        public OpportunityException(String codigo, String mensagem) {
            this(codigo + ': ' + mensagem);
            this.codigo = codigo;
        }
    }    

    public class OportunidadeNaoEncontradaException extends OpportunityException {
        public OportunidadeNaoEncontradaException(Boolean voidParam) {
            super('CKV-0001','Oportunidade não encontrada!');
        }
    }

    public class OportunidadeFaseInvalidaException extends OpportunityException {
        public OportunidadeFaseInvalidaException(Boolean voidParam) {
            super('CKV-0002','Fase da Oportunidade Inválida!');
        }
    }

    public class OportunidadeSemProdutosException extends OpportunityException {
        public OportunidadeSemProdutosException(Boolean voidParam) {
            super('CKV-0003','Oportunidade sem Produtos!');
        }
    }

    public class ProdutoInvalidoNaOportunidadeException extends OpportunityException {
        public ProdutoInvalidoNaOportunidadeException(Boolean voidParam) {
            super('CKV-0004','Produto Inválido na Oportunidade!');
        }
    }        

    public class QuantidadeInvalidoException extends OpportunityException {
        public QuantidadeInvalidoException(Boolean voidParam) {
            super('CKV-0008','Quantidade inválida!');
        }
    }        

    public class ContaOportunidadeNaoInformadaException extends OpportunityException {
        public ContaOportunidadeNaoInformadaException(Boolean voidParam) {
            super('CKV-0025','Conta da Oportunidade não informada!');
        }
    }           

    public class ContaDeFaturamentoNaoInformadaException extends OpportunityException {
        public ContaDeFaturamentoNaoInformadaException(Boolean voidParam) {
            super('CKV-0026','Conta da Faturamento não informada!');
        }
    }              
    // #endregion    

}