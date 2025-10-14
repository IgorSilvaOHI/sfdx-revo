public interface IMalhaVooSelector {

    MalhaVoo__c malhaDeVooDoProdutoNaData(Id idProduct, Date data, Id origem, Id destino, Datetime menorData, Datetime maiorData);
    List<MalhaVoo__c> selectById(Set<ID> idSet);
    List<MalhaVoo__c> selectByProduct(Id productId);
    
}