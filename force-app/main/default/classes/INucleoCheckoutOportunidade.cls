public interface INucleoCheckoutOportunidade {
    void cancelaOportunidade(fflib_ISObjectUnitOfWork uow);
    void bloqueiaAlteracoesFase(fflib_ISObjectUnitOfWork uow);
    void validaOportunidade();
    void validaOsProdutos();
    void confirmaCheckout(fflib_ISObjectUnitOfWork uow);
}