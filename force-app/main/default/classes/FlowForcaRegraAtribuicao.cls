public class FlowForcaRegraAtribuicao {
    @InvocableMethod(label='Força Execução de Regra de Atribuição' description='')
    public static void executar(List<Id> idCasos) {
        CaseSelector seletorCasos = new CaseSelector();
        List<Case> casos = seletorCasos.selectIn(idCasos);

        CaseDomain domain = new CaseDomain();
        domain.applyAssignmentRule(casos);
        
        update casos;
    }
}