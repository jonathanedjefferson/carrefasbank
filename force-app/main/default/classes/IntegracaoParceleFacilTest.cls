@isTest 
public class IntegracaoParceleFacilTest {

    @isTest
    public static void tokenServicesTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputTokenServico retorno = IntegracaoParceleFacil.tokenServices('40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Token Serviços Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno.access_token);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void modalidadeParceleTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseModalidades = new HttpResponse();
        responseModalidades.setStatusCode(200);
        responseModalidades.setBody('{"perfilOferta":2,"permissaoFaturaFechada":true,"permissaoSaldoParcial":false,"permissaoSaldoTotal":true,'
        +'"jurosEncargosHabilitado":false,"valorSaldoTotal":{"valor":-1617.07,"moeda":"R$"},"valorMinimoDivida":{"valor":50,"moeda":"R$"},'
        +'"faturaFechada":{"valorTotal":{"valor":-236.98,"moeda":"R$"},"dataVencimento":"2028-04-15","dataVencimentoReal":"2028-04-17",'
        +'"transacoes":[{"codigo":10,"chaveParticao":1,"nome":"ANUIDADE Diferenciada - 3/12","valorTotal":{"valor":-15,"moeda":"R$"},'
        +'"tipo":0,"descricaoAndamentoParcela":""}]},"faturaAberta":{"valorTotal":{"valor":-255.09,"moeda":"R$"},"dataVencimento":"2028-05-15T00:00:00"'
        +',"transacoes":[{"codigo":100017,"chaveParticao":1028121,"nome":"Multa sobre saldo rotativo em atraso","valorTotal":{"valor":-4.62,"moeda":"R$"},'
        +'"tipo":1,"descricaoAndamentoParcela":""}]},"transacoes":[{"codigo":279803,"chaveParticao":1028060,"nome":"Hipermercado","valorTotal":{"valor":-1125,'
        +'"moeda":"R$"},"quantidadeParcelas":12,"numeroParcelasRestantes":9,"tipo":2,"descricaoAndamentoParcela":"9 parcelas restantes"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/modalidades' => responseModalidades
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputModalidades retorno = BCSF_cmp_ParceleSimularController.modalidadeParcele('40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Modalidades Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('GET', log.Metodo__c);
    }

    @isTest
    public static void simularFaturaFechadaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseSimular = new HttpResponse();
        responseSimular.setStatusCode(200);
        responseSimular.setBody('{"simulacao":{"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorMinimoEntrada":{"valor":14.02,"moeda":"R$"},"valorMaximoEntrada":'
        +'{"valor":230.46,"moeda":"R$"},"dataPagamento":"2028-03-29T00:00:00","formasPagamento":[{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,'
        +'"alertaLimiteCartao":{"mensagem":"Esse parcelamento ","status":"warning","tipo":1},"codigo":"1224","valorDivida":{"valor":266.44,"moeda":"R$"},'
        +'"porcentagemDivida":58.24,"iof":{"valor":1.01,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":1.87,"moeda":"R$"},"iofDiarioPorcentagem":0.41,'
        +'"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,'
        +'"taxaJuros":4.9,"cet":81.34,"valorTotalParcelamento":{"valor":457.46,"moeda":"R$"},"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":188.14,"moeda":'
        +'"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":191.02,"moeda":"R$"},"porcentagemTotalDespesas":41.76,"valorParcela":{"valor":19.06,"moeda":'
        +'"R$"},"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorTotalJuros":{"valor":188.14,"moeda":"R$"},"porcentagemTotalJuros":98.49,"quantidadeParcelas":24,'
        +'"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":{"valor":457.44,"moeda":"R$"}'
        +'}],"possuiEntrada":true,"possuiPlanosComSeguro":false,"possuiPlanosPulaCiclo":false,"possuiSomentePlanosPulaCiclo":false}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/simular/faturafechada' => responseSimular
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputSimulacao retorno = BCSF_cmp_ParceleSimularController.simularFaturaFechada('2024-23-20' ,'95', '40040040040', '40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Simular parcelamento fatura fechada' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areNotEqual(null, retorno.simulacao.valorEntrada);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void simularSaldoTotalTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseSimular = new HttpResponse();
        responseSimular.setStatusCode(200);
        responseSimular.setBody('{"simulacao":{"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorMinimoEntrada":{"valor":14.02,"moeda":"R$"},"valorMaximoEntrada":'
        +'{"valor":230.46,"moeda":"R$"},"dataPagamento":"2028-03-29T00:00:00","formasPagamento":[{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,'
        +'"alertaLimiteCartao":{"mensagem":"Esse parcelamento ","status":"warning","tipo":1},"codigo":"1224","valorDivida":{"valor":266.44,"moeda":"R$"},'
        +'"porcentagemDivida":58.24,"iof":{"valor":1.01,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":1.87,"moeda":"R$"},"iofDiarioPorcentagem":0.41,'
        +'"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,'
        +'"taxaJuros":4.9,"cet":81.34,"valorTotalParcelamento":{"valor":457.46,"moeda":"R$"},"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":188.14,"moeda":'
        +'"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":191.02,"moeda":"R$"},"porcentagemTotalDespesas":41.76,"valorParcela":{"valor":19.06,"moeda":'
        +'"R$"},"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorTotalJuros":{"valor":188.14,"moeda":"R$"},"porcentagemTotalJuros":98.49,"quantidadeParcelas":24,'
        +'"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":{"valor":457.44,"moeda":"R$"}'
        +'}],"possuiEntrada":true,"possuiPlanosComSeguro":false,"possuiPlanosPulaCiclo":false,"possuiSomentePlanosPulaCiclo":false}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/simular/saldototal' => responseSimular
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputSimulacao retorno = BCSF_cmp_ParceleSimularController.simularSaldoTotal('2024-23-20' ,'95', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Simular parcelamento saldo total' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areNotEqual(null, retorno.simulacao.valorEntrada);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void simularSaldoParcialTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseSimular = new HttpResponse();
        responseSimular.setStatusCode(200);
        responseSimular.setBody('{"simulacao":{"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorMinimoEntrada":{"valor":14.02,"moeda":"R$"},"valorMaximoEntrada":'
        +'{"valor":230.46,"moeda":"R$"},"dataPagamento":"2028-03-29T00:00:00","formasPagamento":[{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,'
        +'"alertaLimiteCartao":{"mensagem":"Esse parcelamento ","status":"warning","tipo":1},"codigo":"1224","valorDivida":{"valor":266.44,"moeda":"R$"},'
        +'"porcentagemDivida":58.24,"iof":{"valor":1.01,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":1.87,"moeda":"R$"},"iofDiarioPorcentagem":0.41,'
        +'"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,'
        +'"taxaJuros":4.9,"cet":81.34,"valorTotalParcelamento":{"valor":457.46,"moeda":"R$"},"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":188.14,"moeda":'
        +'"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":191.02,"moeda":"R$"},"porcentagemTotalDespesas":41.76,"valorParcela":{"valor":19.06,"moeda":'
        +'"R$"},"valorEntrada":{"valor":14.02,"moeda":"R$"},"valorTotalJuros":{"valor":188.14,"moeda":"R$"},"porcentagemTotalJuros":98.49,"quantidadeParcelas":24,'
        +'"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":{"valor":457.44,"moeda":"R$"}'
        +'}],"possuiEntrada":true,"possuiPlanosComSeguro":false,"possuiPlanosPulaCiclo":false,"possuiSomentePlanosPulaCiclo":false}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/simular/saldoparcial' => responseSimular
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        integracaoParceleFacilTO.Valor valor = new integracaoParceleFacilTO.Valor();
        valor.valor = 0.0;
        valor.moeda = 'R$';

        integracaoParceleFacilTO.Transacao transacao = new integracaoParceleFacilTO.Transacao();
        transacao.codigo = '10001685159';
        transacao.chaveParticao =  1028091;
        transacao.nome = 'Isenção Parcela Anuidade – 100% - 1/12';
        transacao.valorTotal = valor;
        transacao.tipo = 1;
        transacao.descricaoAndamentoParcela = '';
        
        List<integracaoParceleFacilTO.Transacao> transacoes = new List<integracaoParceleFacilTO.Transacao>();
        transacoes.add(transacao);

        String jsonString = JSON.serialize(transacoes);

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputSimulacao retorno = BCSF_cmp_ParceleSimularController.simularSaldoParcial(jsonString, '2024-23-20' ,'95', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Simular parcelamento saldo parcial' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areNotEqual(null, retorno.simulacao.valorEntrada);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void contratarSaldoTotalTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseContratar = new HttpResponse();
        responseContratar.setStatusCode(200);
        responseContratar.setBody('{"dataPrimeiraParcela":"2028-05-08T00:00:00","valorPrimeiraParcela":{"valor":71.14,"moeda":"R$"},"formaPagamento":{"codigo":'
        +'"5960","valorDivida":{"valor":992.82,"moeda":"R$"},"porcentagemDivida":58.15,"iof":{"valor":3.77,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":'
        +'{"valor":6.98,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},'
        +'"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.99,"cet":81.55,"valorTotalParcelamento":{"valor":1707.44,"moeda":"R$"},'
        +'"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":703.87,"moeda":"R$"},"porcentagemEncargos":41.22,"valorTotalDespesas":{"valor":714.62,"moeda":"R$"}'
        +',"porcentagemTotalDespesas":41.85,"valorParcela":{"valor":71.14,"moeda":"R$"},"valorEntrada":{"valor":52.25,"moeda":"R$"},"valorTotalJuros":{"valor":703.87,'
        +'"moeda":"R$"},"porcentagemTotalJuros":98.5,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-05-08T00:00:00","dataVencimentoProxFatura":'
        +'"2028-05-08T00:00:00","valorTotalParcelamentoCalculado":{"valor":1707.36,"moeda":"R$"}},"dataPagamentoEntrada":"2028-04-21T00:00:00","parceleFacilId":'
        +'"TESTE","ehUltimoDiaPagamento":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/contratar/saldototal' => responseContratar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        String valor = '{ "valor": 3, "moeda": "R$"}';


        String formaPag = '{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,"alertaLimiteCartao":{"mensagem":"teste","status":"warning","tipo":1},"codigo":'
        +'"1224","valorDivida":{"valor":1459.49,"moeda":"R$"},"porcentagemDivida":58.24,"iof":{"valor":5.55,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":10.'
        +'28,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor"'
        +':0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.9,"cet":81.35,"valorTotalParcelamento":{"valor":2505.91,"moeda":"R$"},"porcentagemTotalParcelamento":100,'
        +'"valorEncargos":{"valor":1030.59,"moeda":"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":1046.42,"moeda":"R$"},"porcentagemTotalDespesas":41.76'
        +',"valorParcela":{"valor":104.41,"moeda":"R$"},"valorEntrada":{"valor":76.82,"moeda":"R$"},"valorTotalJuros":{"valor":1030.59,"moeda":"R$"},"porcentagemTotalJuros":'
        +'98.49,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":'
        +'{"valor":2505.84,"moeda":"R$"}}';

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputContratar retorno = BCSF_cmp_ParceleSimularController.contratarSaldoTotal(formaPag, valor, '2028-04-21', '1', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contratar parcelamento saldo total' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('TESTE', retorno.parceleFacilId);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void contratarFaturaFechadaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseContratar = new HttpResponse();
        responseContratar.setStatusCode(200);
        responseContratar.setBody('{"dataPrimeiraParcela":"2028-05-08T00:00:00","valorPrimeiraParcela":{"valor":71.14,"moeda":"R$"},"formaPagamento":{"codigo":'
        +'"5960","valorDivida":{"valor":992.82,"moeda":"R$"},"porcentagemDivida":58.15,"iof":{"valor":3.77,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":'
        +'{"valor":6.98,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},'
        +'"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.99,"cet":81.55,"valorTotalParcelamento":{"valor":1707.44,"moeda":"R$"},'
        +'"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":703.87,"moeda":"R$"},"porcentagemEncargos":41.22,"valorTotalDespesas":{"valor":714.62,"moeda":"R$"}'
        +',"porcentagemTotalDespesas":41.85,"valorParcela":{"valor":71.14,"moeda":"R$"},"valorEntrada":{"valor":52.25,"moeda":"R$"},"valorTotalJuros":{"valor":703.87,'
        +'"moeda":"R$"},"porcentagemTotalJuros":98.5,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-05-08T00:00:00","dataVencimentoProxFatura":'
        +'"2028-05-08T00:00:00","valorTotalParcelamentoCalculado":{"valor":1707.36,"moeda":"R$"}},"dataPagamentoEntrada":"2028-04-21T00:00:00","parceleFacilId":'
        +'"TESTE","ehUltimoDiaPagamento":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/contratar/faturafechada' => responseContratar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        String valor = '{ "valor": 3, "moeda": "R$"}';

        String formaPag = '{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,"alertaLimiteCartao":{"mensagem":"teste","status":"warning","tipo":1},"codigo":'
        +'"1224","valorDivida":{"valor":1459.49,"moeda":"R$"},"porcentagemDivida":58.24,"iof":{"valor":5.55,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":10.'
        +'28,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor"'
        +':0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.9,"cet":81.35,"valorTotalParcelamento":{"valor":2505.91,"moeda":"R$"},"porcentagemTotalParcelamento":100,'
        +'"valorEncargos":{"valor":1030.59,"moeda":"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":1046.42,"moeda":"R$"},"porcentagemTotalDespesas":41.76'
        +',"valorParcela":{"valor":104.41,"moeda":"R$"},"valorEntrada":{"valor":76.82,"moeda":"R$"},"valorTotalJuros":{"valor":1030.59,"moeda":"R$"},"porcentagemTotalJuros":'
        +'98.49,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":'
        +'{"valor":2505.84,"moeda":"R$"}}';

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputContratar retorno = BCSF_cmp_ParceleSimularController.contratarFaturaFechada(formaPag, valor, '2028-04-21', '1', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contratar parcelamento fatura fechada' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('TESTE', retorno.parceleFacilId);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void contratarSaldoParcialTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseContratar = new HttpResponse();
        responseContratar.setStatusCode(200);
        responseContratar.setBody('{"dataPrimeiraParcela":"2028-05-08T00:00:00","valorPrimeiraParcela":{"valor":71.14,"moeda":"R$"},"formaPagamento":{"codigo":'
        +'"5960","valorDivida":{"valor":992.82,"moeda":"R$"},"porcentagemDivida":58.15,"iof":{"valor":3.77,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":'
        +'{"valor":6.98,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},'
        +'"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.99,"cet":81.55,"valorTotalParcelamento":{"valor":1707.44,"moeda":"R$"},'
        +'"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":703.87,"moeda":"R$"},"porcentagemEncargos":41.22,"valorTotalDespesas":{"valor":714.62,"moeda":"R$"}'
        +',"porcentagemTotalDespesas":41.85,"valorParcela":{"valor":71.14,"moeda":"R$"},"valorEntrada":{"valor":52.25,"moeda":"R$"},"valorTotalJuros":{"valor":703.87,'
        +'"moeda":"R$"},"porcentagemTotalJuros":98.5,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-05-08T00:00:00","dataVencimentoProxFatura":'
        +'"2028-05-08T00:00:00","valorTotalParcelamentoCalculado":{"valor":1707.36,"moeda":"R$"}},"dataPagamentoEntrada":"2028-04-21T00:00:00","parceleFacilId":'
        +'"TESTE","ehUltimoDiaPagamento":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/contratar/saldoparcial' => responseContratar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        String valorString = '{ "valor": 3, "moeda": "R$"}';

        String formaPag = '{"limiteBloqueado":true,"numeroParcelasParaLiberacaoLimite":24,"alertaLimiteCartao":{"mensagem":"teste","status":"warning","tipo":1},"codigo":'
        +'"1224","valorDivida":{"valor":1459.49,"moeda":"R$"},"porcentagemDivida":58.24,"iof":{"valor":5.55,"moeda":"R$"},"iofPorcentagem":0.22,"iofDiario":{"valor":10.'
        +'28,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":{"valor":0,"moeda":"R$"},"valorSeguro":{"valor"'
        +':0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.9,"cet":81.35,"valorTotalParcelamento":{"valor":2505.91,"moeda":"R$"},"porcentagemTotalParcelamento":100,'
        +'"valorEncargos":{"valor":1030.59,"moeda":"R$"},"porcentagemEncargos":41.13,"valorTotalDespesas":{"valor":1046.42,"moeda":"R$"},"porcentagemTotalDespesas":41.76'
        +',"valorParcela":{"valor":104.41,"moeda":"R$"},"valorEntrada":{"valor":76.82,"moeda":"R$"},"valorTotalJuros":{"valor":1030.59,"moeda":"R$"},"porcentagemTotalJuros":'
        +'98.49,"quantidadeParcelas":24,"dataPrimeiroPagamento":"2028-04-15T00:00:00","dataVencimentoProxFatura":"2028-04-15T00:00:00","valorTotalParcelamentoCalculado":'
        +'{"valor":2505.84,"moeda":"R$"}}';

        integracaoParceleFacilTO.Valor valorObj = new integracaoParceleFacilTO.Valor();
        valorObj.valor = 0.0;
        valorObj.moeda = 'R$';

        integracaoParceleFacilTO.Transacao transacao = new integracaoParceleFacilTO.Transacao();
        transacao.codigo = '10001685159';
        transacao.chaveParticao =  1028091;
        transacao.nome = 'Isenção Parcela Anuidade – 100% - 1/12';
        transacao.valorTotal = valorObj;
        transacao.tipo = 1;
        transacao.descricaoAndamentoParcela = '';
        
        List<integracaoParceleFacilTO.Transacao> transacoes = new List<integracaoParceleFacilTO.Transacao>();
        transacoes.add(transacao);

        String jsonString = JSON.serialize(transacoes);


        Test.StartTest();
        IntegracaoParceleFacilTO.OutputContratar retorno = BCSF_cmp_ParceleSimularController.contratarSaldoParcial(formaPag , jsonString, valorString, '2028-04-21', '1', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Contratar parcelamento saldo parcial' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('TESTE', retorno.parceleFacilId);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void enviarEmailTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseEmail = new HttpResponse();
        responseEmail.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/enviar-email-segunda-via' => responseEmail
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputDefault retorno = BCSF_cmp_ParceleSimularController.enviarEmail('teste', 'TESTE@gmail.com', '1', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Enviar E-mail Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void listarPerfisTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responsePerfis = new HttpResponse();
        responsePerfis.setStatusCode(200);
        responsePerfis.setBody('{"perfisParcelamento":["teste"]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/perfil/4000/lista-perfil-parcelamento' => responsePerfis
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputListarPerfis retorno = BCSF_cmp_ParceleSimularController.getPerfis('4000' ,'40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Perfis Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('GET', log.Metodo__c);
    }

    @isTest
    public static void alterarPerfilTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responsePerfil = new HttpResponse();
        responsePerfil.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/perfil/40040040040/perfil-parcelamento' => responsePerfil
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputDefault retorno = BCSF_cmp_ParceleSimularController.alterarPerfil('perfil - Teste', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alterar perfil Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('PUT', log.Metodo__c);
    }

    @isTest
    public static void pagamentoEntradaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responsePagamento = new HttpResponse();
        responsePagamento.setStatusCode(200);
        responsePagamento.setBody('{"pix":{"qrCode":"teste","copiaCola":"teste"}}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/pagamento-entrada' => responsePagamento
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        IntegracaoParceleFacilTO.InputPagamentoEntrada pagamento = new IntegracaoParceleFacilTO.InputPagamentoEntrada();
        pagamento.valorEntrada = 11;
        pagamento.dataEntrada = '2028-04-21';
        pagamento.codigoPlanoPagamento = 'C7087';
        pagamento.valorParcela = 8.72;
        pagamento.quantidadeParcelas = 20;
        pagamento.taxaJuros = 9.05;
        pagamento.tipoPagamento = 1;


        Test.StartTest();
        IntegracaoParceleFacilTO.OutputPagamentoEntrada retorno = BCSF_cmp_ParceleSimularController.pagamentoEntrada(JSON.serialize(pagamento), '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Pagamento Entrada Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('OK', retorno.statusAPI);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
    }

    @isTest
    public static void downloadContratoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responsePagamento = new HttpResponse();
        responsePagamento.setStatusCode(200);
        responsePagamento.setBody('PDF boleto');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/contas/40040040040/download-contrato' => responsePagamento
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        Blob retorno = IntegracaoParceleFacil.downloadContrato('teste', '1', '40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Download Contrato Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('POST', log.Metodo__c);
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
            BCSF_cmp_ParceleSimularController.criarCaso('pendente', cf.Id, acc.Id, '1', 'Ouvidoria',  'Whatsapp');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cF.NumeroConta__c = '123333333';
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
            BCSF_cmp_ParceleSimularController.getContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM ContaFinanceira__c]);
    }

    @isTest
    public static void getPerfilTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseModalidades = new HttpResponse();
        responseModalidades.setStatusCode(200);
        responseModalidades.setBody('{"perfil":{"nome":"PSP800 Parcele Pula Ciclo Entrada 5% Taxa 4,99%","codigoPerfil":"PSP800",'
        +'"statusContaCliente":"NORM","listaDeStatusNegativo":["AFRD","DLNQ","FDAP","INAC","NURP","PWOF","XFRD"],'
        +'"numeroMaximoDeOfertas":8,"perfilOferta":2,"perfilOfertaAcesso":7,"parcelamentoPersonalizado":true,"opcaoPagamento":0,'
        +'"percentualMinimoPromessaPagamento":0.05,"percentualMaximoPromessaPagamento":1,"bloqueioLimite":false},"ehFuncionario":false}');
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/perfil/40040040040' => responseModalidades
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputGetPerfil retorno = BCSF_cmp_ParceleSimularController.getPerfil('40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Get perfil Parcele Fácil' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('GET', log.Metodo__c);
    }

    @isTest
    public static void listarParcelePendentesTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseModalidades = new HttpResponse();
        responseModalidades.setStatusCode(200);
        responseModalidades.setBody('{"formasPagamento":[{"dataPromessaPagamento":"2029-02-16T00:00:00","ehUltimoDiaPagamento":false,"parceleFacilId":"teste","codigo":'
                                    +'"5960","valorDivida":{"valor":425.46,"moeda":"R$"},"porcentagemDivida":57.86,"iof":{"valor":1.62,"moeda":"R$"},"iofPorcentagem":0.22,'
                                    +'"iofDiario":{"valor":3.04,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":'
                                    +'{"valor":0,"moeda":"R$"},"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.99,"cet":81.54,"valorTotalParcelamento"'
                                    +':{"valor":735.34,"moeda":"R$"},"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":305.22,"moeda":"R$"},"porcentagemEncargos":41.51,'
                                    +'"valorTotalDespesas":{"valor":309.88,"moeda":"R$"},"porcentagemTotalDespesas":42.14,"valorParcela":{"valor":30.64,"moeda":"R$"},"valorEntrada"'
                                    +':{"valor":22.39,"moeda":"R$"},"valorTotalJuros":{"valor":305.22,"moeda":"R$"},"porcentagemTotalJuros":98.5,"quantidadeParcelas":24,"dataPrimeiroPagamento"'
                                    +':"2029-03-08T00:00:00","dataVencimentoProxFatura":"2029-03-08T00:00:00","valorTotalParcelamentoCalculado":{"valor":735.36,"moeda":"R$"},'
                                    +'"descricaoPlanoParcelamento":"teste","status":"PEND","jurosEncargos":{"valor":5.02,"moeda":"R$"},"dataCriacao":"2024-08-23T12:17:03.017927",'
                                    +'"textoLimiteCartao":"teste"}]}');
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/perfil/40040040040' => responseModalidades
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputListarParcelePendente retorno = BCSF_cmp_ParceleSimularController.listarParcelePendente('40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Parcele Pendentes' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('GET', log.Metodo__c);
    }

    @isTest
    public static void listarParceleContratadosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseModalidades = new HttpResponse();
        responseModalidades.setStatusCode(200);
        responseModalidades.setBody('{"formasPagamento":[{"dataPromessaPagamento":"2029-02-16T00:00:00","ehUltimoDiaPagamento":false,"parceleFacilId":"teste","codigo":'
                                    +'"5960","valorDivida":{"valor":425.46,"moeda":"R$"},"porcentagemDivida":57.86,"iof":{"valor":1.62,"moeda":"R$"},"iofPorcentagem":0.22,'
                                    +'"iofDiario":{"valor":3.04,"moeda":"R$"},"iofDiarioPorcentagem":0.41,"seguroAtivo":false,"pulaCicloAtivo":false,"valorSeguroPorParcela":'
                                    +'{"valor":0,"moeda":"R$"},"valorSeguro":{"valor":0,"moeda":"R$"},"porcentagemSeguro":0,"taxaJuros":4.99,"cet":81.54,"valorTotalParcelamento"'
                                    +':{"valor":735.34,"moeda":"R$"},"porcentagemTotalParcelamento":100,"valorEncargos":{"valor":305.22,"moeda":"R$"},"porcentagemEncargos":41.51,'
                                    +'"valorTotalDespesas":{"valor":309.88,"moeda":"R$"},"porcentagemTotalDespesas":42.14,"valorParcela":{"valor":30.64,"moeda":"R$"},"valorEntrada"'
                                    +':{"valor":22.39,"moeda":"R$"},"valorTotalJuros":{"valor":305.22,"moeda":"R$"},"porcentagemTotalJuros":98.5,"quantidadeParcelas":24,"dataPrimeiroPagamento"'
                                    +':"2029-03-08T00:00:00","dataVencimentoProxFatura":"2029-03-08T00:00:00","valorTotalParcelamentoCalculado":{"valor":735.36,"moeda":"R$"},'
                                    +'"descricaoPlanoParcelamento":"teste","status":"PEND","jurosEncargos":{"valor":5.02,"moeda":"R$"},"dataCriacao":"2024-08-23T12:17:03.017927",'
                                    +'"textoLimiteCartao":"teste"}]}');
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                '/servicecloud-parcele-facil/api/parcelefacil/perfil/40040040040' => responseModalidades
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        IntegracaoParceleFacilTO.OutputListarContratados retorno = BCSF_cmp_ParceleSimularController.listarParceleContratados('40040040040','40040040040', 'cockpit', '1');
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Listar Parcele Contratados' LIMIT 1];
        
        Assert.areNotEqual(null, retorno);
        Assert.areEqual('40040040040', log.CPF__c);
        Assert.areEqual('GET', log.Metodo__c);
    }

}