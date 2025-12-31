/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - BCSF_TransacoesOnUsOffUsController           98%                  *
*                                                                        *
**************************************************************************/
@isTest
public with sharing class BCSF_TransacoesOnUsOffUsTest {
    @isTest
    public static void GetAutorizacoesOnUsOffUs() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setBody('{"tamanhoPagina":1,"pagina":1,"totalItens":1,"data":[{"data":"2024-09-09T17:19:46-03:00","codigo":"055630","valor":350,"quantidadeParcelas":4,"valorParcelado":350,"codigoResposta":"00","detalheResposta":"Aprovado","estabelecimento":"Retail Seller LTD","codigoRamoAtividade":"5411","ramoAtividade":"Supermercados e Mercearias","cidade":"Sao Paolo","codigoPais":"076","pais":"BRAZIL","tipoTransacao":"OFF-US","codigoRecusa":0,"traducaoRecusa":null,"codigoEntrada":"010","meioPagamento":"Virtual","detalheEntrada":null,"statusAutorizacao":"Outstanding","traducaoStatusAutorizacao":"Pendente"}]}');
        responseAPI.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000081481/cartoes/0258/autorizacoes' => responseAPI
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        String cpf = '04544371457';
        String numeroConta = '37000081481';
        String Token = '1';
        String unidadeNegocio = '1';
        String canal = 'cockpit';
        String numeroCartaoSerno = '0258';
        String dataInicial = '01-01-2024';
        String dataFinal = '01-01-2024';
        String tamanhoPagina = '1';
        String pagina = '1';


        AutorizacoesOnUsOffUs.OutputAutorizacoes retorno = BCSF_TransacoesOnUsOffUsController.GetAutorizacoesOnUsOffUs(CPF, NumeroConta, Token, unidadeNegocio, canal, numeroCartaoSerno, dataInicial, dataFinal, tamanhoPagina, pagina);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Autorizações On-Us e Off-Us' LIMIT 1];

        System.AssertEquals(retorno.pagina, 1);
        System.AssertEquals('04544371457'   , log.CPF__c);
        System.AssertEquals('GET'          , log.Metodo__c);
    }

    @isTest
    public static void CreateCaseTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        BCSF_TransacoesOnUsOffUsController.createCase('APP', String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 'Chat', 'Execução', 'Compra', 'Duplicidade de compra');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void identificaNumeroContaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseCancelar = new HttpResponse();
        responseCancelar.setStatusCode(200);
        responseCancelar.setBody('{"data":{"clientePorConta":{"cpf":"98390073277","dadosSociais":[{"estadoCivil":1,"genero":"M","numeroConta":"10000078864","statusConta":"NORM","unidadeNegocio":"ATC"}],"contaCartao":{"contratos":[{"numeroConta":"10000078864","unidadeNegocio":"ATC","tipoEnvioFatura":"1","statusConta":"NORM","valorLimiteDisponivel":45913.83,"valorLimiteTotal":50000,"cartoes":[{"id":"1063227","numeroCartao":"5438.XXXX.XXXX.8418","ehAtivo":true,"ehPrimario":false,"ehVirtual":true,"cpfPortador":"98390073277","nomePortador":"MARCIA GOMES DANTAS","tipoTitularidade":"TITULAR","dataAtivacao":"2029-04-26T03:00:00+00:00","vencimentoCartao":"2032-02-29T00:00:00-03:00","nomeCartao":"CARTAO VIRTUAL","nomeProduto":"MC ATACADAO Gold","idProduto":"12568","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":false,"statusCartao":"NORM"},{"id":"1060173","numeroCartao":"5438.XXXX.XXXX.2050","ehAtivo":true,"ehPrimario":true,"ehVirtual":false,"cpfPortador":"98390073277","nomePortador":"MARCIA GOMES DANTAS","tipoTitularidade":"TITULAR","dataAtivacao":"2029-02-20T03:00:00+00:00","vencimentoCartao":"2032-02-29T00:00:00-03:00","nomeCartao":"GUSTAVO N NUNES","nomeProduto":"MC ATACADAO Gold","idProduto":"12568","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"NORM"}],"aceiteRecebimentoDeEmail":true,"aumentoAutomaticoDeLimite":true,"statusGeralCartaoPrimario":"NORM","classificacaoStatusConta":0}]},"identidades":[{"tipo":"CPF","valor":"98390073277"},{"tipo":"RG","valor":"178478726"}],"contato":{"dadosContato":[{"numeroConta":"10000078864","unidadeNegocio":"ATC","enderecos":[{"numeroSerie":1287257,"cep":"04006040","tipoEndereco":["RESIDENCIAL"],"logradouro":"RUA CORONEL PAULINO CARLOS","numero":"213","complemento":"","bairro":"PARAISO","uf":"SP","cidade":"SAO PAULO","pais":"076","finalidadeEndereco":["OUTROS"]},{"numeroSerie":1287258,"cep":"06460000","tipoEndereco":["COMERCIAL"],"logradouro":"Av. Tambore","numero":"267","complemento":"21 andar","bairro":"Tambore","uf":"SP","cidade":"Barueri","pais":"076","finalidadeEndereco":["OUTROS"]}],"emails":[{"endereco":"teste@gmail.com","tipoEmail":["OUTROS"]}],"telefones":[{"celularSeguro":true,"ddd":"11","tipo":"CELULAR","tipoContato":["RESIDENCIAL"],"numero":"941212985"},{"celularSeguro":false,"ddd":"11","tipo":"PRINCIPAL","tipoContato":["RESIDENCIAL"],"numero":"33334444"},{"celularSeguro":false,"ddd":"11","tipo":"PRINCIPAL","tipoContato":["COMERCIAL"],"numero":"44443333"}]}]}}},"ehBlindado":false,"ehBlindadoFull":false}');
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/numeroconta' => responseCancelar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IdentificaCockpit.ResponseAPIContaFinanceira output = BCSF_TransacoesOnUsOffUsController.getListCartoes ('37000000036','1','55765609309','cockpit');
        Test.StopTest();

        System.AssertEquals('98390073277', output.data.clientePorConta.cpf);
    }

    @isTest
    public static void intefaceObterAutorizacoesOnUsOffUsTestSucess(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPICartaoFisico = new HttpResponse();
        responseAPICartaoFisico.setBody('{ "tamanhoPagina":30, "pagina":1, "totalItens":23, "data":[ { "data":"2025-01-14T15:29:40-03:00", "codigo":null, "valor":0, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"55", "detalheResposta":"Senha inválida", "estabelecimento":null, "codigoRamoAtividade":null, "ramoAtividade":null, "cidade":null, "codigoPais":"076", "pais":"BRAZIL", "tipoTransacao":"ON-US", "codigoRecusa":8, "traducaoRecusa":"Senha inválida", "codigoEntrada":"000", "meioPagamento":"Virtual", "detalheEntrada":null, "statusAutorizacao":null, "traducaoStatusAutorizacao":null }, { "data":"2025-01-14T14:28:18-03:00", "codigo":"063028", "valor":108, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"00", "detalheResposta":"Aprovado", "estabelecimento":"Hipermercado", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paul", "codigoPais":"076", "pais":"BRAZIL", "tipoTransacao":"ON-US", "codigoRecusa":5100, "traducaoRecusa":null, "codigoEntrada":"0710", "meioPagamento":"Contactless", "detalheEntrada":null, "statusAutorizacao":"Non Financial Approval", "traducaoStatusAutorizacao":null }, { "data":"2025-01-14T11:35:13-03:00", "codigo":null, "valor":108, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"14", "detalheResposta":"Cartão inválido", "estabelecimento":"Hipermercado", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paul", "codigoPais":"076", "pais":"BRAZIL", "tipoTransacao":"ON-US", "codigoRecusa":912, "traducaoRecusa":null, "codigoEntrada":"0100", "meioPagamento":"Virtual", "detalheEntrada":null, "statusAutorizacao":null, "traducaoStatusAutorizacao":null }, { "data":"2025-01-14T11:34:42-03:00", "codigo":null, "valor":108, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"14", "detalheResposta":"Cartão inválido", "estabelecimento":"Hipermercado", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paul", "codigoPais":"076", "pais":"BRAZIL", "tipoTransacao":"ON-US", "codigoRecusa":912, "traducaoRecusa":null, "codigoEntrada":"0000", "meioPagamento":"Virtual", "detalheEntrada":null, "statusAutorizacao":null, "traducaoStatusAutorizacao":null } ] }');
        responseAPICartaoFisico.setStatusCode(200);

         HttpResponse responseAPICartaoVirtual = new HttpResponse();
        responseAPICartaoVirtual.setBody('{ "tamanhoPagina":30, "pagina":1, "totalItens":5, "data":[ { "data":"2025-01-15T12:24:58-03:00", "codigo":"048754", "valor":50, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"00", "detalheResposta":"Aprovado", "estabelecimento":"Retail Seller LTD", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paolo", "codigoPais":null, "pais":null, "tipoTransacao":"OFF-US", "codigoRecusa":0, "traducaoRecusa":null, "codigoEntrada":"810", "meioPagamento":"Virtual", "detalheEntrada":"Digitado cartão chipado com senha", "statusAutorizacao":"Matched", "traducaoStatusAutorizacao":"Equalizado" }, { "data":"2025-01-16T12:24:57-03:00", "codigo":"039994", "valor":40, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"00", "detalheResposta":"Aprovado", "estabelecimento":"Retail Seller LTD", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paolo", "codigoPais":null, "pais":null, "tipoTransacao":"OFF-US", "codigoRecusa":0, "traducaoRecusa":null, "codigoEntrada":"810", "meioPagamento":"Virtual", "detalheEntrada":"Digitado cartão chipado com senha", "statusAutorizacao":"Matched", "traducaoStatusAutorizacao":"Equalizado" } ] }');
        responseAPICartaoVirtual.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000132896/cartoes/1070794/autorizacoes' => responseAPICartaoFisico,
                '/api/v1.0/contas/37000132896/cartoes/1089035/autorizacoes' => responseAPICartaoVirtual
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<InterfaceAutorizacoesOnUsOffUs.Input> inputLst = new List<InterfaceAutorizacoesOnUsOffUs.Input>();
        InterfaceAutorizacoesOnUsOffUs.Input input = new InterfaceAutorizacoesOnUsOffUs.Input();
        input.cpf = '61632034450';
        input.numeroConta = '37000132896';
        input.unidadeNegocio = '1';
        input.canal = 'Cockpit';
        input.numeroCartaoSerno = '1070794';
        input.periodoTransacoesEmDias = 30;
        input.idCartoesBloqueadosLst = '1070794,1089035';
        inputLst.add(input);

        Test.StartTest();
        List<InterfaceAutorizacoesOnUsOffUs.Output> retorno = InterfaceAutorizacoesOnUsOffUs.obterAutorizacoesOnUsOffUs(inputLst);
        Test.StopTest();

        Assert.areEqual('Retail Seller LTD no valor de: R$ 40.00 no dia 16/01/2025 às 12:24', retorno[0].transacao1, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.areEqual('Retail Seller LTD no valor de: R$ 50.00 no dia 15/01/2025 às 12:24', retorno[0].transacao2, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.areEqual('Hipermercado no valor de: R$ 108.00 no dia 14/01/2025 às 11:35', retorno[0].transacao3, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.areEqual('Hipermercado no valor de: R$ 108.00 no dia 14/01/2025 às 11:34', retorno[0].transacao4, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.isNull(retorno[0].transacao5, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.isNull(retorno[0].transacao6, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.isNull(retorno[0].transacao7, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.isNull(retorno[0].transacao8, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.isNull(retorno[0].transacao9, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.isNull(retorno[0].transacao10, 'O valor deve ser nulo pois não existem registros o suficiente no json mock para preencher');
        Assert.areEqual('OK', retorno[0].statusAPI, 'A api deve retornar ok');
    }

    @isTest
    public static void intefaceObterAutorizacoesOnUsOffUsTestErroUmaChamada(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPICartaoFisico = new HttpResponse();
        responseAPICartaoFisico.setStatusCode(400);

        HttpResponse responseAPICartaoVirtual = new HttpResponse();
        responseAPICartaoVirtual.setBody('{ "tamanhoPagina":30, "pagina":1, "totalItens":5, "data":[ { "data":"2025-01-15T12:24:58-03:00", "codigo":"048754", "valor":50, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"00", "detalheResposta":"Aprovado", "estabelecimento":"Retail Seller LTD", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paolo", "codigoPais":null, "pais":null, "tipoTransacao":"OFF-US", "codigoRecusa":0, "traducaoRecusa":null, "codigoEntrada":"810", "meioPagamento":"Virtual", "detalheEntrada":"Digitado cartão chipado com senha", "statusAutorizacao":"Matched", "traducaoStatusAutorizacao":"Equalizado" }, { "data":"2025-01-16T12:24:57-03:00", "codigo":"039994", "valor":40, "quantidadeParcelas":null, "valorParcelado":null, "codigoResposta":"00", "detalheResposta":"Aprovado", "estabelecimento":"Retail Seller LTD", "codigoRamoAtividade":"5411", "ramoAtividade":"Supermercados e Mercearias", "cidade":"Sao Paolo", "codigoPais":null, "pais":null, "tipoTransacao":"OFF-US", "codigoRecusa":0, "traducaoRecusa":null, "codigoEntrada":"810", "meioPagamento":"Virtual", "detalheEntrada":"Digitado cartão chipado com senha", "statusAutorizacao":"Matched", "traducaoStatusAutorizacao":"Equalizado" } ] }');
        responseAPICartaoVirtual.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000132896/cartoes/1070794/autorizacoes' => responseAPICartaoFisico,
                '/api/v1.0/contas/37000132896/cartoes/1089035/autorizacoes' => responseAPICartaoVirtual
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<InterfaceAutorizacoesOnUsOffUs.Input> inputLst = new List<InterfaceAutorizacoesOnUsOffUs.Input>();
        InterfaceAutorizacoesOnUsOffUs.Input input = new InterfaceAutorizacoesOnUsOffUs.Input();
        input.cpf = '61632034450';
        input.numeroConta = '37000132896';
        input.unidadeNegocio = '1';
        input.canal = 'Cockpit';
        input.numeroCartaoSerno = '1070794';
        input.periodoTransacoesEmDias = 30;
        input.idCartoesBloqueadosLst = '1070794,1089035';
        inputLst.add(input);

        Test.StartTest();
        List<InterfaceAutorizacoesOnUsOffUs.Output> retorno = InterfaceAutorizacoesOnUsOffUs.obterAutorizacoesOnUsOffUs(inputLst);
        Test.StopTest();

        Assert.areEqual('Retail Seller LTD no valor de: R$ 40.00 no dia 16/01/2025 às 12:24', retorno[0].transacao1, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.areEqual('Retail Seller LTD no valor de: R$ 50.00 no dia 15/01/2025 às 12:24', retorno[0].transacao2, 'A transação retornada deve estar de acordo com a regra de negócio');
        Assert.areEqual('OK', retorno[0].statusAPI, 'A api deve retornar ok');
    }

    @isTest
    public static void intefaceObterAutorizacoesOnUsOffUsTestErroTotal(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(400);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1.0/contas/37000132896/cartoes/1070794/autorizacoes' => responseAPI,
                '/api/v1.0/contas/37000132896/cartoes/1089035/autorizacoes' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        List<InterfaceAutorizacoesOnUsOffUs.Input> inputLst = new List<InterfaceAutorizacoesOnUsOffUs.Input>();
        InterfaceAutorizacoesOnUsOffUs.Input input = new InterfaceAutorizacoesOnUsOffUs.Input();
        input.cpf = '61632034450';
        input.numeroConta = '37000132896';
        input.unidadeNegocio = '1';
        input.canal = 'Cockpit';
        input.numeroCartaoSerno = '1070794';
        input.periodoTransacoesEmDias = 30;
        input.idCartoesBloqueadosLst = '1070794,1089035';
        inputLst.add(input);

        Test.StartTest();
        List<InterfaceAutorizacoesOnUsOffUs.Output> retorno = InterfaceAutorizacoesOnUsOffUs.obterAutorizacoesOnUsOffUs(inputLst);
        Test.StopTest();

        Assert.areEqual('ERROR', retorno[0].statusAPI, 'A api deve retornar erro');
    }

    @isTest
    public static void intefaceChatTesteDuplicados(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockOnUsOffUsMesmaTransacaoComStatusDiferente');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        List<InterfaceAutorizacoesOnUsOffUs.Input> inputLst = new List<InterfaceAutorizacoesOnUsOffUs.Input>();
        InterfaceAutorizacoesOnUsOffUs.Input input = new InterfaceAutorizacoesOnUsOffUs.Input();
        input.cpf = '61632034450';
        input.numeroConta = '37000132896';
        input.unidadeNegocio = '1';
        input.canal = 'Cockpit';
        input.numeroCartaoSerno = '1070794';
        input.periodoTransacoesEmDias = 30;
        input.idCartoesBloqueadosLst = '1070794';
        inputLst.add(input);

        Test.StartTest();
        List<InterfaceAutorizacoesOnUsOffUs.Output> retorno = InterfaceAutorizacoesOnUsOffUs.obterAutorizacoesOnUsOffUs(inputLst);
        Test.StopTest();
        
        System.debug(retorno);

        Assert.areEqual('EC *BARATOALPHA no valor de: R$ 52.42 no dia 18/02/2025 às 22:10', retorno[0].transacao1);
        Assert.areEqual('MERCADOLIVRE*BARATOAL no valor de: R$ 52.42 no dia 18/02/2025 às 22:09', retorno[0].transacao2);
        Assert.areEqual('ECOM STN STONE CARREFOURC no valor de: R$ 2098.94 no dia 15/02/2025 às 21:57', retorno[0].transacao3);
        Assert.areEqual('PAGAMENTO PIX no valor de: R$ 1192.57 no dia 04/02/2025 às 09:46', retorno[0].transacao4);
        Assert.isNull(retorno[0].transacao5);
        Assert.isNull(retorno[0].transacao6);
        Assert.isNull(retorno[0].transacao7);
        Assert.isNull(retorno[0].transacao8);
        Assert.isNull(retorno[0].transacao9);
        Assert.isNull(retorno[0].transacao10);
    }

    @isTest
    public static void CreateCaseOffUsTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        BCSF_TransacoesOnUsOffUsController.createCaseCancelamentoOffUs('APP', String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 
        'Chat', 'Compra', 'Cancelamento De Compra Off-Us', 'Arrependimento', '-', '10/03/2025 09:45:57', 6894.24, 
        'Produto', 'Sim', 'Rua da Bahia', Date.today(), 'Sim', Date.today(), 
        'Sim', 'Sim', 'Não', 'Sim', 'E-mail', Date.today(), '14596871123 - Márcia', 'Proiduto entregue duas vezes.');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void CreateCaseOnUsTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
        BCSF_TransacoesOnUsOffUsController.createCaseCancelamentoOnUs(
        'APP', String.valueOf(cf.Id), String.valueOf(acc.Id), '1', 'Chat', 'Desacordo Comercial', 'Cancelamento de compras On-us',
        'Desistência Total', '069485', '10/03/2025 09:45:57', 250.0, 250.0, '5', Date.today(), 'Carrefour Express', '5', '5438.XXXX.XXXX.4601', 'Cliente não gostou do produto.', 'Carrefour');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }
}