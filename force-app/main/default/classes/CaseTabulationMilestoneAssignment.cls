global class CaseTabulationMilestoneAssignment implements Support.MilestoneTriggerTimeCalculator {
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        CaseSelector selectCase = new CaseSelector();
        TabulacaoSelector selectTabulacao = new TabulacaoSelector();
        Case caso = (Case)selectCase.SelectId(caseId);
        Tabulacao__c tabulacao = (Tabulacao__c)selectTabulacao.SelectId(caso.Tabulacao__c);

        return Integer.valueOf(tabulacao.SLAConclusao__c * 60);
	}
}