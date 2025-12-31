/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceConsultarDebitoAutomatico                           100% * 
*    - InterfaceCadastrarDebitoAutomatico                           100% *
*    - InterfaceRemoverDebitoAutomatico                             100% *
*    - DebitoAutomaticoController                                   100%    *
**************************************************************************/

@isTest
public class InterfaceDebitoAutomaticoTest {

    @TestSetup
    static void makeData(){
        Account novaConta = new Account();
        novaConta.CPF__c = '98390073277';
        novaConta.FirstName = 'Teste';
        novaConta.LastName = 'Teste';
        novaConta.RecordTypeId = IdentificaClienteChatDAO.getPersonRecordType().Id;
        insert novaConta;

        ContaFinanceira__c novaCF = new ContaFinanceira__c();
        novaCF.NomeCliente__c = novaConta.Id;
        novaCF.NumeroConta__c = '37000113748';
        novaCF.StatusConta__c = 'NORM';
        novaCF.UnidadeNegocio__c = '1';
        novaCF.IdConta__c = '813268';
        insert novaCF;
    }

    @isTest
    public static void consultarDebitoAutomatico() {
        // sem cheque especial e com pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"nrBancoAgencia": "033-02041", "numeroContaBancaria": "010238300", "numeroConta": "37000000598", "tipoDebito": 1, "tipoPagamento": "p"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('Santander 033', retorno.get(0).numeroBanco);
        System.AssertEquals('02041', retorno.get(0).numeroAgencia);
        System.AssertEquals('010238300', retorno.get(0).numeroContaBancaria);
        System.AssertEquals('p', retorno.get(0).tipoPagamento);
        System.AssertEquals('Não', retorno.get(0).chequeEspecial);
        System.AssertEquals('Sim', retorno.get(0).tentativaAposVencimento);
    }
    
    @isTest
    public static void consultarDebitoAutomatico2() {
        // com cheque especial e sem pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"nrBancoAgencia": "033-02041", "numeroContaBancaria": "010238300", "numeroConta": "37000000598", "tipoDebito": 1, "tipoPagamento": "o"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('Santander 033', retorno.get(0).numeroBanco);
        System.AssertEquals('02041', retorno.get(0).numeroAgencia);
        System.AssertEquals('010238300', retorno.get(0).numeroContaBancaria);
        System.AssertEquals('o', retorno.get(0).tipoPagamento);
        System.AssertEquals('Sim', retorno.get(0).chequeEspecial);
        System.AssertEquals('Não', retorno.get(0).tentativaAposVencimento);
    }
    
    @isTest
    public static void consultarDebitoAutomatico3() {
        // com cheque especial e com pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"nrBancoAgencia": "033-02041", "numeroContaBancaria": "010238300", "numeroConta": "37000000598", "tipoDebito": 1, "tipoPagamento": "q"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('Santander 033', retorno.get(0).numeroBanco);
        System.AssertEquals('02041', retorno.get(0).numeroAgencia);
        System.AssertEquals('010238300', retorno.get(0).numeroContaBancaria);
        System.AssertEquals('q', retorno.get(0).tipoPagamento);
        System.AssertEquals('Sim', retorno.get(0).chequeEspecial);
        System.AssertEquals('Sim', retorno.get(0).tentativaAposVencimento);
    }
    
    
    @isTest
    public static void consultarDebitoAutomatico4() {
        // sem cheque especial e sem pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"nrBancoAgencia": "033-02041", "numeroContaBancaria": "010238300", "numeroConta": "37000000598", "tipoDebito": 1, "tipoPagamento": "d"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('Santander 033', retorno.get(0).numeroBanco);
        System.AssertEquals('02041', retorno.get(0).numeroAgencia);
        System.AssertEquals('010238300', retorno.get(0).numeroContaBancaria);
        System.AssertEquals('d', retorno.get(0).tipoPagamento);
        System.AssertEquals('Não', retorno.get(0).chequeEspecial);
        System.AssertEquals('Não', retorno.get(0).tentativaAposVencimento);
    }
    
    @isTest
    public static void consultarDebitoAutomaticoErro() {
        // sem cheque especial e sem pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(403);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('-1', retorno.get(0).tipoDebito);
    }
    
    @isTest
    public static void consultarDebitoAutomaticoSemDebitoAtivo() {
        // sem cheque especial e sem pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"nrBancoAgencia": "033-02041", "numeroContaBancaria": "010238300", "numeroConta": "37000000598", "tipoDebito": 0, "tipoPagamento": "d"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/detalhes' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConsultarDebitoAutomatico.RequestConsultarDebito request = new InterfaceConsultarDebitoAutomatico.RequestConsultarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = '';
        request.idEmpresa = '1';
        request.canal = 'chat';
        
        List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito> requestList = new List<InterfaceConsultarDebitoAutomatico.RequestConsultarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceConsultarDebitoAutomatico.ResponseConsultarDebito> retorno = InterfaceConsultarDebitoAutomatico.ConsultarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals(null, retorno.get(0).numeroBanco);
        System.AssertEquals(null, retorno.get(0).numeroAgencia);
        System.AssertEquals(null, retorno.get(0).numeroContaBancaria);
        System.AssertEquals('0', retorno.get(0).tipoDebito);
    }
    
    @isTest
    public static void cadastrarDebitoAutomatico() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/gravar' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito request = new InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.chequeEspecial = 'Sim';
        request.tentativaAposVencimento = 'Sim';
        request.canal = 'chat';
                
        List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito> requestList = new List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceCadastrarDebitoAutomatico.ResponseCadastrarDebito> retorno = InterfaceCadastrarDebitoAutomatico.CadastrarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    @isTest
    public static void cadastrarDebitoAutomaticoD() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/gravar' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito request = new InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.chequeEspecial = 'Não';
        request.tentativaAposVencimento = 'Não';
        request.canal = 'chat';
                
        List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito> requestList = new List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceCadastrarDebitoAutomatico.ResponseCadastrarDebito> retorno = InterfaceCadastrarDebitoAutomatico.CadastrarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    @isTest
    public static void cadastrarDebitoAutomaticoO() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/gravar' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito request = new InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.chequeEspecial = 'Sim';
        request.tentativaAposVencimento = 'Não';
        request.canal = 'chat';
                
        List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito> requestList = new List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceCadastrarDebitoAutomatico.ResponseCadastrarDebito> retorno = InterfaceCadastrarDebitoAutomatico.CadastrarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    @isTest
    public static void cadastrarDebitoAutomaticoP() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/gravar' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito request = new InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.chequeEspecial = 'Não';
        request.tentativaAposVencimento = 'Sim';
        request.canal = 'chat';
                
        List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito> requestList = new List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceCadastrarDebitoAutomatico.ResponseCadastrarDebito> retorno = InterfaceCadastrarDebitoAutomatico.CadastrarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    @isTest
    public static void cadastrarDebitoAutomaticoErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(403);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/gravar' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito request = new InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.chequeEspecial = 'S';
        request.tentativaAposVencimento = 'S';
        request.canal = 'chat';
                
        List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito> requestList = new List<InterfaceCadastrarDebitoAutomatico.RequestCadastrarDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceCadastrarDebitoAutomatico.ResponseCadastrarDebito> retorno = InterfaceCadastrarDebitoAutomatico.CadastrarDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('ERRO', retorno.get(0).statusChamada);
    }
    
    
    @isTest
    public static void removerDebitoAutomatico() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/remover' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceRemoverDebitoAutomatico.RequestRemoverDebito request = new InterfaceRemoverDebitoAutomatico.RequestRemoverDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.tipoPagamento = 'p';
        request.canal = 'chat';
                
        List<InterfaceRemoverDebitoAutomatico.RequestRemoverDebito> requestList = new List<InterfaceRemoverDebitoAutomatico.RequestRemoverDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceRemoverDebitoAutomatico.ResponseRemoverDebito> retorno = InterfaceRemoverDebitoAutomatico.RemoverDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusChamada);
    }
    
    @isTest
    public static void removerDebitoAutomaticoErro() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(403);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/cartao-api-debito-automatico-gke/api/v1/debitoautomatico/contas/remover' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceRemoverDebitoAutomatico.RequestRemoverDebito request = new InterfaceRemoverDebitoAutomatico.RequestRemoverDebito();      
        request.cpf = '49926079857';
        request.numeroConta = '10000019496';
        request.nomeCorrentista = 'USUARIO TESTE';
        request.idEmpresa = '1';
        request.numeroBanco = 'Santander 033';
        request.numeroAgencia = '2042';
        request.numeroContaBancaria = '010238300';
        request.tipoPagamento = 'p';
        request.canal = 'chat';
                
        List<InterfaceRemoverDebitoAutomatico.RequestRemoverDebito> requestList = new List<InterfaceRemoverDebitoAutomatico.RequestRemoverDebito>();
        requestList.add(request);
        
        Test.StartTest();
        List<InterfaceRemoverDebitoAutomatico.ResponseRemoverDebito> retorno = InterfaceRemoverDebitoAutomatico.RemoverDebitoAutomatico(requestList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('ERRO', retorno.get(0).statusChamada);
    }

    @isTest
    public static void getContaFinanceiraTest(){
        String recordId = [SELECT Id FROM ContaFinanceira__c LIMIT 1].Id;
        Test.StartTest();
        ContaFinanceiraBO.ContaFinanceira retorno = DebitoAutomaticoController.getContaFinanceira(recordId);
        Test.StopTest();
        Assert.isNotNull(retorno, 'A conta deve ser retornada');
    }

    @isTest
    public static void getBancosTest(){
        Test.StartTest();
        List<Banco__mdt> retorno = DebitoAutomaticoController.getBancos();
        Test.StopTest();
    }

    @isTest
    public static void consultarDebitoAutomaticoTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarDebitoAutomatico');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        DebitoAutomatico.OutputDebitoAutomatico retorno = DebitoAutomaticoController.consultarDebitoAutomatico('98390073277', '37000113748', 'Teste', '1', 'Cockpit');
        Test.StopTest();

        Assert.areEqual('033-02041', retorno.nrBancoAgencia);
        Assert.areEqual('010238300', retorno.numeroContaBancaria);
        Assert.areEqual('37000000598', retorno.numeroConta);
        Assert.areEqual('1', retorno.tipoDebito);
        Assert.areEqual('o', retorno.tipoPagamento);
    }

    @isTest
    public static void cadastrarDebitoAutomaticoTest(){
    MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        boolean retorno = DebitoAutomaticoController.cadastrarDebitoAutomatico('98390073277', '37000113748', 'Teste', '003', '5555', '3242342', 'o', '1', 'Cockpit');
        Test.StopTest();
        Assert.areEqual(true, retorno);
    }

    @isTest
    public static void removerDebitoAutomaticoTest(){
    MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        boolean retorno = DebitoAutomaticoController.removerDebitoAutomatico('98390073277', '37000113748', 'Teste', '003', '5555', '3242342', 'o', '1', 'Cockpit');
        Test.StopTest();
        Assert.areEqual(true, retorno);
    }

    @isTest
    public static void criarCasoTest(){
    MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        ContaFinanceira__c cf = [SELECT Id, NomeCliente__c FROM ContaFinanceira__c LIMIT 1];

        Test.StartTest();
        DebitoAutomaticoController.criarCaso('Ouvidoria', cf.Id, cf.NomeCliente__c, '1', 'Whatsapp', 'Execução', 'Débito automático', 'Cadastrar débito automático');
        Test.StopTest();

        Assert.areEqual(1, [SELECT COUNT() FROM Case]);
    }
}