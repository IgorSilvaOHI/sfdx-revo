public without sharing class PagamentosServiceImpl implements IPagamentosService  {

    // #region Variaveis Privadas

    private Set<String> statusGatewayValidos = new Set<String> { 'Authorized', 'Not Authorized', 'Pending', 'Canceled', 'Refund', 'Undefined' };

    // #endregion


    // #region Métodos Publicos de Pagamentos

    public String criaLinkPagamentoOportunidade(Id pagamentoId) {

        Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

        if (pagamento == null) {
            throw new PagamentoNaoEncontradoException(true);
        }

        String linkPagamento = CalloutGeraLinkPagamento.geraLinkPagamento(pagamento.OportunidadeOrigem__c);            

        Savepoint sp = Database.setSavepoint();

        try {

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaPagamento(pagamento.OportunidadeOrigem__c);

            CheckoutOportunidadeVoo checkout = new CheckoutOportunidadeVoo(oportunidade);

            checkout.atualizaLinkPagamento(uow, linkPagamento);

            uow.commitWork();

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            oportunidade = OpportunitySelector.newInstance().encontraParaPagamento(pagamento.OportunidadeOrigem__c);            

            checkout = new CheckoutOportunidadeVoo(oportunidade);

            checkout.bloqueiaAlteracoesFase(uow2);

            uow2.commitWork();                 

            return linkPagamento;

        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    public Pagamento__c criaPagamentoVoucher(Id contaOrigemID, Id contaDestinoID, String tipoVoucher, Decimal quantidadeRevoSeats) {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Account contaOrigem = AccountsSelector.newInstance().selectById(contaOrigemID);
            Account contaDestino = AccountsSelector.newInstance().selectById(contaDestinoID);

            if (contaOrigem == null || (tipoVoucher == 'Valor Fechado' && contaDestino == null)) {
                throw new ContaNaoEncontradaException(true);
            }

            if (tipoVoucher == 'Valor Aberto' && contaOrigem.SaldoRevoSeats__c <= 0) {
                throw new SaldoRevoSeatsInsuficienteException(true);
            }

            if (tipoVoucher == 'Valor Fechado' && quantidadeRevoSeats > contaOrigem.SaldoRevoSeats__c) {
                throw new QuantidadeRevoSeatsInsuficienteException(true);
            }

            if (tipoVoucher == 'Valor Fechado' && quantidadeRevoSeats <= 0) {
                throw new QuantidadeRevoSeatsInvalidaException(true);
            }

            LancamentoRevoSeat__c lancamentoRevoSeat = new LancamentoRevoSeat__c();
            lancamentoRevoSeat.Conta__c = contaOrigem.Id;
            lancamentoRevoSeat.Quantidade__c = tipoVoucher == 'Valor Aberto' ? contaOrigem.SaldoRevoSeats__c : quantidadeRevoSeats;
            lancamentoRevoSeat.Tipo__c = 'Débito';
            uow.registerNew(lancamentoRevoSeat);

            Id contaDestinoRevisadoId = tipoVoucher == 'Valor Aberto' ? contaOrigem.Id : contaDestino.Id;

            Pagamento__c pagamento = Pagamentos.criaPagamentoVoucher(uow, contaDestinoRevisadoId, lancamentoRevoSeat, tipoVoucher);
            
            uow.commitWork();
            
            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            lancamentoRevoSeat.VoucherDestino__c = pagamento.Id;

            uow2.registerDirty(lancamentoRevoSeat);

            uow2.commitWork();

            return pagamento;

        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    public Pagamento__c criaPagamentoOportunidade(Id oportunidadeID) {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaPagamento(oportunidadeID);

            if (oportunidade.StageName != 'Aguardando Pagamento') {
                throw new StatusInvalidoOportunidadeException(true);
            }

            List<Pagamento__c> pagamentosExistentes = PagamentosSelector.newInstance().selectPagamentoPendenteGatewayOppId(new Set<Id> { oportunidadeID });

            if (!pagamentosExistentes.isEmpty()) {
                throw new LinkdePagamentoJaCriadoException(true);
            }

            Pagamento__c pagamento = Pagamentos.criaLinkPagamento(uow, oportunidade.Id, oportunidade.AccountId);
            
            uow.commitWork();
            
            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            for (Servico__c servico : oportunidade.Servicos__r) {

                if (servico.Status__c != 'PreReservado') continue;

                Empenho__c empenho = Pagamentos.criaEmpenho(uow2, pagamento.Id, servico.Id, 0);
            }

            uow2.commitWork();

            return pagamento;

        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    public void registraTransacaoGateway(
        Id pagamentoId, String nomeGateway, String metodoPagamento, String transacaoId, String transacaoStatus, 
        String mensagemGateway, Decimal transacaoValor
    ) 
    {
        Savepoint sp = Database.setSavepoint();

        try {

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            if (pagamento == null) {
                throw new PagamentoNaoEncontradoException(true);
            }

            if (!statusGatewayValidos.contains(transacaoStatus)) {
                throw new StatusTransacaoInvalidoException(true);
            }

            if (transacaoStatus == 'Authorized' && pagamento.StatusPagamento__c == 'Efetuado') {
                throw new TransacaoJaAutorizadaException(true);
            }

            if (transacaoStatus == 'Canceled' && pagamento.StatusPagamento__c == 'Cancelado') {
                throw new TransacaoJaCanceladaException(true);
            }

            if (transacaoStatus == 'Refund' && pagamento.StatusPagamento__c == 'Cancelado') {
                throw new TransacaoJaCanceladaException(true);
            }        

            for (TransacaoGateway__c transacao : pagamento.TransacesGateway__r) {
                if (transacao.StatusGateway__c == transacaoStatus && transacao.IdTransacaoGateway__c == transacaoId) {
                    throw new TransacaoJaRegistradaException(true);
                }
            }

            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            TransacaoGateway__c trans = Pagamentos.criaTransacaoGateway(
                uow, pagamento.Id, nomeGateway, metodoPagamento, 
                transacaoId, transacaoStatus, mensagemGateway, transacaoValor
            );

            if (transacaoStatus == 'Authorized') {
                pagamento.StatusPagamento__c = 'Efetuado';
                pagamento.ValorPagamento__c = transacaoValor;
            }

            if (transacaoStatus == 'Canceled') {
                pagamento.StatusPagamento__c = 'Cancelado';
                pagamento.ValorPagamento__c = 0;

                for (Empenho__c empenho : pagamento.Empenhos__r) {
                    uow.registerDeleted(empenho);
                }
            }

            if (transacaoStatus == 'Refund') {

                if (pagamento.AguardandoDevolucao__c != transacaoValor) {
                    throw new ValorDevolucaoDiferenteException(true);
                }

                pagamento.ValorPagamento__c = pagamento.ValorPagamento__c > transacaoValor ? pagamento.ValorPagamento__c - transacaoValor : 0;
                pagamento.StatusPagamento__c = pagamento.ValorPagamento__c == 0 ? 'Devolvido' : pagamento.StatusPagamento__c;
                pagamento.AguardandoDevolucao__c = 0;
            }

            uow.registerDirty(pagamento);

            uow.commitWork();

            if (transacaoStatus == 'Authorized') {
                fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

                pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

                confirmaPagamentoComSaldo(uow2, pagamento, pagamento.Empenhos__r);

                uow2.commitWork();
            }


        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    public void confirmaPagamentoOportunidadeComSaldo(Id pagamentoId, Id oportunidadeId)
    {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Opportunity oportunidade = OpportunitySelector.newInstance().encontraParaPagamento(oportunidadeId);

            if (oportunidade.StageName != 'Aguardando Pagamento') {
                throw new StatusInvalidoOportunidadeException(true);
            }

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            if (pagamento.Conta__c != oportunidade.AccountId) {
                throw new PagamentoContaDiferenteServicoException(true);
            }

            if (saldoPagamento(pagamento) <= 0) {
                throw new PagamentoNaoPossuiSaldoException(true);
            }

            for (Servico__c servico : oportunidade.Servicos__r) {

                if (servico.Status__c != 'PreReservado') continue;

                Empenho__c empenho = Pagamentos.criaEmpenho(uow, pagamento.Id, servico.Id, 0);
            }

            uow.commitWork();

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            confirmaPagamentoComSaldo(uow2, pagamento, pagamento.Empenhos__r);

            uow2.commitWork();

        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }

    public void confirmaPagamentoServicoComSaldo(Id pagamentoId, Set<Id> servicoIds) 
    {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            List<Servico__c> servicos = ServicosSelector.newInstance().selectById(servicoIds);

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            for (Servico__c servico : servicos) {
                if (servico.Status__c != 'PreReservado') {
                    throw new StatusInvalidoServicoException(true);
                }

                if (pagamento.Conta__c != servico.ContaComprador__c) {
                    throw new PagamentoContaDiferenteServicoException(true);
                }
            }

            if (pagamento.RecordType.DeveloperName == 'VoucherRevoSeats') {
                if (saldoRevoSeats(pagamento) <= 0) {
                    throw new PagamentoNaoPossuiSaldoException(true);
                }
            } else {
                if (saldoPagamento(pagamento) <= 0) {
                    throw new PagamentoNaoPossuiSaldoException(true);
                }
            }

            for (Servico__c servico : servicos) {

                if (servico.Status__c != 'PreReservado') {
                    throw new StatusInvalidoServicoException(true);
                }

                Empenho__c empenho = Pagamentos.criaEmpenho(uow, pagamento.Id, servico.Id, 0);
            }            

            uow.commitWork();

            fflib_ISObjectUnitOfWork uow2 = Application.UnitOfWork.newInstance();

            pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            if (pagamento.RecordType.DeveloperName == 'VoucherRevoSeats') {
                confirmaPagamentoComSaldoRevoSeats(uow2, pagamento, pagamento.Empenhos__r);
            } else {
                confirmaPagamentoComSaldo(uow2, pagamento, pagamento.Empenhos__r);
            }

            uow2.commitWork();
        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }
    }
    
    public void cancelarPagamentoVoucher(Id pagamentoId) {
        Savepoint sp = Database.setSavepoint();

        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

            Pagamento__c pagamento = PagamentosSelector.newInstance().selectPagamentoGateway(pagamentoId);

            if (pagamento.RecordType.DeveloperName != 'VoucherRevoSeats') {
                throw new PagamentoNaoEhVoucherException(true);
            }

            if (pagamento.StatusPagamento__c == 'Cancelado') {
                throw new PagamentoJaCanceladoException(true);
            }

            if (pagamento.TotalRevoSeatsEmpenhado__c > 0) {
                throw new PagamentoComEmpenhosException(true);
            }

            pagamento.StatusPagamento__c = 'Cancelado';

            uow.registerDirty(pagamento);

            uow.registerDeleted(pagamento.RevoseatsOrigem__r);

            uow.commitWork();
        } catch (Exception e) {
            Database.rollback(sp);
            Database.releaseSavepoint(sp);
            throw e;
        }

    }

    //#endregion

    //#region Métodos Privados

    private void confirmaPagamentoComSaldo(fflib_ISObjectUnitOfWork uow, Pagamento__c pagamento, List<Empenho__c> empenhos) 
    {
        Decimal saldoTotal = saldoPagamento(pagamento);

        for (Empenho__c empenho : empenhos) {

            if (saldoTotal <= 0) break;

            if (sfd(empenho.ValorEmpenho__c) != 0) {
                continue;
            }

            if (empenho.Servico__r.Status__c != 'PreReservado') {
                continue;
            }

            Decimal saldoServico = sfd(empenho.Servico__r.ValorTotal__c) - sfd(empenho.Servico__r.ValorPago__c);

            if (saldoServico <= 0) {
                continue;
            }

            Decimal valorEmpenho = (saldoServico <= saldoTotal) ? saldoServico : saldoTotal;
            saldoTotal = saldoTotal - valorEmpenho;

            Pagamentos.atualizaValorEmpenho(uow, empenho, valorEmpenho);
        }

        // Elimina Empenhos que não puderam ser pagos
        for (Empenho__c empenho : empenhos) {
            if (empenho.ValorEmpenho__c == 0) {
                uow.registerDeleted(empenho);
            }
        }
    }

    private void confirmaPagamentoComSaldoRevoSeats(fflib_ISObjectUnitOfWork uow, Pagamento__c pagamento, List<Empenho__c> empenhos) 
    {
        Decimal saldoTotal = saldoRevoSeats(pagamento);

        Decimal valorFinanceiroConvertidoPagamento = 0;
        Decimal revoSeatsEmpenhados = 0;

        for (Empenho__c empenho : empenhos) {

            if (saldoTotal <= 0) break;

            if (sfd(empenho.ValorEmpenho__c) != 0) {
                continue;
            }

            if (empenho.Servico__r.Status__c != 'PreReservado') {
                continue;
            }

            Decimal saldoServico = sfd(empenho.Servico__r.ValorTotal__c) - sfd(empenho.Servico__r.ValorPago__c);
            Decimal saldoServicoRevoSeats = sfd(empenho.Servico__r.TotalRevoSeats__c) - sfd(empenho.Servico__r.PagoRevoSeats__c);

            if (saldoServico <= 0 || saldoServicoRevoSeats <= 0) {
                continue;
            }

            Decimal valorEmpenhoRevoSeats = (saldoServicoRevoSeats <= saldoTotal) ? saldoServicoRevoSeats : saldoTotal;

            Decimal valorEmpenho = (saldoServicoRevoSeats <= saldoTotal) ? saldoServico : saldoServico * (valorEmpenhoRevoSeats / saldoServicoRevoSeats);

            valorEmpenho = valorEmpenho.setScale(2);

            saldoTotal = saldoTotal - valorEmpenhoRevoSeats;

            valorFinanceiroConvertidoPagamento += valorEmpenho;
            revoSeatsEmpenhados += valorEmpenhoRevoSeats;

            Pagamentos.atualizaValorEmpenhoRevoSeats(uow, empenho, valorEmpenhoRevoSeats, valorEmpenho);
        }

        if (pagamento.RevoseatsOrigem__c != null && revoSeatsEmpenhados > 0) {
            LancamentoRevoSeat__c lancamentoRevoSeat = new LancamentoRevoSeat__c();
            lancamentoRevoSeat.Id = pagamento.RevoseatsOrigem__c;
            lancamentoRevoSeat.Quantidade__c = revoSeatsEmpenhados;
            uow.registerDirty(lancamentoRevoSeat);
        }

        if (valorFinanceiroConvertidoPagamento > 0) {
            pagamento.ValorPagamento__c = valorFinanceiroConvertidoPagamento;
            uow.registerDirty(pagamento);
        }   

        // Elimina Empenhos que não puderam ser pagos
        for (Empenho__c empenho : empenhos) {
            if (empenho.ValorEmpenho__c == 0) {
                uow.registerDeleted(empenho);
            }
        }
    }    

    private Decimal saldoPagamento(Pagamento__c pagamento) {
        return sfd(pagamento.ValorPagamento__c) - (sfd(pagamento.AguardandoDevolucao__c) + sfd(pagamento.TotalEmpenhado__c));
    }

    private Decimal saldoRevoSeats(Pagamento__c pagamento) {
        return sfd(pagamento.RevoSeats__c) - sfd(pagamento.TotalRevoSeatsEmpenhado__c);
    }    

    private Decimal sfd(Decimal value) {
        return (value == null) ? 0 : value;
    }

    //#endregion

    // #region Classe Base de Erros

    public virtual class PagementosException extends Exception {
        public String codigo;
    
        public PagementosException(String codigo, String mensagem) {
            this(codigo + ': ' + mensagem);
            this.codigo = codigo;
        }
    }    
    
    public class StatusInvalidoOportunidadeException extends PagementosException {
        public StatusInvalidoOportunidadeException(Boolean voidParam) {
            super('PKV-0001','Status inválido da Oportunidade para geração de link de Pagamento!');
        }
    }

    public class LinkdePagamentoJaCriadoException extends PagementosException {
        public LinkdePagamentoJaCriadoException(Boolean voidParam) {
            super('PKV-0002','Link de Pagamento já criado para Oportunidade!');
        }
    }

    public class PagamentoNaoEncontradoException extends PagementosException {
        public PagamentoNaoEncontradoException(Boolean voidParam) {
            super('PKV-0003','Pagamento não encontrado!');
        }
    }    

    public class TransacaoJaRegistradaException extends PagementosException {
        public TransacaoJaRegistradaException(Boolean voidParam) {
            super('PKV-0004','Transação já registrada!');
        }
    }        

    public class TransacaoJaAutorizadaException extends PagementosException {
        public TransacaoJaAutorizadaException(Boolean voidParam) {
            super('PKV-0005','Transação já Autorizada!');
        }
    }

    public class TransacaoJaCanceladaException extends PagementosException {
        public TransacaoJaCanceladaException(Boolean voidParam) {
            super('PKV-0006','Transação já Cancelada!');
        }
    }

    public class StatusTransacaoInvalidoException extends PagementosException {
        public StatusTransacaoInvalidoException(Boolean voidParam) {
            super('PKV-0007','Status Transação invalido!');
        }
    }         

    public class ValorDevolucaoDiferenteException extends PagementosException {
        public ValorDevolucaoDiferenteException(Boolean voidParam) {
            super('PKV-0008','Valor da Devolução diferente do Esperado!');
        }
    }

    public class PagamentoNaoPossuiSaldoException extends PagementosException {
        public PagamentoNaoPossuiSaldoException(Boolean voidParam) {
            super('PKV-0009','Pagamento não possui Saldo para Pagamento!');
        }
    }

    public class PagamentoContaDiferenteServicoException extends PagementosException {
        public PagamentoContaDiferenteServicoException(Boolean voidParam) {
            super('PKV-0010','Conta do Pagamento diferente do Serviço!');
        }
    }    

    public class StatusInvalidoServicoException extends PagementosException {
        public StatusInvalidoServicoException(Boolean voidParam) {
            super('PKV-0011','Status inválido do Serviço para pagamento!');
        }
    }        

    public class ContaNaoEncontradaException extends PagementosException {
        public ContaNaoEncontradaException(Boolean voidParam) {
            super('PKV-0012','Conta não encontrada!');
        }
    }         

    public class SaldoRevoSeatsInsuficienteException extends PagementosException {
        public SaldoRevoSeatsInsuficienteException(Boolean voidParam) {
            super('PKV-0013','Saldo RevoSeats insuficiente!');
        }
    }        

    public class QuantidadeRevoSeatsInsuficienteException extends PagementosException {
        public QuantidadeRevoSeatsInsuficienteException(Boolean voidParam) {
            super('PKV-0014','Quantidade RevoSeats insuficiente!');
        }
    }        

    public class QuantidadeRevoSeatsInvalidaException extends PagementosException {
        public QuantidadeRevoSeatsInvalidaException(Boolean voidParam) {
            super('PKV-0015','Quantidade RevoSeats inválida!');
        }
    }        

    public class PagamentoNaoEhVoucherException extends PagementosException {
        public PagamentoNaoEhVoucherException(Boolean voidParam) {
            super('PKV-0016','Pagamento não é um Voucher de Pagamento!');
        }
    }        

    public class PagamentoJaCanceladoException extends PagementosException {
        public PagamentoJaCanceladoException(Boolean voidParam) {
            super('PKV-0017','Voucher de Pagamento já cancelado!');
        }
    }        

    public class PagamentoComEmpenhosException extends PagementosException {
        public PagamentoComEmpenhosException(Boolean voidParam) {
            super('PKV-0018','Voucher de Pagamento com Empenhos não pode ser cancelado!');
        }
    }        

    // #endregion

}