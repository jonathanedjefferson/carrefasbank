@isTest
public class CreditoPessoalTest {

    @TestSetup
    static void makeData(){
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();

        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
            LastName = 'Teste Account',
            CPF__c = '49599020006'
        );
        insert accountNomeCliente;

        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '00977880022825672'
        );
        insert contaFinceira;
    }
    
    @isTest
    public static void consultarContratosTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultaContratos');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaContratos retorno = CreditoPessoalController.consultarContratos('Cockpit', '81488436274', '2', '10000001213');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarContratosTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaContratos retorno = CreditoPessoalController.consultarContratos('Cockpit', '81488436274', '2', '10000001213');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

      @isTest
    public static void consultarPropostaTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultaProposta');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaProposta retorno = CreditoPessoalController.consultarProposta('Cockpit', '81488436274', '2', 12345);
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void consultarPropostaTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaProposta retorno = CreditoPessoalController.consultarProposta('Cockpit', '81488436274', '2', 12345);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void enviarTermoAdesaoTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.EnvioTermo retorno = CreditoPessoalController.enviarTermoAdesao('Cockpit', '81488436274', '2', 12345, 'cliente@email.com');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void enviarTermoAdesaoTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.EnvioTermo retorno = CreditoPessoalController.enviarTermoAdesao('Cockpit', '81488436274', '2', 12345, 'cliente@email.com');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void obterBancosTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalObterBancos');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaBancos retorno = CreditoPessoalController.obterBancos('Cockpit', '81488436274', '2');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void obterBancosTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaBancos retorno = CreditoPessoalController.obterBancos('Cockpit', '81488436274', '2');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void alterarDadosBancariosTestOk(){
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenCsfServicosV2');
        mock.addResponse(200, 'MockCreditoPessoalAlteracaoDadosBancarios');
        Test.setMock(HttpCalloutMock.class, mock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';

        CreditoPessoalTO.ContratoRejeitado contrato = new CreditoPessoalTO.ContratoRejeitado();
        contrato.idContratoGF = 1608128421;
        contrato.idPlano = 'I5536';
        contrato.numeroConta = '37000121311';
        contrato.numeroContrato = 2024091348;
        contrato.numeroAutorizacaoTsys = 328215;
        contrato.valorSolicitado = 25000;

        Test.startTest();
        CreditoPessoalTO.AlteracaoDadosBancarios retorno = CreditoPessoalController.alterarDadosBancarios('Cockpit', '81488436274', '2', '10000001213', 12345, dados, contrato);
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void alterarDadosBancariosTestError(){
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenCsfServicosV2');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';

        CreditoPessoalTO.ContratoRejeitado contrato = new CreditoPessoalTO.ContratoRejeitado();
        contrato.idContratoGF = 1608128421;
        contrato.idPlano = 'I5536';
        contrato.numeroConta = '37000121311';
        contrato.numeroContrato = 2024091348;
        contrato.numeroAutorizacaoTsys = 328215;
        contrato.valorSolicitado = 25000;

        Test.startTest();
        CreditoPessoalTO.AlteracaoDadosBancarios retorno = CreditoPessoalController.alterarDadosBancarios('Cockpit', '81488436274', '2', '10000001213', 12345, dados, contrato);
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void buscarInformacoesClienteTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultarCliente');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaCliente retorno = CreditoPessoalController.consultarCliente('cockpit', '38429392211', '1', '37000025496');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void buscarInformacoesClienteTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.ConsultaCliente retorno = CreditoPessoalController.consultarCliente('cockpit', '38429392211', '1', '37000025496');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    // MockCreditoPessoalConsultaElegibilidade


    @isTest
    public static void iniciarPropostaTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalIniciarProposta');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultaElegibilidade');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalEfetuarSimulacao');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.iniciarProposta('cockpit', '38429392211', '1',
            '96482132081', '10000', '10000', '1');

        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.isNotNull(retorno.idProposta, 'Id da proposta não deve ser nulo.');
    }

    @isTest
    public static void iniciarPropostaTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.iniciarProposta('cockpit', '38429392211', '1',
            '96482132081', '10000', '10000', '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void iniciarPropostaTestErrorElegibilidade(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalIniciarProposta');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.iniciarProposta('cockpit', '38429392211', '1',
            '96482132081', '10000', '10000', '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void iniciarPropostaTestErrorSimulacao(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalIniciarProposta');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultaElegibilidade');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.iniciarProposta('cockpit', '38429392211', '1',
            '96482132081', '10000', '10000', '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void efetuarSimulacaoTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalEfetuarSimulacao');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.efetuarSimulacao('cockpit', '38429392211', '1', '37000025496',
        '36997', '5000', null);
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void efetuarSimulacaoTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.DadosSimulacao retorno = CreditoPessoalController.efetuarSimulacao('cockpit', '38429392211', '1', '37000025496',
        '36997', '5000', null);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void salvarSimulacaoTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalSalvar');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.SalvarSimulacao retorno = CreditoPessoalController.salvarSimulacao('cockpit', '38429392211', '1', '37000025496',
        '36997', '5000', '96482132081');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void salvarSimulacaoTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        CreditoPessoalTO.SalvarSimulacao retorno = CreditoPessoalController.salvarSimulacao('cockpit', '38429392211', '1', '37000025496',
        '36997', '5000', '96482132081');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void salvarDadosBancariosTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalValidarDadosBancarios');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalSalvar');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';
        String jsonDadosBancarios = JSON.serialize(dados);

        Test.StartTest();
        CreditoPessoalTO.SalvarDadosBancarios retorno = CreditoPessoalController.salvarDadosBancarios('cockpit', '38429392211', '1', '37000025496', '36997', jsonDadosBancarios);
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void salvarDadosBancariosTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';
        String jsonDadosBancarios = JSON.serialize(dados);
        
        Test.StartTest();
        CreditoPessoalTO.SalvarDadosBancarios retorno = CreditoPessoalController.salvarDadosBancarios('cockpit', '38429392211', '1', '37000025496', '36997', jsonDadosBancarios);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void contratacaoTestOk(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCreditoPessoalConsultaElegibilidade'); // Mock: {"resultado":true}
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';
        String jsonDadosBancarios = JSON.serialize(dados);

        Test.StartTest();
        CreditoPessoalTO.Contratacao retorno = CreditoPessoalController.contratacao('cockpit', '38429392211', '1', '37000025496', '36997', 'I5636', jsonDadosBancarios, '1');
        Test.StopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void contratacaoTestError(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        CreditoPessoalTO.DadosBancarios dados = new CreditoPessoalTO.DadosBancarios();
        dados.codBanco = '341';
        dados.nomeBanco = 'ITAÚ';
        dados.numeroConta = '16898';
        dados.digitoConta = '2';
        dados.tipoConta = 1;
        dados.agencia = '2';
        String jsonDadosBancarios = JSON.serialize(dados);
        
        Test.StartTest();
        CreditoPessoalTO.Contratacao retorno = CreditoPessoalController.contratacao('cockpit', '38429392211', '1', '37000025496', '36997', 'I5636', jsonDadosBancarios, '1');
        Test.StopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void obterContaFinanceiraTest(){
        
        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];

        Test.StartTest();
        ContaFinanceiraBO.ContaFinanceira retorno = CreditoPessoalController.obterContaFinanceira(cf.Id);
        Test.StopTest();

        Assert.isNotNull(retorno, 'a conta financeira deve ser retornada');
    }

    @isTest
    public static void criarCasoReenvioTermoTest(){

        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

         Map<String, Object> inputs = new Map<String, Object>{
            'accountId' => acc.Id,
            'status' => 'Closed',
            'assunto' => 'Credito Pessoal',
            'evento' => 'Reenvio termo de adesão',
            'origem' => 'Pós Vendas',
            'contaFinanceiraId' => cf.Id,
            'unidadeNegocio' => '1',
            'tipo' => 'Execução',
            'canal' => 'Chat',
            'prioridade' => 'Medium'
        };

        Test.startTest();
        Case retorno = CreditoPessoalController.criarCaso(inputs);
        Test.stopTest();

        Assert.isNotNull(retorno, 'o caso deve ser retornado');
    }
    
    @isTest
    public static void criarCasoReenvioDadosBancoTest(){

        ContaFinanceira__c cf = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

         Map<String, Object> inputs = new Map<String, Object>{
            'accountId' => acc.Id,
            'status' => 'Closed',
            'assunto' => 'Credito Pessoal',
            'evento' => 'Reenvio dos dados bancários',
            'origem' => 'Pós Vendas',
            'contaFinanceiraId' => cf.Id,
            'unidadeNegocio' => '1 ',
            'tipo' => 'Execução',
            'canal' => 'Chat',
            'prioridade' => 'Medium'
        };

        Test.startTest();
        Case retorno = CreditoPessoalController.criarCaso(inputs);
        Test.stopTest();

        Assert.isNotNull(retorno, 'o caso deve ser retornado');
    }

    @isTest
    public static void obterChaveLigaDesligaTest(){
        Test.StartTest();
        List<ChaveLigaDesligaBO.ChaveTO> retorno = CreditoPessoalController.obterChaveLigaDesliga('btnCreditoPessoal_%');
        Test.StopTest();

        Assert.isNotNull(retorno, 'Deve ser retornado os valores');
        Assert.isFalse(retorno.isEmpty(), 'O retorno não deve estar vazio');
    }


    @isTest
    public static void cancelamentoTest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenCsfServicosV2');
        objMultiHttpCalloutMock.addResponse(200, 'MockCancelarCreditoPessoal');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
            CreditoPessoalTO.Cancelamento response = CreditoPessoalController.cancelamento('21343', '40020030015', '1', 'cockpit');
        Test.StopTest();

        System.AssertEquals(response.statusAPI, '200');
    }
}