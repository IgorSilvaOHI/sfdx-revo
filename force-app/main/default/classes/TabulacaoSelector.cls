public class TabulacaoSelector extends SObjectSelector {
    protected override Schema.SObjectType getSObjectType() {
        return Tabulacao__c.sObjectType;
    }

    public List<Tabulacao__c> FindFluxoDeTrabalho(
        String keyword,
        String accountType,
        Boolean fluxoInterno
    ) {
        List<List<SObject>> results = [
            FIND :keyword
            IN ALL FIELDS
            RETURNING
                Tabulacao__c(
                    Id,
                    Name,
                    Descricao__c,
                    FormulaVisibilidade__c
                    WHERE
                        RecordType.DeveloperName = 'FluxoTrabalho'
                        AND PermiteAtendimento__c INCLUDES (:accountType)
                        AND TabulacaoOculta__c = FALSE
                        AND TabulacaoInterna__c = :fluxoInterno
                    ORDER BY Name)
        ];
        return results.get(0);
    }

    protected override string allFieldList() {
        List<String> strList = super.allFieldList().Split(',');
        strList.add('RecordType.DeveloperName');
        return STRING.join(strList, ',');
    }
}