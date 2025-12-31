/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BCSF_CLS_CalloutFaturasV1                 100%                    *
*    - BCSF_CLS_CalloutFaturasController         100%                    *
*    - BCSF_CLS_CalloutFaturasBO                 100%                    *
**************************************************************************/
@isTest
public class BCSF_CLS_CalloutFaturasV1Test {

    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'Teste Account';
        acc.CPF__c = '98390073277';
        insert acc;

        ContaFinanceira__c contaFinanceira = new ContaFinanceira__c();
        contaFinanceira.NumeroConta__c = '70000050032';
        contaFinanceira.NomeCliente__c = acc.Id;
        insert contaFinanceira;

        Case caso = new Case();
        caso.CampoControle__c = true;
        caso.Description = 'Teste';
        caso.NomeContato__c = 'Teste';
        caso.CPFContato__c = '98390073277';
        insert caso;
    }
    
    @isTest 
    public static void buscarFaturaAbertaTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseFaturaAberta = new HttpResponse();
        responseFaturaAberta.setStatusCode(200);
        responseFaturaAberta.setBody('{ "dataVencimento": "2030-03-08T00:00:00", "valorParcial": { "valor": -1132.58, "moeda": "R$" }, "limiteTotal": { "valor": 50000, "moeda": "R$" }, "limiteDisponivel": { "valor": 42552.69, "moeda": "R$" } }');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/faturas/aberta/resumo' => responseFaturaAberta
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        String retorno = BCSF_CLS_CalloutFaturasController.buscarFaturaAberta('70000050032', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isNotNull(retorno, 'O retorno não deve ser nulo');
    }

    @isTest 
    public static void buscarFaturaFechadaTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseFaturasFechadas = new HttpResponse();
        responseFaturasFechadas.setStatusCode(200);
        responseFaturasFechadas.setBody('[ { "serno": 8513415, "dataVencimento": null, "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 0, "moeda": "R$" }, "creditos": { "valor": 2147.62, "moeda": "R$" }, "pagamentoMinimo": { "valor": 0, "moeda": "R$" } }, { "serno": 8510535, "dataVencimento": "2030-02-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 2147.62, "moeda": "R$" }, "creditos": { "valor": 964.54, "moeda": "R$" }, "pagamentoMinimo": { "valor": 107.39, "moeda": "R$" } }, { "serno": 8508154, "dataVencimento": "2030-01-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 964.54, "moeda": "R$" }, "creditos": { "valor": 2016.97, "moeda": "R$" }, "pagamentoMinimo": { "valor": 48.23, "moeda": "R$" } }, { "serno": 8497237, "dataVencimento": "2029-12-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 2016.97, "moeda": "R$" }, "creditos": { "valor": 917.94, "moeda": "R$" }, "pagamentoMinimo": { "valor": 707.88, "moeda": "R$" } }, { "serno": 8455616, "dataVencimento": "2029-11-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 917.94, "moeda": "R$" }, "creditos": { "valor": 2251.65, "moeda": "R$" }, "pagamentoMinimo": { "valor": 889.44, "moeda": "R$" } }, { "serno": 8453187, "dataVencimento": "2029-10-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 2251.65, "moeda": "R$" }, "creditos": { "valor": 1065.02, "moeda": "R$" }, "pagamentoMinimo": { "valor": 597.21, "moeda": "R$" } }, { "serno": 8449405, "dataVencimento": "2029-09-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 1065.02, "moeda": "R$" }, "creditos": { "valor": 1486.19, "moeda": "R$" }, "pagamentoMinimo": { "valor": 537.88, "moeda": "R$" } }, { "serno": 8443298, "dataVencimento": "2029-08-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 1486.19, "moeda": "R$" }, "creditos": { "valor": 606.17, "moeda": "R$" }, "pagamentoMinimo": { "valor": 310.83, "moeda": "R$" } }, { "serno": 8436932, "dataVencimento": "2029-07-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 606.17, "moeda": "R$" }, "creditos": { "valor": 512.47, "moeda": "R$" }, "pagamentoMinimo": { "valor": 266.82, "moeda": "R$" } }, { "serno": 8433068, "dataVencimento": "2029-06-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 512.47, "moeda": "R$" }, "creditos": { "valor": 395.88, "moeda": "R$" }, "pagamentoMinimo": { "valor": 262.14, "moeda": "R$" } }, { "serno": 8429277, "dataVencimento": "2029-05-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 395.88, "moeda": "R$" }, "creditos": { "valor": 1226.58, "moeda": "R$" }, "pagamentoMinimo": { "valor": 256.31, "moeda": "R$" } }, { "serno": 8424472, "dataVencimento": "2029-04-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 1226.58, "moeda": "R$" }, "creditos": { "valor": 1000, "moeda": "R$" }, "pagamentoMinimo": { "valor": 61.33, "moeda": "R$" } }, { "serno": 8423513, "dataVencimento": "2029-03-08T00:00:00", "valorAberturaFatura": { "valor": 0, "moeda": "R$" }, "valorFatura": { "valor": 1000, "moeda": "R$" }, "creditos": { "valor": 0, "moeda": "R$" }, "pagamentoMinimo": { "valor": 50, "moeda": "R$" } } ]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/faturas/ultimos-resumos' => responseFaturasFechadas
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        String retorno = BCSF_CLS_CalloutFaturasController.buscarFaturaFechada('70000050032', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isNotNull(retorno, 'O retorno não deve ser nulo');
    }

    @isTest 
    public static void buscarDetalhesFaturaTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseDetalhesFaturaFechada = new HttpResponse();
        responseDetalhesFaturaFechada.setStatusCode(200);
        responseDetalhesFaturaFechada.setBody('[ { "data": "2029-05-26T00:00:00", "valor": { "valor": -1.5, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499045", "origMsgType": "SFEE", "reasonCode": "aior", "msgType": "0220", "procCode": "193000", "valor": { "valor": -1.5, "moeda": "R$" }, "descricao": "IOF adicional saldo financiad ref Mai/29", "glTrxnTypeSerno": 1027, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "IOF adicional saldo financiad ref Mai/29", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -0.03, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499042", "origMsgType": "SFEE", "reasonCode": "aior", "msgType": "0220", "procCode": "193000", "valor": { "valor": -0.03, "moeda": "R$" }, "descricao": "IOF adicional saldo financiad ref Mai/29", "glTrxnTypeSerno": 1027, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "IOF adicional saldo financiad ref Mai/29", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -1.75, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499031", "origMsgType": "DBINT", "reasonCode": "pint", "msgType": "0220", "procCode": "193000", "valor": { "valor": -1.75, "moeda": "R$" }, "descricao": "Encargos sobre Rotativo em Atraso", "glTrxnTypeSerno": 1034, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "Juros Remuneratórios", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -2.49, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499028", "origMsgType": "DBINT", "reasonCode": "pa12", "msgType": "0220", "procCode": "193000", "valor": { "valor": -2.49, "moeda": "R$" }, "descricao": "Juros Remuneratórios de Parc Automatico", "glTrxnTypeSerno": 125865, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "Juros Remuneratórios de Parc Automatico", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/lancamentos' => responseDetalhesFaturaFechada
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = BCSF_CLS_CalloutFaturasController.buscarDetalhesFatura('70000050032','06-2029', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isNotNull(retorno, 'O retorno não deve ser nulo');
    }

    @isTest 
    public static void buscarDetalhesFaturaIndisponivelTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(404);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseDetalhesFaturaFechada = new HttpResponse();
        responseDetalhesFaturaFechada.setStatusCode(404);
 
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/lancamentos' => responseDetalhesFaturaFechada
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = BCSF_CLS_CalloutFaturasController.buscarDetalhesFatura('70000050032','06-2029', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isTrue(retorno[0].faturaIndisponivel, 'Os lançamentos para a fatura estão indisponíveis');
    }

    @isTest 
    public static void buscarDetalhesFaturaAbertaTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseDetalhesFaturaAberta = new HttpResponse();
        responseDetalhesFaturaAberta.setStatusCode(200);
        responseDetalhesFaturaAberta.setBody('[ { "data": "2029-05-26T00:00:00", "valor": { "valor": -1.5, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499045", "origMsgType": "SFEE", "reasonCode": "aior", "msgType": "0220", "procCode": "193000", "valor": { "valor": -1.5, "moeda": "R$" }, "descricao": "IOF adicional saldo financiad ref Mai/29", "glTrxnTypeSerno": 1027, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "IOF adicional saldo financiad ref Mai/29", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -0.03, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499042", "origMsgType": "SFEE", "reasonCode": "aior", "msgType": "0220", "procCode": "193000", "valor": { "valor": -0.03, "moeda": "R$" }, "descricao": "IOF adicional saldo financiad ref Mai/29", "glTrxnTypeSerno": 1027, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "IOF adicional saldo financiad ref Mai/29", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -1.75, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499031", "origMsgType": "DBINT", "reasonCode": "pint", "msgType": "0220", "procCode": "193000", "valor": { "valor": -1.75, "moeda": "R$" }, "descricao": "Encargos sobre Rotativo em Atraso", "glTrxnTypeSerno": 1034, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "Juros Remuneratórios", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }, { "data": "2029-05-26T00:00:00", "valor": { "valor": -2.49, "moeda": "R$" }, "numeroCartao": "70000050032", "descricaoLancamento": { "parcelamentoSerno": 0, "idLancamento": "10002499028", "origMsgType": "DBINT", "reasonCode": "pa12", "msgType": "0220", "procCode": "193000", "valor": { "valor": -2.49, "moeda": "R$" }, "descricao": "Juros Remuneratórios de Parc Automatico", "glTrxnTypeSerno": 125865, "postingDate": "2029-05-26", "tipoPagamento": "Compra" }, "agrupamentoLancamentos": [], "descricao": "Juros Remuneratórios de Parc Automatico", "descricaoGrupo": null, "chaveParticaoTransacao": "1029151", "detalheLancamentoParcela": { "quantidadeParcelas": null, "numeroParcelaTransacao": null, "parcelamentoSerno": 0, "parcelaIndice": 0, "parcelamentoPartitionKey": 0 } }]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/faturas/aberta/lancamentos' => responseDetalhesFaturaAberta
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = BCSF_CLS_CalloutFaturasController.buscarDetalhesFaturaAberta('70000050032', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isNotNull(retorno, 'O retorno não deve ser nulo');
    }

    @isTest 
    public static void buscarDetalhesFaturaAbertaIndisponivelTest(){
    HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(404);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseDetalhesFaturaFechada = new HttpResponse();
        responseDetalhesFaturaFechada.setStatusCode(404);
 
        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/lancamentos' => responseDetalhesFaturaFechada
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = BCSF_CLS_CalloutFaturasController.buscarDetalhesFaturaAberta('70000050032', '98390073277', '2', 'cockpit');
        Test.StopTest();

        Assert.isTrue(retorno[0].faturaIndisponivel, 'Os lançamentos para a fatura estão indisponíveis');
    }

    @isTest
    public static void criarCasoTest(){
        Account  conta = [SELECT Id FROM Account WHERE Name = 'Teste Account'];
        ContaFinanceira__c  contaFinanceira = [SELECT Id FROM ContaFinanceira__c LIMIT 1];

        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> lstDetalhes = new List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>();
        BCSF_CLS_CalloutFaturasTO.DetalhesFatura det = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
        det.chaveParticaoTransacao = '32143';
        det.dataProcessamento = '2001-01-01';
        det.dataTransacao = Datetime.valueOf('2029-05-26 00:00:00');
        det.dataVencimentoFatura = '2001-01-01';
        det.descricao = 'Teste';
        det.faturaIndisponivel = true;
        det.idTransacao = '34534';
        det.moeda = 'R$';
        det.numeroCartao = '324453';
        det.numeroConta = '34534';
        det.reasonCode = 'abc';
        det.tipoLancamento = 'A';
        det.valor = 10;
        lstDetalhes.add(det);

        BCSF_CLS_CalloutFaturasTO.DetalhesEstorno detalhesEstorno = new BCSF_CLS_CalloutFaturasTO.DetalhesEstorno();
        detalhesEstorno.descricao = 'Caso Teste';
        detalhesEstorno.accountid = conta.Id;
        detalhesEstorno.contafinanceiraid = contaFinanceira.Id;
        detalhesEstorno.encargosRotativos = 0;
        detalhesEstorno.encargosAtraso = 0;
        detalhesEstorno.tarifaAvaliacao = 0;
        detalhesEstorno.tarifaAnuidade = 0;
        detalhesEstorno.encargosPagamento = 0;
        detalhesEstorno.encargosSaqueVisa = 0;
        detalhesEstorno.encargosSaqueMaster = 0;
        detalhesEstorno.tarifaRetirada = 0;
        detalhesEstorno.tarifaTelesaqueVista = 0;
        detalhesEstorno.tarifaSaqueVistaMastercard = 0;
        detalhesEstorno.tarifaSaqueVistaInternacionalMaster = 0;
        detalhesEstorno.tarifaSaqueVistaVisa = 0;
        detalhesEstorno.tarifaSaqueVistaInternacionalVisa = 0;
        detalhesEstorno.tarifaSaqueVistaTecban = 0;
        detalhesEstorno.tarifaSaqueParceladoTecban = 0;
        detalhesEstorno.iofDiarioSaqueParcelado = 0;
        detalhesEstorno.iofDiarioSaqueVista = 0;
        detalhesEstorno.iofAdicionalSaqueVista = 0;
        detalhesEstorno.iofDiarioPagContasVista = 0;
        detalhesEstorno.iofAdicionalPagContasVistas = 0;
        detalhesEstorno.jurosOpPagContas = 0;
        detalhesEstorno.total = 0;

        Test.startTest();
        Case caso = BCSF_CLS_CalloutFaturasController.criaOuVinculaCaso(JSON.serialize(detalhesEstorno), JSON.serialize(lstDetalhes));
        Test.stopTest();

        Assert.isNotNull(caso, 'O caso deve ser retornado');
    }

    @isTest
    public static void vincularCasoTest(){
        Account  conta = [SELECT Id FROM Account WHERE Name = 'Teste Account'];
        ContaFinanceira__c  contaFinanceira = [SELECT Id FROM ContaFinanceira__c LIMIT 1];
        Case caso = [SELECT Id FROM Case LIMIT 1];

        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> lstDetalhes = new List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>();
        BCSF_CLS_CalloutFaturasTO.DetalhesFatura det = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
        det.chaveParticaoTransacao = '32143';
        det.dataProcessamento = '2001-01-01';
        det.dataTransacao = Datetime.valueOf('2029-05-26 00:00:00');
        det.dataVencimentoFatura = '2001-01-01';
        det.descricao = 'Teste';
        det.faturaIndisponivel = true;
        det.idTransacao = '34534';
        det.moeda = 'R$';
        det.numeroCartao = '324453';
        det.numeroConta = '34534';
        det.reasonCode = 'abc';
        det.tipoLancamento = 'A';
        det.valor = 10;
        lstDetalhes.add(det);

        BCSF_CLS_CalloutFaturasTO.DetalhesEstorno detalhesEstorno = new BCSF_CLS_CalloutFaturasTO.DetalhesEstorno();
        detalhesEstorno.casoId = caso.Id;
        detalhesEstorno.descricao = 'Caso Teste';
        detalhesEstorno.accountid = conta.Id;
        detalhesEstorno.contafinanceiraid = contaFinanceira.Id;
        detalhesEstorno.encargosRotativos = 0;
        detalhesEstorno.encargosAtraso = 0;
        detalhesEstorno.tarifaAvaliacao = 0;
        detalhesEstorno.tarifaAnuidade = 0;
        detalhesEstorno.encargosPagamento = 0;
        detalhesEstorno.encargosSaqueVisa = 0;
        detalhesEstorno.encargosSaqueMaster = 0;
        detalhesEstorno.tarifaRetirada = 0;
        detalhesEstorno.tarifaTelesaqueVista = 0;
        detalhesEstorno.tarifaSaqueVistaMastercard = 0;
        detalhesEstorno.tarifaSaqueVistaInternacionalMaster = 0;
        detalhesEstorno.tarifaSaqueVistaVisa = 0;
        detalhesEstorno.tarifaSaqueVistaInternacionalVisa = 0;
        detalhesEstorno.tarifaSaqueVistaTecban = 0;
        detalhesEstorno.tarifaSaqueParceladoTecban = 0;
        detalhesEstorno.iofDiarioSaqueParcelado = 0;
        detalhesEstorno.iofDiarioSaqueVista = 0;
        detalhesEstorno.iofAdicionalSaqueVista = 0;
        detalhesEstorno.iofDiarioPagContasVista = 0;
        detalhesEstorno.iofAdicionalPagContasVistas = 0;
        detalhesEstorno.jurosOpPagContas = 0;
        detalhesEstorno.total = 0;

        Test.startTest();
        Case casoRetorno = BCSF_CLS_CalloutFaturasController.criaOuVinculaCaso(JSON.serialize(detalhesEstorno), JSON.serialize(lstDetalhes));
        Test.stopTest();

        Assert.isNotNull(casoRetorno, 'O caso deve ser retornado');
    }

    @isTest 
    public static void verificaAlcadaTest(){
    HttpResponse responseServerToServer = new HttpResponse();

        Test.StartTest();
        Boolean retorno = BCSF_CLS_CalloutFaturasController.verificaAlcada('AlcadaNaoExiste234234');
        Test.StopTest();

        Assert.isFalse(retorno, 'A alcada não existe');
    }

    @isTest
    public static void downloadFaturaSucesso() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockDownloadFaturaSemCriptografia');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        BCSF_CLS_CalloutFaturasV1.outputDownloadFatura retorno = BCSF_CLS_CalloutFaturasController.downloadFatura('37000120255', '2', '3763942', '44904911407', 'cockpit');
        Test.StopTest();

        System.assertEquals('OK', retorno.statusReponse);
    }

    @isTest
    public static void downloadFaturaEncriptedSucesso() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockDownloadFaturaComCriptografia');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        BCSF_CLS_CalloutFaturasV1.outputDownloadFatura retorno = BCSF_CLS_CalloutFaturasController.downloadFaturaEncripted('37000120255', '2', '3763942', '44904911407', 'cockpit');
        Test.StopTest();

        System.assertEquals('OK', retorno.statusReponse);
    }

    @isTest
    public static void UltimosVencimentosFechadosTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');

        HttpResponse responseVencimentos = new HttpResponse();
        responseVencimentos.setStatusCode(200);
        responseVencimentos.setBody('[{"idFatura":13163763,"data":"2029-01-11T00:00:00"},{"idFatura":13115463,"data":"2029-02-11T00:00:00"}]');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/api/v1.0/contas/10000198050/faturas/fechadas/ultimos-vencimentos' => responseVencimentos
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        List<BCSF_CLS_CalloutFaturasV1.OutputUltimosVencimentosFechados> retorno = BCSF_CLS_CalloutFaturasController.getListaFaturas('10000198050', '2', '31649927932', 'chat');
        Test.StopTest();

        List<LogIntegracao__c> log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Últimos Vencimentos Fechados'];

        System.AssertEquals(retorno[0].idFatura, 13163763);
        System.AssertEquals(retorno[1].idFatura, 13115463);

        System.AssertEquals(log.size(), 1);
        System.AssertEquals(log[0].CPF__c, '31649927932');
    }

    @isTest
    public static void getExtratoCompactoSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockObterExtratoCompacto');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        BCSF_CLS_CalloutFaturasV1.OutPutGetExtratoCompacto retorno = BCSF_CLS_CalloutFaturasController.getExtratoCompacto('1000000000', '1', '00000000000', 'chat');
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
    }

    @isTest
    public static void getExtratoCompactoErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockObterExtratoCompacto');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        BCSF_CLS_CalloutFaturasV1.OutPutGetExtratoCompacto retorno = BCSF_CLS_CalloutFaturasController.getExtratoCompacto('1000000000', '1', '00000000000', 'chat');
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

}