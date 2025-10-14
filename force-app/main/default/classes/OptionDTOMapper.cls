public class OptionDTOMapper {
    
    public static List<AddHorarioMalhaController.OptionDTO> mapProducts(List<Product2> products) {
        List<AddHorarioMalhaController.OptionDTO> options = new List<AddHorarioMalhaController.OptionDTO>();
        for (Product2 product : products) {
            options.add(new AddHorarioMalhaController.OptionDTO(product.Name, product.Id));
        }
        return options;
    }
    
    public static List<AddHorarioMalhaController.OptionDTO> mapMalhas(List<MalhaVoo__c> malhas) {
        List<AddHorarioMalhaController.OptionDTO> options = new List<AddHorarioMalhaController.OptionDTO>();
        for (MalhaVoo__c malha : malhas) {
            options.add(new AddHorarioMalhaController.OptionDTO(malha.Name, malha.Id));
        }
        return options;
    }
}