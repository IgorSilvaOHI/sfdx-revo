public class MalhaVooService {
    
    public static List<AddHorarioMalhaController.OptionDTO> getActiveProducts() {
        List<Product2> products = Product2Selector.newInstance().selectActiveShuttleSeatProducts();
        return OptionDTOMapper.mapProducts(products);
    }
    
    public static List<AddHorarioMalhaController.OptionDTO> getMalhasByProduct(Id productId) {
        if (productId == null) {
            return new List<AddHorarioMalhaController.OptionDTO>();
        }
        
        List<MalhaVoo__c> malhas = MalhaVooSelector.newInstance().selectByProduct(productId);
        return OptionDTOMapper.mapMalhas(malhas);
    }
    
    public static Id createHorarioExtra(Id malhaId, DateTime dataHora) {
        MalhaVooService.validateHorarioExtraInput(malhaId, dataHora);
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        Horarioextradamalha__c horarioExtra = new Horarioextradamalha__c(
            MalhadeVoo__c = malhaId,
            DataHoraExtra__c = dataHora
        );
        
        uow.registerNew(horarioExtra);
        uow.commitWork();
        
        return horarioExtra.Id;
    }
    
    private static void validateHorarioExtraInput(Id malhaId, DateTime dataHora) {
        if (malhaId == null) {
            throw new MalhaVooServiceExceptions.MalhaNaoInformadaException();
        }
        if (dataHora == null) {
            throw new MalhaVooServiceExceptions.DataHoraNaoInformadaException();
        }
    }
}