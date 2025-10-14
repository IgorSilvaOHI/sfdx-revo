public class VooDomain 
{
    List<Voo__c> voos;
    //List<SolicitacaoCotacao__c> solicitacoes;
    FINAL String RASCUNHO = 'Rascunho';
    FINAL String RESERVADO = 'Reservado';
    FINAL String CONFIRMADO = 'Confirmado';
    FINAL String EMROTA = 'Em Rota';
    FINAL String EXECUTADO = 'Executado';
    FINAL String EMFATURAMENTO = 'Em Faturamento';
    FINAL String FATURADO = 'Faturado';
    
   /* public VooDomain(SolicitacaoCotacao__c solicitacao)
    {
        solicitacoes = new List<SolicitacaoCotacao__c>();
        solicitacoes.add(solicitacao);
        voos = new List<Voo__c>();
    }*/

    public VooDomain()
    {
        voos = new List<Voo__c>();
    }
        
    /*public void criaVoo(SolicitacaoCotacao__c solicitacao)
    {
        Voo__c voo = new Voo__c();
        voo.Cliente__c = solicitacao.Conta__c;
        voo.SolicitacaoCotacao__c = solicitacao.Id;
        voos.add(voo);
    }*/
    /*
    public SolicitacaoCotacao__c getSolicitacaoUnica()
    {
        return solicitacoes.get(0);
    }*/

    public Boolean checkStatusRascunho(Voo__c voo)
    {
        return voo.Status__c.equals(RASCUNHO);
    }

    public Boolean checkPassageirosCargas(Voo__c voo)
    {        
        return
        (
            (voo.Status__c.equals(RASCUNHO) && voo.QtdTrechos__c > 0) ||
            (
                (
                    voo.Status__c.equals(RESERVADO) ||
                    voo.Status__c.equals(CONFIRMADO)||
                    voo.Status__c.equals(EMROTA)
                ) &&
                voo.TrechosNaoIniciados__c > 0
            )
        );
    }

    public Boolean checkVooNaoGerenciavel(Voo__c voo)
    {
        return
        (
            voo.Status__c.equals(EXECUTADO) ||
            voo.Status__c.equals(EMFATURAMENTO) ||
            voo.Status__c.equals(FATURADO)
        );
    }
}