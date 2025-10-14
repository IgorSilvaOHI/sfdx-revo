public class VooSelector 
{    
    public static Voo__c getVooById(Id vooId)
    {
        return 
            [
                SELECT
                    Id, Name, DataVoo__c, Modelo__c, Rota__c, RotaCompleta__c, Cliente__c, 
                    Status__c, TrechosNaoIniciados__c, QtdTrechos__c
                FROM Voo__c 
                WHERE Id = :vooId
            ];
    }
}