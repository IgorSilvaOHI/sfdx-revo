trigger trgCase on Case (before insert, before update, after insert, after update) {
    new CaseDomain().run();
    new CaseFluxoTrabalhoDomain().run();
    new CaseTrabalhoDomain().run();
}