public interface ICodigoPromocionalSelector {

    CodigoPromocional__c selectByCodigo(String codigoPromocional);

    CodigoPromocional__c selectById(Id codigoPromocionalId);

    List<CodigoPromocional__c> selectById(Set<ID> idSet);

}