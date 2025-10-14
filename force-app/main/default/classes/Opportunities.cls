public class Opportunities extends fflib_SObjectDomain implements IOpportunities
{
    public Opportunities(List<Opportunity> sObjectList)
    {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Opportunities(sObjectList);
        }
    }
    
    public static Opportunity criaOportunidade(
        fflib_ISObjectUnitOfWork uow, Id invoicedId, Id customerId, String customerName, String typeOpp, Id promotionId, String codigoReserva, String source
    ) {

        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE AND IsActive = TRUE LIMIT 1];

        Datetime agora = Datetime.now();
        Integer numero = agora.second() + agora.millisecond() + agora.month();

        Opportunity oportunidade = new Opportunity();
        oportunidade.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Oportunidade').getRecordTypeId();
        oportunidade.Type = typeOpp;
        oportunidade.Name = typeOpp + ' - ' + customerName + ' - ' + System.today().format() + ' - ' + codigoReserva;
        oportunidade.StageName = 'Cotação';
        oportunidade.FaturadoPara__c = invoicedId;
        oportunidade.Pricebook2Id = standardPricebook.Id;
        oportunidade.AccountId = customerId;
        oportunidade.CodigoPromocional__c = promotionId;
        oportunidade.closeDate = System.today();
        oportunidade.CodigoReserva__c = codigoReserva;
        oportunidade.Origem__c = source ?? 'Salesforce';
        
        uow.registerNew(oportunidade);

        return oportunidade;
    }


    public static Opportunity criaOportunidadeRevoSeats(
        fflib_ISObjectUnitOfWork uow, Id invoicedId, Id customerId, String customerName, Id promotionId, String codigoReserva, String source
    ) {

        Pricebook2 revoSeatsPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];

        Datetime agora = Datetime.now();
        Integer numero = agora.second() + agora.millisecond() + agora.month();

        Opportunity oportunidade = new Opportunity();
        oportunidade.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('RevoSeats').getRecordTypeId();
        oportunidade.Name = 'Revo Seats - ' + customerName + ' - ' + System.today().format() + ' - ' + codigoReserva;
        oportunidade.StageName = 'Cotação';
        oportunidade.FaturadoPara__c = invoicedId;
        oportunidade.Pricebook2Id = revoSeatsPricebook.Id;
        oportunidade.AccountId = customerId;
        oportunidade.CodigoPromocional__c = promotionId;
        oportunidade.closeDate = System.today();
        oportunidade.CodigoReserva__c = codigoReserva;
        oportunidade.Origem__c = source ?? 'Salesforce';
        
        uow.registerNew(oportunidade);

        Product2 product = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'RevoSeats' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :revoSeatsPricebook.Id AND Product2Id = :product.Id LIMIT 1];

        OpportunityLineItem line = new OpportunityLineItem();
        line.Product2Id = product.Id;
        line.Quantity = 1;
        line.PrecoUnitario__c = pricebookEntry.UnitPrice;
        line.UnitPrice = pricebookEntry.UnitPrice;

        uow.registerNew(line, OpportunityLineItem.OpportunityId, oportunidade);

        return oportunidade;
    }    

    public static OpportunityLineItem criaLinhaShuttleSeat(
        fflib_ISObjectUnitOfWork uow, Id productId, Id aircraftModel, Decimal missionTime, Integer quantity, Boolean appliedPromotion, 
        Datetime flightDateTime, Decimal unitPrice, Decimal revoSeatsPrice, Opportunity oportunidade, Id departurePointId, Id destinationPointId, 
        Id routeId, Decimal totalPrice, Decimal totalPriceRevoSeats, Decimal valueDiscount, Decimal percDiscount
    ) {

        OpportunityLineItem line = new OpportunityLineItem();
        line.Product2Id = productId;
        line.TempoMissao__c = missionTime;
        line.Quantity = quantity;
        line.ModeloSelecionado__c = aircraftModel;
        line.PromocaoAplicada__c = appliedPromotion;
        line.PrevisaoEmbarque__c = flightDateTime;
        line.PrecoUnitario__c = unitPrice;
        line.Pacote__c = null;
        line.Origem__c = departurePointId;
        line.UnitPrice = totalPrice / quantity;
        line.PrecoRevoSeats__c = revoSeatsPrice;
        line.Obrigatorio__c = false;
        line.MalhaVoo__c = routeId;
        line.Empacotado__c = false;
        line.Destino__c = destinationPointId;
        line.DescontoValor__c = valueDiscount;
        line.DescontoPercentual__c = percDiscount;
        line.TotalRevoSeats__c = totalPriceRevoSeats;

        uow.registerNew(line, OpportunityLineItem.OpportunityId, oportunidade);

        return line;
    }        

    public static OpportunityLineItem criaLinhaFullCabin(
        fflib_ISObjectUnitOfWork uow, Id productId, Id aircraftModel, Decimal missionTime, Boolean appliedPromotion, 
        Datetime flightDateTime, Decimal unitPrice, Decimal revoSeatsPrice, Opportunity oportunidade, Id departurePointId, Id destinationPointId, 
        Decimal totalPrice, Decimal totalPriceRevoSeats, Decimal valueDiscount, Decimal percDiscount
    ) {

        OpportunityLineItem line = new OpportunityLineItem();
        line.Product2Id = productId;
        line.ModeloSelecionado__c = aircraftModel;
        line.TempoMissao__c = missionTime;
        line.Quantity = 1;
        line.PromocaoAplicada__c = appliedPromotion;
        line.PrevisaoEmbarque__c = flightDateTime;
        line.PrecoUnitario__c = unitPrice;
        line.Pacote__c = null;
        line.Origem__c = departurePointId;
        line.UnitPrice = totalPrice;
        line.Obrigatorio__c = false;
        line.Empacotado__c = false;
        line.Destino__c = destinationPointId;
        line.DescontoValor__c = valueDiscount;
        line.DescontoPercentual__c = percDiscount;
        line.PrecoRevoSeats__c = revoSeatsPrice;
        line.TotalRevoSeats__c = totalPriceRevoSeats;

        uow.registerNew(line, OpportunityLineItem.OpportunityId, oportunidade);

        return line;
    }        

    public static OpportunityLineItem criaLinhaCharter(
        fflib_ISObjectUnitOfWork uow, Id productId, Id aircraftModel, Decimal missionTime, Boolean appliedPromotion, 
        Datetime flightDateTime, Decimal unitPrice, Decimal revoSeatsPrice, Opportunity oportunidade, Id departurePointId, Id destinationPointId,
        Decimal totalPrice, Decimal totalPriceRevoSeats, Decimal valueDiscount, Decimal percDiscount
    ) {
        Decimal quantidade = missionTime / 60;
        quantidade = quantidade.setScale(2, RoundingMode.HALF_UP);

        OpportunityLineItem line = new OpportunityLineItem();
        line.Product2Id = productId;
        line.ModeloSelecionado__c = aircraftModel;        
        line.TempoMissao__c = missionTime;
        line.Quantity = quantidade;
        line.PromocaoAplicada__c = appliedPromotion;
        line.PrevisaoEmbarque__c = flightDateTime;
        line.PrecoUnitario__c = unitPrice;
        line.Pacote__c = null;
        line.Origem__c = departurePointId;
        line.Destino__c = destinationPointId;
        line.UnitPrice = totalPrice / line.Quantity;
        line.Obrigatorio__c = false;
        line.Empacotado__c = false;
        line.DescontoValor__c = valueDiscount;
        line.DescontoPercentual__c = percDiscount;
        line.PrecoRevoSeats__c = revoSeatsPrice;
        line.TotalRevoSeats__c = totalPriceRevoSeats;

        uow.registerNew(line, OpportunityLineItem.OpportunityId, oportunidade);

        return line;
    }        

    public static OpportunityLineItem criaLinhaServico(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem pacote, Id productId, Integer quantity, 
        Boolean obrigatorio, Boolean empacotado, Boolean porPassageiro, Boolean appliedPromotion, Datetime flightDateTime, Decimal unitPrice, Decimal revoSeatsPrice,  
        Decimal totalPrice, Decimal totalPriceRevoSeats, Decimal valueDiscount, Decimal percDiscount
    ) {

        OpportunityLineItem line = new OpportunityLineItem();
        line.Product2Id = productId;
        line.Quantity = quantity;
        line.PromocaoAplicada__c = appliedPromotion;
        //line.PrevisaoEmbarque__c = flightDateTime;
        line.PrecoUnitario__c = unitPrice;
        line.UnitPrice = totalPrice / quantity;
        line.Obrigatorio__c = obrigatorio;
        line.Empacotado__c = empacotado;
        line.ServicaoPorPassageiro__c = porPassageiro;
        line.DescontoValor__c = valueDiscount;
        line.DescontoPercentual__c = percDiscount;
        line.PrecoRevoSeats__c = revoSeatsPrice;
        line.TotalRevoSeats__c = totalPriceRevoSeats;

        uow.registerNew(line, OpportunityLineItem.OpportunityId, oportunidade);
        uow.registerRelationship(line, OpportunityLineItem.Pacote__c, pacote);
        
        return line;
    }          

    public static PassageiroOportunidade__c criaPassageiroOportunidade(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, Contact passageiro
    ) {

        PassageiroOportunidade__c passOpp = new PassageiroOportunidade__c();

        uow.registerNew(passOpp, PassageiroOportunidade__c.Oportunidade__c, oportunidade);
        uow.registerRelationship(passOpp, PassageiroOportunidade__c.Passageiro__c, passageiro);

        return passOpp;
    }           

    public static LocalOportunidade__c criaLocal(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem item, Integer sequencia, Id localId, Decimal latitude, Decimal longitude
    ) {
        List<LocalOportunidade__c> result = new List<LocalOportunidade__c>();

        LocalOportunidade__c local = new LocalOportunidade__c();

        local.Sequencia__c = sequencia;
        local.Local__c = localId;
        local.Coordenadas__Latitude__s = latitude;
        local.Coordenadas__Longitude__s = longitude;

        uow.registerNew(local, LocalOportunidade__c.Oportunidade__c, oportunidade);
        uow.registerRelationship(local, LocalOportunidade__c.ProdutoOportunidade__c, item);

        return local;
    }    

    public static List<LocalOportunidade__c> criaLocaisOrigemDestino(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, OpportunityLineItem item, Id origemId, Id destinoId
    ) {
        List<LocalOportunidade__c> result = new List<LocalOportunidade__c>();

        LocalOportunidade__c origem = new LocalOportunidade__c();
        origem.Sequencia__c = 10;
        origem.Local__c = origemId;

        result.add(origem);

        uow.registerNew(origem, LocalOportunidade__c.Oportunidade__c, oportunidade);
        uow.registerRelationship(origem, LocalOportunidade__c.ProdutoOportunidade__c, item);

        LocalOportunidade__c destino = new LocalOportunidade__c();
        destino.Sequencia__c = 20;
        destino.Local__c = destinoId;

        result.add(destino);

        uow.registerNew(destino, LocalOportunidade__c.Oportunidade__c, oportunidade);
        uow.registerRelationship(destino, LocalOportunidade__c.ProdutoOportunidade__c, item);
                
        return result;
    }
    

    public static ProdutoPassageiro__c criaProdutoDoPassageiro(
        fflib_ISObjectUnitOfWork uow, PassageiroOportunidade__c passageiro, OpportunityLineItem item, String endereco,
        String cidade, String estado, String zipcode, String pais, String complemento, Integer qtdMalasPequenas, 
        Integer qtdMalasMedias, Integer qtdMalasGrandes, String status, String airline, String flightNumber
    ) {

        ProdutoPassageiro__c produto = new ProdutoPassageiro__c();

        produto.EnderecoServico__c = endereco;
        produto.CidadeServico__c = cidade;
        produto.EstadoServico__c = estado;
        produto.PaisServico__c = pais;
        produto.CEPServico__c = zipcode;
        produto.ComplementoEndereco__c = complemento;
        produto.QtdsMalasPequenas__c = qtdMalasPequenas;
        produto.QtdsMalasGrandes__c = qtdMalasGrandes;
        produto.QtdsMalasMedias__c = qtdMalasMedias;
        produto.Status__c = status ?? 'Pendente';
        produto.CompanhiaAerea__c = airline;
        produto.NumeroVoo__c = flightNumber;

        uow.registerNew(produto, ProdutoPassageiro__c.PassageiroOportunidade__c, passageiro);
        uow.registerRelationship(produto, ProdutoPassageiro__c.ProdutoOportunidade__c, item);

        return produto;
    }          


    public static PromocaoOportunidade__c criaPromocaoOportunidade(
        fflib_ISObjectUnitOfWork uow, Opportunity oportunidade, Id codigoPromocionalId
    ) {

        PromocaoOportunidade__c promocao = new PromocaoOportunidade__c();

        promocao.Promocao__c = codigoPromocionalId;

        uow.registerNew(promocao, PromocaoOportunidade__c.Oportunidade__c, oportunidade);

        return promocao;
    }          
}