public class CalculaPrecosParaPesquisa {
    
    public class CalculaPrecosParaPesquisaResult {
        public Boolean invalido;
        public Decimal precoUnitario;
        public Decimal precoRevoSeats;
        public Decimal descontoPerc;
        public Decimal descontoValor;
        public Boolean promocaoValida;
        public String codigoPromocionalApurado;
        public Id idPromocional;
        public Decimal precoFinal;
        public Decimal precoFinalRevoSeats;
        public RegraProduto.RegraProdutoResult regraProdutoResult;
    }

    public static CalculaPrecosParaPesquisaResult calculaPrecosVoos(
        Id produtoId, Id contaId, String quem, Id origemId, Id destinoId, DateTime previsaoDecolagem, 
        Id modeloId, Decimal quantidade, List<RegraProduto__c> regrasProdutos, List<RegraPreco__c> regrasPrecos,
        List<RegraDesconto__c> regrasDescontos, CodigoPromocional__c codigoPromocao, Boolean codigoJaUtilizado, 
        Boolean primeiraCompra, Boolean vooValidaModeloAeronave, Boolean servicoValidaLocal
    ) {
        return calculaPrecos(false, produtoId, contaId, quem, origemId, destinoId, previsaoDecolagem, modeloId, 
            quantidade, regrasProdutos, regrasPrecos, regrasDescontos, codigoPromocao, codigoJaUtilizado, primeiraCompra, 
            vooValidaModeloAeronave, servicoValidaLocal);
    }    

    public static CalculaPrecosParaPesquisaResult calculaPrecosServicos(
        Id produtoId, Id contaId, String quem, Id origemId, Id destinoId, DateTime previsaoDecolagem, 
        Id modeloId, Decimal quantidade, List<RegraProduto__c> regrasProdutos, List<RegraPreco__c> regrasPrecos,
        List<RegraDesconto__c> regrasDescontos, CodigoPromocional__c codigoPromocao, Boolean codigoJaUtilizado, 
        Boolean primeiraCompra, Boolean vooValidaModeloAeronave, Boolean servicoValidaLocal
    ) {
        return calculaPrecos(true, produtoId, contaId, quem, origemId, destinoId, previsaoDecolagem, modeloId, 
            quantidade, regrasProdutos, regrasPrecos, regrasDescontos, codigoPromocao, codigoJaUtilizado, primeiraCompra, 
            vooValidaModeloAeronave, servicoValidaLocal);
    }

    private static CalculaPrecosParaPesquisaResult calculaPrecos(
        Boolean servico,
        Id produtoId, Id contaId, String quem, Id origemId, Id destinoId, DateTime previsaoDecolagem, 
        Id modeloId, Decimal quantidade, List<RegraProduto__c> regrasProdutos, List<RegraPreco__c> regrasPrecos,
        List<RegraDesconto__c> regrasDescontos, CodigoPromocional__c codigoPromocao, Boolean codigoJaUtilizado, 
        Boolean primeiraCompra, Boolean vooValidaModeloAeronave, Boolean servicoValidaLocal
    ) 
    {
        CalculaPrecosParaPesquisaResult result = new CalculaPrecosParaPesquisaResult();
        result.regraProdutoResult = RegraProduto.trechoValido(servicoValidaLocal, origemId, destinoId, previsaoDecolagem, quem, regrasProdutos);
        result.invalido = !result.regraProdutoResult.valido;

        if (result.invalido) return result;

        RegraPreco__c preco = RegraPreco.encontraRegraPreco(servicoValidaLocal, vooValidaModeloAeronave, regrasPrecos, previsaoDecolagem, modeloId, origemId, destinoId, quem);

        result.invalido = preco == null;
        
        if (result.invalido) return result;

        result.precoUnitario = preco.PrecoUnitario__c;
        result.precoRevoSeats = preco.PrecoRevoSeats__c == null || preco.AceitaPagamentoRevoSeats__c == false ? 0 : preco.PrecoRevoSeats__c;

        RegraDesconto.RegraDescontoResult resultDesconto = RegraDesconto.encontraRegraDesconto(regrasDescontos, previsaoDecolagem, quem, 
        contaId, quantidade);

        RegraDesconto.MelhorDescontoResult melhor = RegraDesconto.qualMelhorDesconto(resultDesconto, quantidade, result.precoUnitario);

        result.descontoPerc = melhor.descontoPerc;
        result.descontoValor = melhor.descontoValor;        

        result.promocaoValida = false;
        result.idPromocional = null;

        CodigoPromocional.PromocaoValidaProduto promocao = CodigoPromocional.encontraMelhorPromocao(
            codigoPromocao, contaId, produtoId, servico, previsaoDecolagem.date(), true, result.precoUnitario, quantidade, codigoJaUtilizado, primeiraCompra
        );        

        if (promocao != null) {
            result.promocaoValida = true;
            result.idPromocional = promocao.idPromocional;
            result.codigoPromocionalApurado = promocao.codigoPromocionalApurado;
            result.descontoPerc = promocao.descontoPerc;
            result.descontoValor = promocao.descontoPerc > 0 ? 0 : promocao.descontoValor;
        }        

        result.precoFinal = ((result.precoUnitario - result.descontoValor) * (1 - result.descontoPerc / 100) * quantidade).setScale(4, RoundingMode.HALF_UP);
        result.precoFinalRevoSeats = (result.precoRevoSeats * quantidade).setScale(2, RoundingMode.HALF_UP);

        return result;
    }

}