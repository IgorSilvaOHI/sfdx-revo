public with sharing class EnvelopeDAO 
{
    public static List<EnvelopeAeronave__c> getEnvelopeByAircraftId(Id aircraftId)
    {
        return [select id, Peso__c, balanceamento__c from EnvelopeAeronave__c
                where Aeronave__c =: aircraftId ORDER By Ordem__c];
    } 
}