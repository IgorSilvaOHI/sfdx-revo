public with sharing class ProductSearchController {
    
    /**
     * Busca produtos do objeto Product2 baseado no termo de busca
     * @param searchTerm Termo de busca para filtrar produtos
     * @return Lista de produtos que correspondem ao termo de busca
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> searchProducts(String searchTerm) {
        if (String.isBlank(searchTerm)) {
            return new List<Product2>();
        }
        
        try {
            // Escapar caracteres especiais para evitar injeção SOQL
            String escapedSearchTerm = String.escapeSingleQuotes(searchTerm);
            
            // Query para buscar produtos que contenham o termo de busca no nome ou código
            String query = 'SELECT Id, Name, ProductCode, Description, IsActive ' +
                          'FROM Product2 ' +
                          'WHERE IsActive = true ' +
                          'AND (Name LIKE \'%' + escapedSearchTerm + '%\' ' +
                          'OR ProductCode LIKE \'%' + escapedSearchTerm + '%\') ' +
                          'ORDER BY Name ' +
                          'LIMIT 50';
            
            List<Product2> products = Database.query(query);
            return products;
            
        } catch (Exception e) {
            System.debug('Erro ao buscar produtos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar produtos: ' + e.getMessage());
        }
    }
    
    /**
     * Busca um produto específico pelo ID
     * @param productId ID do produto
     * @return Produto encontrado ou null
     */
    @AuraEnabled(cacheable=true)
    public static Product2 getProductById(String productId) {
        if (String.isBlank(productId)) {
            return null;
        }
        
        try {
            List<Product2> products = [
                SELECT Id, Name, ProductCode, Description, IsActive
                FROM Product2
                WHERE Id = :productId
                AND IsActive = true
                LIMIT 1
            ];
            
            return products.isEmpty() ? null : products[0];
            
        } catch (Exception e) {
            System.debug('Erro ao buscar produto por ID: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar produto: ' + e.getMessage());
        }
    }
    
    /**
     * Busca todos os produtos ativos (para casos onde não há termo de busca)
     * @return Lista de todos os produtos ativos
     */
    @AuraEnabled(cacheable=true)
    public static List<Product2> getAllActiveProducts() {
        try {
            List<Product2> products = [
                SELECT Id, Name, ProductCode, Description, IsActive
                FROM Product2
                WHERE IsActive = true
                ORDER BY Name
                LIMIT 100
            ];
            
            return products;
            
        } catch (Exception e) {
            System.debug('Erro ao buscar todos os produtos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar produtos: ' + e.getMessage());
        }
    }
}