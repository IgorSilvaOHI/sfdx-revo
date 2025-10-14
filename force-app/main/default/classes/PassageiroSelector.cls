public class PassageiroSelector {
    
    public static List<Passageiro__c> getPassageirosTrechos(List<Id> trechos)
    {
        return
            [
                SELECT Contato__c 
                FROM Passageiro__c 
                WHERE Trecho__c IN :trechos
            ];
    }
    
    public static List<Passageiro__c> getPassageirosToSurveyBySetVoosIds(Set<Id> voosIds)
    {
        return
            [
                SELECT Id, Contato__c, Contato__r.Email, IdVoo__c
                FROM Passageiro__c 
                WHERE 
                	Trecho__r.Voo__c IN :voosIds AND
                	NoShow__c = false
            ];
    }
    
    public static List<Passageiro__c> getPassageirosByVooId(Id vooId)
    {
        return 
            [
             	SELECT 
                	Contato__c,
                	Trecho__c,
                	Bagagem__c,
                	Peso__c
                FROM Passageiro__c
                WHERE Trecho__r.Voo__c = :vooId
            ];
    }
}