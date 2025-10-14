public with sharing class AddHorarioMalhaController {
    public class OptionDTO {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        public OptionDTO(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionDTO> getProducts() {
        return MalhaVooService.getActiveProducts();
    }

    @AuraEnabled(cacheable=true)
    public static List<OptionDTO> getMalhasByProduct(Id productId) {
        return MalhaVooService.getMalhasByProduct(productId);
    }


    @AuraEnabled
    public static Id createHorarioExtra(Id malhaId, DateTime dataHora) {
        return MalhaVooService.createHorarioExtra(malhaId, dataHora);
    }
}