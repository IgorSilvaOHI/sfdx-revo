public class FlowThrowFaultMessage {
  @InvocableMethod(
    label='Lançar Mensagem de Erro'
    description='Classe Auxiliar para o Flow para Lançar Mensagens de Erro'
  )
  public static void throwMessage(List<String> messages) {
    throw new CustomMessageException(messages[0]);
  }

  public class CustomMessageException extends Exception {
  }
}