@isTest
global class ConsultaReceitaAPITest {

    @isTest
    static void testConsultar() {
        Test.setMock(HttpCalloutMock.class, new ConsultaReceitaAPIMock());

        ConsultaReceitaResposta resposta = ConsultaReceitaAPI.consultar('');
    }

    global class ConsultaReceitaAPIMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();

            ConsultaReceitaResposta data = new ConsultaReceitaResposta();

            res.setStatusCode(200);
            res.setBody(JSON.serialize(data));

            return res;
        }
    }
}