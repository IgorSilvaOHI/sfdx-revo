public class CheckoutOportunidade {

    // #region Variaveis Privadas

    private CheckoutOportunidadeVoo checkoutVoo;
    private CheckoutOportunidadeRevoSeats checkoutRevoSeats;

    // #endregion

    // #region Variaveis Publicas

    public Boolean isRevoSeats { get { return this.checkoutRevoSeats != null; } }
    public Boolean isVoo { get { return this.checkoutVoo != null; } }

    public CheckoutOportunidadeVoo getCheckoutVoo() {
        return this.checkoutVoo;
    }
    public CheckoutOportunidadeRevoSeats getCheckoutRevoSeats() {
        return this.checkoutRevoSeats;
    }

    public INucleoCheckoutOportunidade getCheckoutNucleo() {
        if (this.checkoutRevoSeats != null) {
            return this.checkoutRevoSeats;
        }
        return this.checkoutVoo;
    }

    // #endregion

    // #region Métodos Públicos

    public static INucleoCheckoutOportunidade newInstanceNucleo(Opportunity oportunidade) {
        if (oportunidade.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RevoSeats').getRecordTypeId()) {
            return new CheckoutOportunidadeRevoSeats(oportunidade);
        }
        return new CheckoutOportunidadeVoo(oportunidade);
    }

    public static CheckoutOportunidade newInstance(Opportunity oportunidade) {
        CheckoutOportunidade checkout = new CheckoutOportunidade();
        if (oportunidade.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RevoSeats').getRecordTypeId()) {
            checkout.checkoutRevoSeats = new CheckoutOportunidadeRevoSeats(oportunidade);
            checkout.checkoutVoo = null;
            return checkout;
        }
        checkout.checkoutVoo = new CheckoutOportunidadeVoo(oportunidade);
        checkout.checkoutRevoSeats = null;
        return checkout;
    }

    // #endregion

}