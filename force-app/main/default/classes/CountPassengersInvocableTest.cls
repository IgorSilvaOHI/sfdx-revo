@IsTest
public with sharing class CountPassengersInvocableTest {
    
    @TestSetup
    static void Setup(){
        TestUtil.insereConfiguracoesPersonalizadas();
        TestUtil.SetupAccountContactVooComTrechoEPassageiro('nome', 'email2@email.com', 'Rascunho', 'Não Iniciado');
    }

    @isTest
    static void getVooById() {
        Voo__c voo = [SELECT Id FROM Voo__c LIMIT 1];

        Test.startTest();

        CountPassengersInvocable.countPassengers(new List<Id>{voo.Id});

        Test.stopTest();
    }
}