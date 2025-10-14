public class MalhaVooServiceExceptions {
    public virtual class MalhaVooServiceException extends Exception {}
    public class MalhaNaoInformadaException extends MalhaVooServiceException {}
    public class DataHoraNaoInformadaException extends MalhaVooServiceException {}
}