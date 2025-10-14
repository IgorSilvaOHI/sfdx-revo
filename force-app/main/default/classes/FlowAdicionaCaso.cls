public class FlowAdicionaCaso {
    public class FlowAdicionaCasoChamada {
        @InvocableVariable(label='Tabulações IDs' required=true)
        @AuraEnabled
        public List<Id> idTabulacoes;
        
        @InvocableVariable(label='Registros IDs' required=true)
        @AuraEnabled
        public List<Id> recordIds;
        
        @InvocableVariable(label='Last Case IDs' required=true)
        @AuraEnabled
        public List<Id> lastCaseIds;
        
        
        @InvocableVariable(label='Aplica Regra de Atribuições' required=true)
        @AuraEnabled
        public Boolean applyAssignmentRules;
    }
    
    public class FlowAdicionaCasoResultado {
        @InvocableVariable(label='Caso IDs' required=false)
        @AuraEnabled
        public List<Id> idCases;
    }
    
    @InvocableMethod(
        label='Adiciona lista de caso por Tabulação e registro Pai'
        description=''
    )    
    public static List<FlowAdicionaCasoResultado> executar(
        List<FlowAdicionaCasoChamada> chamadas
    ) {
        List<FlowAdicionaCasoResultado> resultados = new List<FlowAdicionaCasoResultado>();
        System.debug('chamadas: ' + chamadas);
        for (FlowAdicionaCasoChamada chamada : chamadas) {
            CaseDomain domain = new CaseDomain();
            
            System.debug('chamada.idTabulacoes: ' + chamada.idTabulacoes);
            System.debug('chamada.recordIds: ' + chamada.recordIds);
            
            List<Case> casos = domain.newInstance(
                chamada.idTabulacoes,
                chamada.recordIds,
                chamada.lastCaseIds
            );
            
            if (chamada.applyAssignmentRules)
                domain.applyAssignmentRule(casos);
            
            insert casos;
            
            FlowAdicionaCasoResultado resultado = new FlowAdicionaCasoResultado();
            resultado.idCases = new List<Id>(new Map<Id, Case>(casos).keyset());
            
            resultados.add(resultado);
        }
        
        return resultados;
    }
}