public interface IPagamentosService {

    String criaLinkPagamentoOportunidade(Id pagamentoId);

    Pagamento__c criaPagamentoOportunidade(Id oportunidadeID);

    Pagamento__c criaPagamentoVoucher(Id contaOrigemID, Id contaDestinoID, String tipoVoucher, Decimal quantidadeRevoSeats);

    void registraTransacaoGateway(
        Id pagamentoId, String nomeGateway, String metodoPagamento, String transacaoId, String transacaoStatus, 
        String mensagemGateway, Decimal transacaoValor
    );

    void confirmaPagamentoOportunidadeComSaldo(Id pagamentoId, Id oportunidadeId);

    void confirmaPagamentoServicoComSaldo(Id pagamentoId, Set<Id> servicoIds);

    void cancelarPagamentoVoucher(Id pagamentoId);
}