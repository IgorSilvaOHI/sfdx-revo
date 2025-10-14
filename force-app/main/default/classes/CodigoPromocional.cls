public class CodigoPromocional extends fflib_SObjectDomain  {

    public CodigoPromocional(List<CodigoPromocional__c> sObjectList)
	{
		super(sObjectList);
	}
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CodigoPromocional(sObjectList);
		}
	}

    public static Set<Id> itensJaUtilizadosOportunidade = new Set<Id>();
    public static Set<Id> itensJaUtilizadosServicos = new Set<Id>();

    public class PromocaoValidaProduto {
        public Id idPromocional;
        public String codigoPromocionalApurado;
        public Decimal descontoPerc;
        public Decimal descontoValor;
    }

    public static ItemPromocao__c encontraItemPromocaoUtilizado(CodigoPromocional__c promocao, Id produtoId, Decimal quantidade) 
    {
        if (promocao != null) {
            for (ItemPromocao__c item : promocao.ItensPromocoes__r) {

                if (item.Produto__c != produtoId || itensJaUtilizadosServicos.contains(item.Id)) continue;

                if (item.QuantidadeMinima__c <= quantidade) {
                    itensJaUtilizadosServicos.add(item.Id);
                    return item;
                }
            }
        }

        return null;
    }    

    public static PromocaoValidaProduto encontraMelhorPromocao(
        CodigoPromocional__c promocao, Id contaId, Id produtoId, Boolean ehServico, Date data, Boolean consideraData, Decimal precoUnitario, Decimal quantidade, Boolean jaUsado, Boolean primeiraCompra
    ) 
    {
        PromocaoValidaProduto result = new PromocaoValidaProduto();

        if (promocao != null) {
            if (promocaoPermitida(promocao, contaId, jaUsado, primeiraCompra, consideraData, data)) {

                result.idPromocional = promocao.Id;
                result.codigoPromocionalApurado = promocao.Name;
                result.descontoPerc = !ehServico ? promocao.Desconto__c == null || promocao.Desconto__c <= 0 ? 0 
                : promocao.Desconto__c : promocao.DescontoServicos__c == null || promocao.DescontoServicos__c <= 0 ? 0 : promocao.DescontoServicos__c;
                result.descontoValor = 0;

                for (ItemPromocao__c item : promocao.ItensPromocoes__r) {

                    if (item.Produto__c != produtoId || itensJaUtilizadosOportunidade.contains(item.Id)) continue;

                    if (item.QuantidadeMinima__c <= quantidade) {
                        Decimal percentualTodo = quantidade <= item.QuantidadeMaxima__c ? 100 : item.QuantidadeMaxima__c / quantidade * 100;
                        Decimal percentualParte = quantidade <= item.QuantidadeMaxima__c ? 0 : (quantidade - item.QuantidadeMaxima__c) / quantidade * 100;

                        if (item.DescontoUnitario__c > 0) {
                            result.descontoValor = item.DescontoUnitario__c * percentualTodo / 100 + precoUnitario * percentualParte / 100 * result.descontoPerc / 100;
                            result.descontoPerc = 0;
                        } else {
                            result.descontoPerc = item.PercDesconto__c * percentualTodo / 100 + result.descontoPerc * percentualParte / 100;
                            result.descontoValor = 0;
                        }

                        if (item.UsoUnico__c) {
                            itensJaUtilizadosOportunidade.add(item.Id);
                        }

                        break;
                    }
                }

                return result;
            }
        }

        return null;
    }

    public static CodigoPromocional__c clonaModeloPromocao(fflib_ISObjectUnitOfWork uow, CodigoPromocional__c promocaoModelo, Id contaId, String novoCodigoPromocional) {
        
        if (promocaoModelo == null) {
            throw new CheckoutOportunidadeVoo.PromocaoModeloNaoEncontradaException(true);
        }

        if (promocaoModelo.RecordTypeId != codigoPromocionalModeloRecordTypeId()) {
            throw new CheckoutOportunidadeVoo.PromocaoModeloNaoEncontradaException(true);
        }

        CodigoPromocional__c promocaoClonada = new CodigoPromocional__c();

        promocaoClonada.RecordTypeId = codigoPromocionalParceiroRecordTypeId();
        promocaoClonada.Name = novoCodigoPromocional;
        promocaoClonada.Ativo__c = true;
        promocaoClonada.UsoUnico__c = true;
        promocaoClonada.Desconto__c = promocaoModelo.Desconto__c;
        promocaoClonada.DescontoServicos__c = promocaoModelo.DescontoServicos__c;
        promocaoClonada.Conta__c = contaId;
        promocaoClonada.Parceiro__c = promocaoModelo.Parceiro__c;
        promocaoClonada.DataInicial__c = Date.today();
        promocaoClonada.DataFinal__c = Date.today();
        promocaoClonada.GeraCobrancaParceiro__c = promocaoModelo.GeraCobrancaParceiro__c;
        promocaoClonada.ValorCobrancaParceiro__c = promocaoModelo.ValorCobrancaParceiro__c;
        promocaoClonada.Modelo__c = promocaoModelo.Id;

        uow.registerNew(promocaoClonada);

        for (ItemPromocao__c item : promocaoModelo.ItensPromocoes__r) {
            ItemPromocao__c itemClonado = new ItemPromocao__c();
            itemClonado.Produto__c = item.Produto__c;
            itemClonado.QuantidadeMinima__c = item.QuantidadeMinima__c;
            itemClonado.QuantidadeMaxima__c = item.QuantidadeMaxima__c; 
            itemClonado.DescontoUnitario__c = item.DescontoUnitario__c;
            itemClonado.PercDesconto__c = item.PercDesconto__c;
            itemClonado.UsoUnico__c = item.UsoUnico__c;
            
            uow.registerNew(itemClonado);
            uow.registerRelationship(itemClonado, ItemPromocao__c.Promocao__c, promocaoClonada);
        }

        return promocaoClonada;
    }

    private static Boolean promocaoPermitida(CodigoPromocional__c promocao, Id contaId, Boolean jaUsado, Boolean primeiraCompra, Boolean consideraData, Date data) {
      
        if (!promocao.Ativo__c) {
            return false;
        }

        if (promocao.UsoUnico__c && jaUsado) {
            return false;
        }

        if (promocao.PrimeiraCompra__c && !primeiraCompra) {
            return false;
        }

        if (promocao.Conta__c != null && promocao.Conta__c != contaId) {
            return false;
        }

        if (consideraData) {
            if ((promocao.DataInicial__c > data) || (promocao.DataFinal__c < data)) {
                return false;
            }
        }

        if (!promocao.UsoUnico__c && !promocao.PrimeiraCompra__c) {
            if (promocao.SaldoUtilizacao__c <= 0) {
                return false;
            } 
        }
        
        return true;
    }

    private static Id codigoPromocionalParceiroRecordTypeId() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('CodigoPromocional__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'PromocaoParceiro') {
                return rtInfo.getRecordTypeId();
            }
        }        

        return null;
    }    

    private static Id codigoPromocionalModeloRecordTypeId() {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('CodigoPromocional__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'ModeloPromocaoParceiro') {
                return rtInfo.getRecordTypeId();
            }
        }        

        return null;
    }        
}