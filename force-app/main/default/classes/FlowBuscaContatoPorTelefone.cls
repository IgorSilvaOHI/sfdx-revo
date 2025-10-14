public with sharing class FlowBuscaContatoPorTelefone {

    /**
     * Classe wrapper para retornar informações de conta e contato
     */
    public class ResultadoBusca {
        @InvocableVariable(label='ID da Conta' description='ID da conta pessoal encontrada')
        public Id contaId;
        
        @InvocableVariable(label='ID do Contato' description='ID do contato encontrado')
        public Id contatoId;
        
        public ResultadoBusca(Id contaId, Id contatoId) {
            this.contaId = contaId;
            this.contatoId = contatoId;
        }
    }

    @InvocableMethod(label='Busca Conta Pessoal pelo Telefone' description='Busca Conta Pessoal através do Telefone do Contato de forma Inteligente')
    public static List<ResultadoBusca> buscaContatoPorTelefone(List<String> telefones) {

        List<ResultadoBusca> result = new List<ResultadoBusca>();
        
        if (telefones == null || telefones.isEmpty()) {
            return result;
        }

        for (String telefone : telefones) {
            if (String.isBlank(telefone)) {
                continue;
            }

            String telefoneLimpo = telefone.replaceAll('[^0-9+]', '');

            if (String.isBlank(telefoneLimpo)) {
                continue;
            }

            // Busca SOSL em contatos e depois busca as contas pessoais relacionadas
            String soslQuery = 'FIND {' + String.escapeSingleQuotes(telefoneLimpo) + '} IN PHONE FIELDS RETURNING Contact(Id, Name, Phone, MobilePhone, HomePhone, OtherPhone, AssistantPhone, AccountId, Account.RecordType.DeveloperName)';
            
            try {
                List<List<SObject>> searchResults = Search.query(soslQuery);
                
                if (!searchResults.isEmpty() && !searchResults[0].isEmpty()) {
                    List<Contact> contatos = (List<Contact>) searchResults[0];
                    
                    for (Contact contato : contatos) {
                        if (correspondeTelefone(contato, telefoneLimpo)) {
                            result.add(new ResultadoBusca(contato.AccountId, contato.Id));
                            break;
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Erro na busca SOSL: ' + e.getMessage());
            }
        }

        return result;
    }
    
    /**
     * Verifica se o telefone buscado corresponde a algum dos campos de telefone do contato
     */
    private static Boolean correspondeTelefone(Contact contato, String telefoneBuscado) {
        if (String.isBlank(telefoneBuscado)) {
            return false;
        }
        
        // Lista de campos de telefone para verificar
        List<String> camposTelefone = new List<String>{
            contato.Phone,
            contato.MobilePhone,
            contato.HomePhone,
            contato.OtherPhone,
            contato.AssistantPhone
        };
        
        for (String telefone : camposTelefone) {
            if (String.isNotBlank(telefone)) {
                // Remove caracteres especiais para comparação
                String telefoneLimpo = telefone.replaceAll('[^0-9+]', '');
                
                // Verifica se o telefone buscado está contido no telefone do contato ou vice-versa
                if (telefoneLimpo.contains(telefoneBuscado) || telefoneBuscado.contains(telefoneLimpo)) {
                    return true;
                }
            }
        }
        
        return false;
    }

}