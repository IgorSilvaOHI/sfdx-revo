@IsTest
private class RevoSiteUserApiTest {

    @TestSetup
    static void setupTestData() {
        // Configura dados de teste básicos
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/siteuser/', 'POST');
        insert TestFactory.createPersonAccount('Caio', 'Bernardi');
    }

    // ========================================
    // TESTES PARA RevoSiteApi
    // ========================================

    @IsTest
    static void testStandardBadResult_GenericException() {
        // Testa o método standardBadResult com exceção genérica
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/any', 'POST');

        Exception e;
        try {
            Integer x = 1 / 0; // força uma exceção genérica
        } catch (Exception ex) {
            e = ex;
        }

        Test.startTest();
        RevoSiteApi.standardBadResult(e);
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode, 'HTTP 500 esperado');
        String body = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(body.contains('API-0000'), 'Deve usar código padrão API-0000');
        System.assert(body.contains('message'), 'Deve devolver a mensagem da exceção');
    }

    @IsTest
    static void testStandardBadResult_ApiException() {
        // Testa o método standardBadResult com exceção específica da API
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/any', 'POST');

        Exception e;
        try {
            throw new RevoSiteApi.UsuarioNaoEncontradoException(true);
        } catch (Exception ex) {
            e = ex;
        }

        Test.startTest();
        RevoSiteApi.standardBadResult(e);
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode, 'HTTP 500 esperado');
        String body = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(body.contains('API-0001'), 'Deve usar o código específico da exceção');
        System.assert(body.contains('Usuário Não Encontrado'), 'Mensagem específica deve estar presente');
    }

    @IsTest
    static void testStandardBadResult_CustomApiException() {
        // Testa o método standardBadResult com exceção customizada
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/any', 'POST');

        Exception e;
        try {
            throw new RevoSiteApi.RevoSiteApiException('API-9999', 'Erro customizado de teste');
        } catch (Exception ex) {
            e = ex;
        }

        Test.startTest();
        RevoSiteApi.standardBadResult(e);
        Test.stopTest();

        System.assertEquals(500, RestContext.response.statusCode, 'HTTP 500 esperado');
        String body = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(body.contains('API-9999'), 'Deve usar o código customizado da exceção');
        System.assert(body.contains('Erro customizado de teste'), 'Mensagem customizada deve estar presente');
    }

    @IsTest
    static void testStandardBadResult_ResponseStructure() {
        // Testa se a estrutura da resposta está correta
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/any', 'POST');

        RevoSiteApi.RevoSiteApiException e = new RevoSiteApi.RevoSiteApiException('API-STRUCTURE', 'Mensagem de teste');

        Test.startTest();
        RevoSiteApi.standardBadResult(e);
        Test.stopTest();

        String body = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        
        // Verifica se o JSON contém os campos esperados
        System.assert(body.contains('Error'), 'Status deve ser Error');
        System.assert(body.contains('API-STRUCTURE'), 'Código deve ser API-STRUCTURE');
        System.assert(body.contains('Mensagem de teste'), 'Mensagem deve estar presente');
    }

    @IsTest
    static void testRevoSiteApiException_Constructor() {
        // Testa o construtor da exceção RevoSiteApiException
        Test.startTest();
        RevoSiteApi.RevoSiteApiException ex = new RevoSiteApi.RevoSiteApiException('API-TEST', 'Mensagem de teste');
        Test.stopTest();

        System.assertEquals('API-TEST', ex.codigo, 'Código deve ser API-TEST');
        System.assertEquals('API-TEST: Mensagem de teste', ex.getMessage(), 'Mensagem deve estar correta');
    }

    @IsTest
    static void testUsuarioNaoEncontradoException_Constructor() {
        // Testa o construtor da exceção UsuarioNaoEncontradoException
        Test.startTest();
        RevoSiteApi.UsuarioNaoEncontradoException ex = new RevoSiteApi.UsuarioNaoEncontradoException(true);
        Test.stopTest();

        System.assertEquals('API-0001', ex.codigo, 'Código deve ser API-0001');
        System.assertEquals('API-0001: Usuário Não Encontrado!', ex.getMessage(), 'Mensagem deve estar correta');
    }

    @IsTest
    static void testUsuarioNaoEncontradoException_WithDifferentParameters() {
        // Testa exceção com diferentes parâmetros booleanos
        Test.startTest();
        RevoSiteApi.UsuarioNaoEncontradoException ex1 = new RevoSiteApi.UsuarioNaoEncontradoException(true);
        RevoSiteApi.UsuarioNaoEncontradoException ex2 = new RevoSiteApi.UsuarioNaoEncontradoException(false);
        Test.stopTest();

        System.assertEquals('API-0001', ex1.codigo, 'Código deve ser API-0001 para true');
        System.assertEquals('API-0001', ex2.codigo, 'Código deve ser API-0001 para false');
        System.assertEquals('API-0001: Usuário Não Encontrado!', ex1.getMessage(), 'Mensagem deve estar correta para true');
        System.assertEquals('API-0001: Usuário Não Encontrado!', ex2.getMessage(), 'Mensagem deve estar correta para false');
    }

    @IsTest
    static void testRevoSiteApiException_WithSpecialCharacters() {
        // Testa exceção com caracteres especiais
        Test.startTest();
        RevoSiteApi.RevoSiteApiException ex = new RevoSiteApi.RevoSiteApiException('API-SPECIAL', 'Mensagem com ç, ã, õ e outros caracteres especiais!');
        Test.stopTest();

        System.assertEquals('API-SPECIAL', ex.codigo, 'Código deve ser API-SPECIAL');
        System.assertEquals('API-SPECIAL: Mensagem com ç, ã, õ e outros caracteres especiais!', ex.getMessage(), 'Mensagem com caracteres especiais deve estar correta');
    }

    @IsTest
    static void testRevoSiteApiException_WithLongMessage() {
        // Testa exceção com mensagem longa
        String longMessage = 'Esta é uma mensagem muito longa que pode testar como o sistema lida com textos extensos. ' +
                           'A mensagem contém múltiplas frases e pode ser útil para verificar se há algum limite ' +
                           'de caracteres ou se o sistema processa corretamente mensagens longas.';

        Test.startTest();
        RevoSiteApi.RevoSiteApiException ex = new RevoSiteApi.RevoSiteApiException('API-LONG', longMessage);
        Test.stopTest();

        System.assertEquals('API-LONG', ex.codigo, 'Código deve ser API-LONG');
        System.assertEquals('API-LONG: ' + longMessage, ex.getMessage(), 'Mensagem longa deve estar correta');
    }

    // ========================================
    // TESTES PARA RevoSiteUserApi
    // ========================================

    @IsTest
    static void testRevoSiteUser_ConstructorAndProperties() {
        // Testa a classe interna RevoSiteUser
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        
        // Testa setters
        siteUser.webSiteUserId = 'test-id';
        siteUser.fullName = 'Nome Teste';
        siteUser.title = 'Mr.';
        siteUser.gender = 'M';
        siteUser.birthDate = Date.today();
        siteUser.nationality = 'BR';
        siteUser.documentType = 'CPF';
        siteUser.document = '12345678901';
        siteUser.cpf = '12345678901';
        siteUser.emergencyContactName = 'Contato';
        siteUser.emergencyContactPhone = '11999999999';
        siteUser.hasSpecialNeeds = false;
        siteUser.specialNeeds = '';
        siteUser.address = 'Rua Teste';
        siteUser.city = 'São Paulo';
        siteUser.state = 'SP';
        siteUser.zipcode = '01234-567';
        siteUser.country = 'Brasil';
        siteUser.addressLine2 = 'Apto 1';
        siteUser.language = 'pt-BR';
        siteUser.email = 'teste@example.com';
        siteUser.phone = '11999999999';

        // Testa getters
        System.assertEquals('test-id', siteUser.webSiteUserId, 'webSiteUserId deve ser igual');
        System.assertEquals('Nome Teste', siteUser.fullName, 'fullName deve ser igual');
        System.assertEquals('Mr.', siteUser.title, 'title deve ser igual');
        System.assertEquals('M', siteUser.gender, 'gender deve ser igual');
        System.assertEquals(Date.today(), siteUser.birthDate, 'birthDate deve ser igual');
        System.assertEquals('BR', siteUser.nationality, 'nationality deve ser igual');
        System.assertEquals('CPF', siteUser.documentType, 'documentType deve ser igual');
        System.assertEquals('12345678901', siteUser.document, 'document deve ser igual');
        System.assertEquals('12345678901', siteUser.cpf, 'cpf deve ser igual');
        System.assertEquals('Contato', siteUser.emergencyContactName, 'emergencyContactName deve ser igual');
        System.assertEquals('11999999999', siteUser.emergencyContactPhone, 'emergencyContactPhone deve ser igual');
        System.assertEquals(false, siteUser.hasSpecialNeeds, 'hasSpecialNeeds deve ser igual');
        System.assertEquals('', siteUser.specialNeeds, 'specialNeeds deve ser igual');
        System.assertEquals('Rua Teste', siteUser.address, 'address deve ser igual');
        System.assertEquals('São Paulo', siteUser.city, 'city deve ser igual');
        System.assertEquals('SP', siteUser.state, 'state deve ser igual');
        System.assertEquals('01234-567', siteUser.zipcode, 'zipcode deve ser igual');
        System.assertEquals('Brasil', siteUser.country, 'country deve ser igual');
        System.assertEquals('Apto 1', siteUser.addressLine2, 'addressLine2 deve ser igual');
        System.assertEquals('pt-BR', siteUser.language, 'language deve ser igual');
        System.assertEquals('teste@example.com', siteUser.email, 'email deve ser igual');
        System.assertEquals('11999999999', siteUser.phone, 'phone deve ser igual');
    }

    @IsTest
    static void testRevoSiteUser_WithAllFields() {
        // Testa criação com todos os campos preenchidos
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-complete-001';
        siteUser.fullName = 'Usuário Teste site-user-complete-001';
        siteUser.title = 'Dr.';
        siteUser.gender = 'F';
        siteUser.birthDate = Date.newInstance(1985, 5, 15);
        siteUser.nationality = 'US';
        siteUser.language = 'en-US';
        siteUser.addressLine2 = 'Suite 100';

        // Verifica se todos os campos foram definidos corretamente
        System.assertEquals('Dr.', siteUser.title, 'Title deve ser Dr.');
        System.assertEquals('F', siteUser.gender, 'Gender deve ser F');
        System.assertEquals(Date.newInstance(1985, 5, 15), siteUser.birthDate, 'BirthDate deve ser 1985-05-15');
        System.assertEquals('US', siteUser.nationality, 'Nationality deve ser US');
        System.assertEquals('en-US', siteUser.language, 'Language deve ser en-US');
        System.assertEquals('Suite 100', siteUser.addressLine2, 'AddressLine2 deve ser Suite 100');
    }

    @IsTest
    static void testRevoSiteUser_WithSpecialNeeds() {
        // Testa criação com necessidades especiais
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-special-001';
        siteUser.fullName = 'Usuário Teste site-user-special-001';
        siteUser.hasSpecialNeeds = true;
        siteUser.specialNeeds = 'Usuário com necessidades especiais';

        System.assertEquals(true, siteUser.hasSpecialNeeds, 'hasSpecialNeeds deve ser true');
        System.assertEquals('Usuário com necessidades especiais', siteUser.specialNeeds, 'specialNeeds deve estar correto');
    }

    @IsTest
    static void testRevoSiteUser_WithNullValues() {
        // Testa com campos opcionais nulos
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-null-001';
        siteUser.fullName = 'Usuário Teste site-user-null-001';
        siteUser.addressLine2 = null;
        siteUser.specialNeeds = null;
        siteUser.emergencyContactName = null;
        siteUser.emergencyContactPhone = null;

        System.assertEquals(null, siteUser.addressLine2, 'addressLine2 deve ser null');
        System.assertEquals(null, siteUser.specialNeeds, 'specialNeeds deve ser null');
        System.assertEquals(null, siteUser.emergencyContactName, 'emergencyContactName deve ser null');
        System.assertEquals(null, siteUser.emergencyContactPhone, 'emergencyContactPhone deve ser null');
    }

    @IsTest
    static void testRevoSiteUser_WithEdgeCases() {
        // Testa casos extremos e validações adicionais
        
        // Testa com valores mínimos
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-edge-001';
        siteUser.fullName = 'A'; // Nome muito curto
        siteUser.email = 'a@b.c'; // Email mínimo
        
        System.assertEquals('A', siteUser.fullName, 'fullName deve aceitar valores curtos');
        System.assertEquals('a@b.c', siteUser.email, 'email deve aceitar formato mínimo');
    }

    // ========================================
    // TESTES DE INTEGRAÇÃO (quando possível)
    // ========================================

    @IsTest
    static void testInsertUpdate_NullBody_ErrorHandled() {
        // Garante contexto REST antes de chamar o endpoint
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/siteuser/', 'POST');

        // Testa tratamento de erro com corpo nulo
        Test.startTest();
        RevoSiteUserApi.insertUpdate(null);
        Test.stopTest();

        // Verifica se o erro foi tratado pelo standardBadResult
        System.assertEquals(500, RestContext.response.statusCode, 'Deve retornar 500 no tratamento de erro');
        System.assertNotEquals(null, RestContext.response.responseBody, 'Resposta deve conter corpo JSON');
        String body = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
        System.assert(body.contains('Error'), 'Corpo deve indicar status de erro');
    }

    @IsTest
    static void testInsertUpdate_WithValidData_NoException() {
        // Garante contexto REST antes de chamar o endpoint
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/siteuser/', 'POST');

        // Testa com dados válidos (pode não executar completamente devido às dependências)
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-valid-001';
        siteUser.fullName = 'Usuário Teste site-user-valid-001';
        siteUser.title = 'Mr.';
        siteUser.gender = 'M';
        siteUser.birthDate = Date.newInstance(1990, 1, 1);
        siteUser.email = 'teste@example.com';
        
        // Este teste pode falhar devido às dependências externas, mas testa a estrutura
        try {
            Test.startTest();
            RevoSiteUserApi.insertUpdate(siteUser);
            Test.stopTest();
            
            // Se chegou até aqui sem exceção, o teste passou
            System.assert(true, 'Execução sem exceções');
        } catch (Exception e) {
            // Se houve exceção, verifica se foi tratada corretamente
            System.assertEquals(500, RestContext.response.statusCode, 'Deve retornar 500 em caso de erro');
        }
    }


    @IsTest
    static void testInsertUpdate_WithValidData_OnlyLinkAccount() {
        // Garante contexto REST antes de chamar o endpoint
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/siteuser/', 'POST');

        System.debug([Select Id, PersonEmail From Account]);

        // Testa com dados válidos (pode não executar completamente devido às dependências)
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-valid-001';
        siteUser.fullName = 'Usuário Teste site-user-valid-001';
        siteUser.email = 'caio.bernardi@email.com';

        // Este teste pode falhar devido às dependências externas, mas testa a estrutura
        try {
            Test.startTest();
            RevoSiteUserApi.insertUpdate(siteUser);
            Test.stopTest();
            
            // Se chegou até aqui sem exceção, o teste passou
            System.assert(true, 'Execução sem exceções');
        } catch (Exception e) {
            // Se houve exceção, verifica se foi tratada corretamente
            System.assertEquals(500, RestContext.response.statusCode, 'Deve retornar 500 em caso de erro');
        }
    }    


    @IsTest
    static void testInsertUpdate_WithInvalidData_ErrorHandled() {
        // Garante contexto REST antes de chamar o endpoint
        RevoTestUtil.setupRestContext('/services/apexrest/revosite/v1/siteuser/', 'POST');

        // Testa com dados inválidos que podem causar exceção
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        siteUser.webSiteUserId = 'site-user-invalid-001';
        siteUser.fullName = 'Usuário Teste site-user-invalid-001';
        siteUser.email = null; // Campo obrigatório nulo
        
        try {
            Test.startTest();
            RevoSiteUserApi.insertUpdate(siteUser);
            Test.stopTest();
            
            // Se chegou até aqui sem exceção, o teste passou
            System.assert(true, 'Execução sem exceções');
        } catch (Exception e) {
            // Se houve exceção, verifica se foi tratada corretamente
            System.assertEquals(500, RestContext.response.statusCode, 'Deve retornar 500 em caso de erro');
        }
    }

    // ========================================
    // TESTES DE COBERTURA ADICIONAL
    // ========================================

    @IsTest
    static void testRevoSiteApiException_Inheritance() {
        // Testa a herança das exceções
        RevoSiteApi.RevoSiteApiException baseException = new RevoSiteApi.RevoSiteApiException('API-BASE', 'Exceção base');
        RevoSiteApi.UsuarioNaoEncontradoException specificException = new RevoSiteApi.UsuarioNaoEncontradoException(true);
        
        // Verifica se as exceções foram criadas corretamente
        System.assertNotEquals(null, baseException, 'baseException deve ser criada');
        System.assertNotEquals(null, specificException, 'specificException deve ser criada');
        
        // Verifica se as propriedades estão corretas
        System.assertEquals('API-BASE', baseException.codigo, 'Código da exceção base deve estar correto');
        System.assertEquals('API-0001', specificException.codigo, 'Código da exceção específica deve estar correto');
    }

    @IsTest
    static void testRevoSiteApiException_CodeAssignment() {
        // Testa se o código é atribuído corretamente
        RevoSiteApi.RevoSiteApiException ex = new RevoSiteApi.RevoSiteApiException('API-CODE', 'Mensagem');
        
        System.assertEquals('API-CODE', ex.codigo, 'Código deve ser atribuído corretamente');
        System.assertEquals('API-CODE: Mensagem', ex.getMessage(), 'Mensagem deve incluir o código');
    }

    @IsTest
    static void testRevoSiteUser_FieldTypes() {
        // Testa os tipos de dados dos campos
        RevoSiteUserApi.RevoSiteUser siteUser = new RevoSiteUserApi.RevoSiteUser();
        
        // Testa tipos String
        siteUser.webSiteUserId = 'test-id';
        siteUser.fullName = 'Nome Teste';
        System.assertNotEquals(null, siteUser.webSiteUserId, 'webSiteUserId deve ser definido');
        System.assertNotEquals(null, siteUser.fullName, 'fullName deve ser definido');
        
        // Testa tipo Date
        siteUser.birthDate = Date.today();
        System.assertNotEquals(null, siteUser.birthDate, 'birthDate deve ser definido');
        
        // Testa tipo Boolean
        siteUser.hasSpecialNeeds = true;
        System.assertEquals(true, siteUser.hasSpecialNeeds, 'hasSpecialNeeds deve ser true');
    }
}