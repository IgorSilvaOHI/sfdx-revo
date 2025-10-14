@IsTest
private class RevoSiteCharterSearchTest {

    @TestSetup
    static void setup() {
        RevoTestUtil.ConfigurarProdutosEServicos();
        RevoTestUtil.setupSiteUser('ws-user');
    }

    @IsTest
    static void testSearch() {
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/charter/search', 'POST');

        RevoSiteCharterSearch.CharterSearch param = new RevoSiteCharterSearch.CharterSearch();
        param.webSiteUserId = 'ws-user';
        param.route = new List<RevoSiteCharterSearch.LocalCharter>();
        param.route.add(new RevoSiteCharterSearch.LocalCharter());
        param.route[0].wayPointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SBGR' limit 1].Id;
        param.route[0].sequence = 1;
        param.route.add(new RevoSiteCharterSearch.LocalCharter());
        param.route[1].wayPointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SDOF' limit 1].Id;
        param.route[1].sequence = 2;
        param.flightDate = Date.today().addDays(1);
        param.promotionalCode = 'PROMO10';

        Test.startTest();
        RevoSiteCharterSearch.search(param);
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response.responseBody, 'Resposta deve ter corpo');

        String responseBody = RestContext.response.responseBody.toString(); 

        List<RevoSiteCharterSearch.CharterResults> results = 
            (List<RevoSiteCharterSearch.CharterResults>) JSON.deserialize(responseBody, List<RevoSiteCharterSearch.CharterResults>.class);

        System.assert(results != null && results.size() > 0, 'Deve retornar pelo menos uma configuração de data disponível');
    }

    @IsTest
    static void testSearchWithConfirmation() {
        // Busca dados necessários para criar o charter
        Product2 produto = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'CharterFlight' LIMIT 1];
        Product2 modeloAeronave = [SELECT Id FROM Product2 WHERE RecordType.DeveloperName = 'Modelo' LIMIT 1];
        Local__c origem = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SBGR' LIMIT 1];
        Local__c destino = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SDOF' LIMIT 1];
        
        // Cria parâmetro de checkout para charter
        RevoSiteCheckout.OpportunityCheckout checkoutParam = new RevoSiteCheckout.OpportunityCheckout();
        checkoutParam.webSiteUserId = 'ws-user';
        checkoutParam.confirmCheckout = true;
        checkoutParam.oppotunityType = 'Charter';
        checkoutParam.source = 'Site';
        checkoutParam.promotionalCode = 'PROMO10';
        checkoutParam.priceBlockUntil = DateTime.now().addDays(1);

        // Cria lista de charters
        List<RevoSiteCheckout.Charter> charters = new List<RevoSiteCheckout.Charter>();
        RevoSiteCheckout.Charter charter = new RevoSiteCheckout.Charter();

        Integer quantidadePassageiros = 1;

        charter.key = 'charter-1';
        charter.productId = produto.Id;
        charter.aircraftModelId = modeloAeronave.Id;
        charter.flightDateTime = DateTime.now().addDays(1).addHours(10); // Voo às 10h do dia seguinte
        charter.missionTime = 120; // 2 horas de voo
        charter.unitPrice = 5000;
        charter.percDiscount = 10;
        charter.valueDiscount = 0;
        charter.totalPrice = 4500;
        charter.appliedPromotion = true;

        // Define a rota do charter
        charter.route = new List<RevoSiteCheckout.LocalCharter>();
        RevoSiteCheckout.LocalCharter localOrigem = new RevoSiteCheckout.LocalCharter();
        localOrigem.sequence = 1;
        localOrigem.wayPointId = origem.Id;
        charter.route.add(localOrigem);
        
        RevoSiteCheckout.LocalCharter localDestino = new RevoSiteCheckout.LocalCharter();
        localDestino.sequence = 2;
        localDestino.wayPointId = destino.Id;
        charter.route.add(localDestino);

        // Configura os serviços do charter
        List<ConfiguracaoPacote__c> servicos = [SELECT Id, Empacotado__c, Obrigatorio__c, Posicao__c,
        ProdutoPacote__c, ProdutoPai__c, QuantidadePadrao__c, QuantidadeRelativa__c, Selecionado__c
         FROM ConfiguracaoPacote__c WHERE ProdutoPai__c = :produto.Id];

        List<RevoSiteCheckout.PackageServices> checkoutServices = new List<RevoSiteCheckout.PackageServices>();
        for (ConfiguracaoPacote__c service : servicos) {
            RevoSiteCheckout.PackageServices checkoutService = new RevoSiteCheckout.PackageServices();
            checkoutService.productId = service.ProdutoPacote__c;
            checkoutService.required = service.Obrigatorio__c;
            checkoutService.Bundled = service.Empacotado__c;
            checkoutService.selected = service.Selecionado__c;
            checkoutService.passengerQty = service.QuantidadeRelativa__c == 'Por Passageiros' ? true : false;
            checkoutService.position = service.Posicao__c.intValue();
            checkoutService.unitPrice = 150.00;
            checkoutService.quantity = service.QuantidadePadrao__c.intValue();
            checkoutService.percDiscount = 10;
            checkoutService.valueDiscount = 0;
            checkoutService.totalPrice = 130.00;
            checkoutService.appliedPromotion = true;
            
            // Cria passenger services para cada passageiro se o serviço for por passageiro
            List<RevoSiteCheckout.PassengerService> passengerServices = new List<RevoSiteCheckout.PassengerService>();
            if (checkoutService.passengerQty) {
                for (Integer i = 0; i < quantidadePassageiros; i++) {
                    RevoSiteCheckout.PassengerService passengerService = new RevoSiteCheckout.PassengerService();
                    passengerService.keyPassenger = 'passenger-' + (i + 1);
                    passengerService.serviceAddress = 'Rua Teste ' + (i + 1);
                    passengerService.servicecity = 'São Paulo';
                    passengerService.servicestate = 'SP';
                    passengerService.servicezipcode = '01234-567';
                    passengerService.servicecountry = 'BR';
                    passengerService.serviceaddressLine2 = 'Apto ' + (i + 1);
                    passengerService.serviceAirline = 'LATAM';
                    passengerService.serviceFlightNumber = 'LA1234';
                    passengerService.smallBags = 1;
                    passengerService.mediumBags = 0;
                    passengerService.bigBags = 0;
                    passengerServices.add(passengerService);
                }
            }
            checkoutService.passengerServices = passengerServices;
            checkoutServices.add(checkoutService);
        }
        charter.services = checkoutServices;
        
        // Cria passenger services gerais para o charter
        List<RevoSiteCheckout.PassengerService> charterPassengerServices = new List<RevoSiteCheckout.PassengerService>();
        for (Integer i = 0; i < quantidadePassageiros; i++) {
            RevoSiteCheckout.PassengerService passengerService = new RevoSiteCheckout.PassengerService();
            passengerService.keyPassenger = 'passenger-' + (i + 1);
            passengerService.serviceAddress = 'Rua Teste ' + (i + 1);
            passengerService.servicecity = 'São Paulo';
            passengerService.servicestate = 'SP';
            passengerService.servicezipcode = '01234-567';
            passengerService.servicecountry = 'BR';
            passengerService.serviceaddressLine2 = 'Apto ' + (i + 1);
            passengerService.serviceAirline = 'LATAM';
            passengerService.serviceFlightNumber = 'LA1234';
            passengerService.smallBags = 1;
            passengerService.mediumBags = 0;
            passengerService.bigBags = 0;
            charterPassengerServices.add(passengerService);
        }
        charter.passengerServices = charterPassengerServices;
        charters.add(charter);
        checkoutParam.charters = charters;
        
        // Cria lista de passageiros baseada na quantidade
        List<RevoSiteCheckout.Passenger> passengers = new List<RevoSiteCheckout.Passenger>();
        for (Integer i = 0; i < quantidadePassageiros; i++) {
            RevoSiteCheckout.Passenger passenger = new RevoSiteCheckout.Passenger();
            passenger.key = 'passenger-' + (i + 1);
            passenger.fullName = 'Passageiro ' + (i + 1);
            passenger.birthDate = Date.today().addYears(-30);
            passenger.nationality = 'BR';
            passenger.documentType = 'CPF';
            passenger.document = GeraCpfCnpj.cpf(true);
            passenger.email = 'passageiro' + (i + 1) + '@test.com';
            passenger.phone = '11999999999';
            passenger.hasSpecialNeeds = false;
            passenger.smallBags = 1;
            passenger.mediumBags = 0;
            passenger.bigBags = 0;
            passengers.add(passenger);
        }
        checkoutParam.passengers = passengers;

        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/checkout', 'POST');

        Test.startTest();
        RevoSiteCheckout.checkout(checkoutParam);
        Test.stopTest();
        
        // Verifica se o checkout retornou resposta
        System.assertNotEquals(null, RestContext.response.responseBody, 'Checkout deve retornar resposta');
        
        // Deserializa o retorno do checkout
        String responseBodyString = RestContext.response.responseBody.toString();
        RevoSiteCheckout.CheckoutResult checkoutResult = (RevoSiteCheckout.CheckoutResult) JSON.deserialize(responseBodyString, RevoSiteCheckout.CheckoutResult.class);
        
        // Verifica se gerou ID de oportunidade
        System.assertNotEquals(null, checkoutResult.opportunityId, 'Deve gerar ID de oportunidade');
        System.assertNotEquals('', checkoutResult.opportunityId, 'ID de oportunidade não pode estar vazio');
                
        // Verifica se o status da oportunidade foi definido
        System.assertNotEquals(null, checkoutResult.opportunityStatus, 'Status da oportunidade deve ser definido');
        System.assertNotEquals('', checkoutResult.opportunityStatus, 'Status da oportunidade não pode estar vazio');
    }
}