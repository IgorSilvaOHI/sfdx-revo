public class LocalVooWrapper {
    @AuraEnabled
    public String Value {get; set;}

    @AuraEnabled
    public String FormattedValue {get; set;}
    
    @AuraEnabled
    public Boolean IsCoordenada {get; set;}
}