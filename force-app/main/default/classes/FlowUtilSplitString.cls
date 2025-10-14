public class FlowUtilSplitString {
    public class FlowUtilSplitStringChamada {
        @InvocableVariable(label='String To Split')
        @AuraEnabled public String StringToSplit;

        @InvocableVariable(label='Delimiter')
        @AuraEnabled public String Delimiter;
    }    
    
    public class FlowUtilSplitStringResultado {
        @InvocableVariable(label='List Splitted String')
        @AuraEnabled public List<String> StringSplitted;
    }        
    
    @InvocableMethod(label='String.Split for Flow' description='')
    public static List<FlowUtilSplitStringResultado> executar(List<FlowUtilSplitStringChamada> parameters) {
        List<FlowUtilSplitStringResultado> resultados = new List<FlowUtilSplitStringResultado>();
        for (FlowUtilSplitStringChamada parameter : parameters) {
            FlowUtilSplitStringResultado resultado = new FlowUtilSplitStringResultado();
            
            resultado.StringSplitted = parameter.StringToSplit.split(parameter.Delimiter);
            
            resultados.add(resultado);
        }
        
        return resultados;
    }
}