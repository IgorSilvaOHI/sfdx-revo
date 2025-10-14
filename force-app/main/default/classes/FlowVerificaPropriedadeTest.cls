@IsTest
public class FlowVerificaPropriedadeTest {
    @IsTest
    static void test() {
        FlowVerificaPropriedade.FlowChamada chamada = new FlowVerificaPropriedade.FlowChamada ();
        chamada.Id = UserInfo.getUserId();
        FlowVerificaPropriedade.executar(new List<FlowVerificaPropriedade.FlowChamada> { chamada } );
        
        Group grupo = [Select Id From Group Where Type = 'Queue' LIMIT 1];
        chamada.Id = grupo.Id;
        FlowVerificaPropriedade.executar(new List<FlowVerificaPropriedade.FlowChamada> { chamada } );

        grupo = [Select Id From Group Where Type = 'RoleAndSubordinatesInternal' LIMIT 1];
        chamada.Id = grupo.Id;
        FlowVerificaPropriedade.executar(new List<FlowVerificaPropriedade.FlowChamada> { chamada } );

        grupo = [Select Id From Group Where Type = 'RoleAndSubordinates' LIMIT 1];
        chamada.Id = grupo.Id;
        FlowVerificaPropriedade.executar(new List<FlowVerificaPropriedade.FlowChamada> { chamada } );
        
        grupo = [Select Id From Group Where Type = 'Role' LIMIT 1];
        chamada.Id = grupo.Id;
        FlowVerificaPropriedade.executar(new List<FlowVerificaPropriedade.FlowChamada> { chamada } );
    }
}