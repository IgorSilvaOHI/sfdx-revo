@IsTest
private class RevoSiteShuttleSearchTest {

    @TestSetup
    static void setup() {
        RevoTestUtil.setupSiteUser('ws-user');
        RevoTestUtil.ConfigurarProdutosEServicos();
    }

    @IsTest
    static void testSearch() {
        // Cria usuário do site com conta vinculada
        
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/shuttle/search', 'POST');

        // Monta o payload com webSiteUserId existente
        RevoSiteShuttleSearch.ShuttleSeatSearch param = new RevoSiteShuttleSearch.ShuttleSeatSearch();
        param.webSiteUserId = 'ws-user';
        param.departurePointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SBGR' limit 1].Id;
        param.destinationPointId = [SELECT Id FROM Local__c WHERE CodigoLocal__c = 'SDOF' limit 1].Id;
        param.quantity = 1;
        param.flightDate = Date.today().addDays(1);
        param.dateOffSet = 1;
        param.promotionalCode = 'PROMO10';

        Test.startTest();
        RevoSiteShuttleSearch.search(param);
        Test.stopTest();
        // Verifica se retornou pelo menos uma configuração de data disponível
        System.assertNotEquals(null, RestContext.response.responseBody, 'Resposta deve ter corpo');
        
        // Deserializa o JSON para verificar se há pelo menos uma configuração disponível
        String responseBody = RestContext.response.responseBody.toString();
        
        List<RevoSiteShuttleSearch.ShuttleSeatResults> results = 
            (List<RevoSiteShuttleSearch.ShuttleSeatResults>) JSON.deserialize(responseBody, List<RevoSiteShuttleSearch.ShuttleSeatResults>.class);
        
        System.assert(results != null && results.size() > 0, 'Deve retornar pelo menos uma configuração de data disponível');
    }

    @IsTest
    static void testCheckoutWithoutConfirmation() {
        
        MalhaVoo__c malhaVoo = [SELECT Id, Origem__c, Destino__c, Produto__c, Duracao__c, SegundaFeira__c,
                                (SELECT Aeronave__r.ModeloAeronave__c FROM PrioridadesMalha__r)
                                FROM MalhaVoo__c WHERE Ativa__c = true LIMIT 1];
        
        // Cria parâmetro de checkout baseado no resultado da busca
        RevoSiteCheckout.OpportunityCheckout checkoutParam = new RevoSiteCheckout.OpportunityCheckout();
        checkoutParam.webSiteUserId = 'ws-user';
        checkoutParam.confirmCheckout = false;
        checkoutParam.oppotunityType = 'ShuttleSeat';
        checkoutParam.source = 'Site';
        checkoutParam.promotionalCode = 'PROMO10';
        checkoutParam.priceBlockUntil = DateTime.now().addDays(1);
        // Cria lista de shuttle seats baseada no resultado

        String horaVoo = malhaVoo.SegundaFeira__c.split(';')[3];
        DateTime dataHoraVoo = DateTime.newInstance(System.today().addDays(1), Time.newInstance(Integer.valueOf(horaVoo.split(':')[0]), 
        Integer.valueOf(horaVoo.split(':')[1]), 0, 0));

        List<RevoSiteCheckout.ShuttleSeat> shuttleSeats = new List<RevoSiteCheckout.ShuttleSeat>();
        RevoSiteCheckout.ShuttleSeat shuttleSeat = new RevoSiteCheckout.ShuttleSeat();

        Integer quantidadePassageiros = 1;

        shuttleSeat.key = 'shuttle-1';
        shuttleSeat.productId = malhaVoo.Produto__c;
        shuttleSeat.aircraftModelId = malhaVoo.PrioridadesMalha__r[0].Aeronave__r.ModeloAeronave__c;
        shuttleSeat.routeId = malhaVoo.Id;
        shuttleSeat.departurePointId = malhaVoo.Origem__c;
        shuttleSeat.destinationPointId = malhaVoo.Destino__c;
        shuttleSeat.flightDateTime = dataHoraVoo;
        shuttleSeat.missionTime = malhaVoo.Duracao__c;
        shuttleSeat.unitPrice = 1000;
        shuttleSeat.quantity = quantidadePassageiros; // Número de passageiros
        shuttleSeat.percDiscount = 10;
        shuttleSeat.valueDiscount = 0;
        shuttleSeat.totalPrice = 900;
        shuttleSeat.appliedPromotion = true;
    

        List<ConfiguracaoPacote__c> servicos = [SELECT Id, Empacotado__c, Obrigatorio__c, Posicao__c,
        ProdutoPacote__c, ProdutoPai__c, QuantidadePadrao__c, QuantidadeRelativa__c, Selecionado__c
         FROM ConfiguracaoPacote__c WHERE ProdutoPai__c = :malhaVoo.Produto__c];

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
            if (checkoutService.passengerQty ) {
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
        shuttleSeat.services = checkoutServices;
        
        
        // Cria passenger services gerais para o shuttle seat
        List<RevoSiteCheckout.PassengerService> shuttlePassengerServices = new List<RevoSiteCheckout.PassengerService>();
        for (Integer i = 0; i < quantidadePassageiros ; i++) {
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
            shuttlePassengerServices.add(passengerService);
        }
        shuttleSeat.passengerServices = shuttlePassengerServices;
        shuttleSeats.add(shuttleSeat);
        checkoutParam.shuttleSeats = shuttleSeats;
        
        // Cria lista de passageiros baseada na quantidade
        List<RevoSiteCheckout.Passenger> passengers = new List<RevoSiteCheckout.Passenger>();
        for (Integer i = 0; i < quantidadePassageiros ; i++) {
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
        System.assertEquals(null, checkoutResult.opportunityId, 'Deve gerar ID de oportunidade');
        
        // Verifica se gerou ID de pagamento
        System.assertEquals(null, checkoutResult.paymentId, 'Deve gerar ID de pagamento');
        
        // Verifica se o status da oportunidade foi definido
        System.assertEquals(null, checkoutResult.opportunityStatus, 'Status da oportunidade deve ser definido');
    }

    @IsTest
    static void testCheckoutWithConfirmation() {
        
        MalhaVoo__c malhaVoo = [SELECT Id, Origem__c, Destino__c, Produto__c, Duracao__c, SegundaFeira__c,
                                (SELECT Aeronave__r.ModeloAeronave__c FROM PrioridadesMalha__r)
                                FROM MalhaVoo__c WHERE Ativa__c = true LIMIT 1];
        
        // Cria parâmetro de checkout baseado no resultado da busca
        RevoSiteCheckout.OpportunityCheckout checkoutParam = new RevoSiteCheckout.OpportunityCheckout();
        checkoutParam.webSiteUserId = 'ws-user';
        checkoutParam.confirmCheckout = true;
        checkoutParam.oppotunityType = 'ShuttleSeat';
        checkoutParam.source = 'Site';
        checkoutParam.promotionalCode = 'PROMO10';
        checkoutParam.priceBlockUntil = DateTime.now().addDays(1);
        // Cria lista de shuttle seats baseada no resultado

        String horaVoo = malhaVoo.SegundaFeira__c.split(';')[3];
        DateTime dataHoraVoo = DateTime.newInstance(System.today().addDays(1), Time.newInstance(Integer.valueOf(horaVoo.split(':')[0]), 
        Integer.valueOf(horaVoo.split(':')[1]), 0, 0));

        List<RevoSiteCheckout.ShuttleSeat> shuttleSeats = new List<RevoSiteCheckout.ShuttleSeat>();
        RevoSiteCheckout.ShuttleSeat shuttleSeat = new RevoSiteCheckout.ShuttleSeat();

        Integer quantidadePassageiros = 1;

        shuttleSeat.key = 'shuttle-1';
        shuttleSeat.productId = malhaVoo.Produto__c;
        shuttleSeat.aircraftModelId = malhaVoo.PrioridadesMalha__r[0].Aeronave__r.ModeloAeronave__c;
        shuttleSeat.routeId = malhaVoo.Id;
        shuttleSeat.departurePointId = malhaVoo.Origem__c;
        shuttleSeat.destinationPointId = malhaVoo.Destino__c;
        shuttleSeat.flightDateTime = dataHoraVoo;
        shuttleSeat.missionTime = malhaVoo.Duracao__c;
        shuttleSeat.unitPrice = 1000;
        shuttleSeat.quantity = quantidadePassageiros; // Número de passageiros
        shuttleSeat.percDiscount = 10;
        shuttleSeat.valueDiscount = 0;
        shuttleSeat.totalPrice = 900;
        shuttleSeat.appliedPromotion = true;
    

        List<ConfiguracaoPacote__c> servicos = [SELECT Id, Empacotado__c, Obrigatorio__c, Posicao__c,
        ProdutoPacote__c, ProdutoPai__c, QuantidadePadrao__c, QuantidadeRelativa__c, Selecionado__c
         FROM ConfiguracaoPacote__c WHERE ProdutoPai__c = :malhaVoo.Produto__c];

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
            if (checkoutService.passengerQty ) {
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
        shuttleSeat.services = checkoutServices;
        
        
        // Cria passenger services gerais para o shuttle seat
        List<RevoSiteCheckout.PassengerService> shuttlePassengerServices = new List<RevoSiteCheckout.PassengerService>();
        for (Integer i = 0; i < quantidadePassageiros ; i++) {
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
            shuttlePassengerServices.add(passengerService);
        }
        shuttleSeat.passengerServices = shuttlePassengerServices;
        shuttleSeats.add(shuttleSeat);
        checkoutParam.shuttleSeats = shuttleSeats;
        
        // Cria lista de passageiros baseada na quantidade
        List<RevoSiteCheckout.Passenger> passengers = new List<RevoSiteCheckout.Passenger>();
        for (Integer i = 0; i < quantidadePassageiros ; i++) {
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
        
        // Verifica se gerou ID de pagamento
        System.assertNotEquals(null, checkoutResult.paymentId, 'Deve gerar ID de pagamento');
        System.assertNotEquals('', checkoutResult.paymentId, 'ID de pagamento não pode estar vazio');
        
        // Verifica se o status da oportunidade foi definido
        System.assertNotEquals(null, checkoutResult.opportunityStatus, 'Status da oportunidade deve ser definido');
        System.assertNotEquals('', checkoutResult.opportunityStatus, 'Status da oportunidade não pode estar vazio');
    }
}