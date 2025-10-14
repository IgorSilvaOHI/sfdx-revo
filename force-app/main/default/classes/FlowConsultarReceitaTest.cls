@isTest
public  class FlowConsultarReceitaTest {
    
    @isTest
    static void testConsultar() {
        Test.setMock(HttpCalloutMock.class, new ConsultaReceitaAPITest.ConsultaReceitaAPIMock());

        FlowConsultarReceita.FlowChamada chamada = new FlowConsultarReceita.FlowChamada();

        chamada.cnpj = '';
        chamada.jsonFormatado = true;

        FlowConsultarReceita.consultar(new List<FlowConsultarReceita.FlowChamada> { chamada });
    }
}