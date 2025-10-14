public with sharing class Pagamentos extends fflib_SObjectDomain implements IPagamentos
{
    
    public Pagamentos(List<Pagamento__c> sObjectList)
    {
        super(sObjectList);
    }
    
    public static IPagamentos newInstance(List<Pagamento__c> sObjectList)
    {
        return (IPagamentos) Application.Domain.newInstance(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Pagamentos(sObjectList);
        }
    }

    public static Pagamento__c criaLinkPagamento(
        fflib_ISObjectUnitOfWork uow, Id oportunidadeId, Id contaId
    ) {

        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Pagamento__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id GatewayPagamento = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'GatewayPagamento') {
                GatewayPagamento = rtInfo.getRecordTypeId();
            }
        }        

        Pagamento__c pagamento = new Pagamento__c();

        pagamento.RecordTypeId = GatewayPagamento;
        pagamento.Conta__c = contaId;
        pagamento.OportunidadeOrigem__c = oportunidadeId;
        pagamento.StatusPagamento__c = 'Pendente';

        uow.registerNew(pagamento);

        return pagamento;
    }


    public static Pagamento__c criaPagamentoVoucher(
        fflib_ISObjectUnitOfWork uow, Id contaDestinoId, LancamentoRevoSeat__c lancamentoRevoSeat, String tipoVoucher
    ) {

        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('Pagamento__c').getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfoMap = describeResult.getRecordTypeInfosById();

        Id VoucherRevoSeats = null;

        for (Schema.RecordTypeInfo rtInfo : recordTypeInfoMap.values()) {
            if (rtInfo.getDeveloperName() == 'VoucherRevoSeats') {
                VoucherRevoSeats = rtInfo.getRecordTypeId();
            }
        }        

        Pagamento__c pagamento = new Pagamento__c();

        pagamento.RecordTypeId = VoucherRevoSeats;
        pagamento.Conta__c = contaDestinoId;
        pagamento.TipoVoucher__c = tipoVoucher;
        pagamento.StatusPagamento__c = 'Efetuado';

        uow.registerNew(pagamento);

        if (lancamentoRevoSeat.id == null) {
            uow.registerRelationship(pagamento, Pagamento__c.RevoseatsOrigem__c, lancamentoRevoSeat);
        } else {
            pagamento.RevoseatsOrigem__c = lancamentoRevoSeat.Id;
        }

        return pagamento;
    }    

    public static TransacaoGateway__c criaTransacaoGateway(
        fflib_ISObjectUnitOfWork uow, Id pagamentoId, String nomeGateway, String metodoPagamento, String transacaoId, String transacaoStatus, 
        String mensagemGateway, Decimal transacaoValor
    ) {
        TransacaoGateway__c transacao = new TransacaoGateway__c();

        transacao.Pagamento__c = pagamentoId;
        transacao.NomeGateway__c = nomeGateway;
        transacao.FormaPagamento__c = metodoPagamento;
        transacao.IdTransacaoGateway__c = transacaoId;
        transacao.StatusGateway__c = transacaoStatus;
        transacao.MensagensGateway__c = mensagemGateway;
        transacao.ValorTransacao__c = transacaoValor;

        uow.registerNew(transacao);

        return transacao;
    }    

    public static Empenho__c criaEmpenho(
        fflib_ISObjectUnitOfWork uow, Id pagamentoId, Id servicoId, Decimal ValorEmpenho
    ) {
        Empenho__c empenho = new Empenho__c();

        empenho.Pagamento__c = pagamentoId;
        empenho.Servico__c = servicoId;
        empenho.ValorEmpenho__c = ValorEmpenho;

        uow.registerNew(empenho);

        return empenho;
    }

    public static Empenho__c atualizaValorEmpenho(
        fflib_ISObjectUnitOfWork uow, Empenho__c empenho, Decimal ValorEmpenho
    ) {

        empenho.ValorEmpenho__c = ValorEmpenho;

        uow.registerDirty(empenho);

        return empenho;
    }           


    public static Empenho__c atualizaValorEmpenhoRevoSeats(
        fflib_ISObjectUnitOfWork uow, Empenho__c empenho, Decimal ValorEmpenhoRevoSeats, Decimal ValorEmpenho
    ) {

        empenho.ValorEmpenho__c = ValorEmpenho;
        empenho.RevoSeatEmpenhado__c = ValorEmpenhoRevoSeats;

        uow.registerDirty(empenho);

        return empenho;
    }               
}