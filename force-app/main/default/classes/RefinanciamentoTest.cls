@isTest
public class RefinanciamentoTest {
    @isTest
    public static void GetDadosContratoOriginal(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"statusContrato":"Vigente","dataLiquidacao":"2024-05-22T00:00:00-03:00","valorContratado":3746.78,"dataContratacao":"2024-05-02T00:00:00-03:00","valorLiberado":3000.00,"diasAtraso":0,"valorPago":892.70,"valorParcelaContratado":158.56,"valorPresenteContrato":2218.81,"quantidadeTotalParcelas":24,"numeroContrato":1000031138,"quantidadeParcelasPagas":6,"dataVencimentoPrimeiraParcela":"2024-06-10T00:00:00","dataVencimentoUltimaParcela":"2026-05-10T00:00:00","taxaJurosMensal":1.68,"taxaJurosAnual":22.13,"custoEfetivoTotalMensal":1.95,"custoEfetivoTotalAnual":26.04,"iof":1.46}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/api/v1/contrato/987654321' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        IntegrationConsignado.OutputDadosContratoOriginal output = RefinanciamentoController.GetDadosContratoOriginal('cockpit', '12345678912', '987654321', '1');
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Dados de Contrato Original'].size());
        System.AssertEquals(3746.78, output.valorContratado);
        System.AssertEquals('Vigente', output.statusContrato);
        System.AssertEquals(892.70, output.valorPago);
    }

    @isTest
    public static void CriarPropostaRefinanciamentoTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"idProposta":"d205da1b-b788-4571-ab7f-45372329e742"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/propostas/completa' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        IntegrationConsignado.OutputPropostaRefinanciamento output = RefinanciamentoController.CriarPropostaRefinanciamento('123456789', 'cockpit', '1', 'test@gmail.com', '987654321');
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Criar Proposta para Refinanciamento'].size());
        System.AssertEquals('OK', output.StatusAPI);
        System.AssertEquals('d205da1b-b788-4571-ab7f-45372329e742', output.idProposta);
    }

    @isTest
    public static void CalcularSimulacaoRefinanciamentoTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"valorSaldoDevedor":2218.81,"valorParcelaAtual":158.56,"totalParcelas":24,"parcelaPagas":6,"taxa":1.6800,"vlrMargem":306.22,"simulacoes":[{"resumo":{"mensagem":"Valor financiado inferior ao saldo devedor.","novoValorEmprestimo":0,"valorEmprestimoPercentual":0,"parcela":0,"novaTaxa":0,"iofTotal":0,"custoEfetivoTotal":0,"valorTroco":0,"valorFinanciado":0,"prazo":2}},{"resumo":{"mensagem":"Valor financiado inferior ao saldo devedor.","novoValorEmprestimo":0,"valorEmprestimoPercentual":0,"parcela":0,"novaTaxa":0,"iofTotal":0,"custoEfetivoTotal":0,"valorTroco":0,"valorFinanciado":0,"prazo":8}},{"resumo":{"mensagem":"Valor financiado inferior ao saldo devedor.","novoValorEmprestimo":0,"valorEmprestimoPercentual":0,"parcela":0,"novaTaxa":0,"iofTotal":0,"custoEfetivoTotal":0,"valorTroco":0,"valorFinanciado":0,"prazo":14}},{"resumo":{"novoValorEmprestimo":3171.20,"valorEmprestimoPercentual":13,"parcela":158.56,"novaTaxa":1.65,"iofTotal":11.74,"custoEfetivoTotal":22.6483154,"valorTroco":417.63,"valorFinanciado":2648.18,"prazo":20},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":3171.20,"valorTotalReceber":417.63,"valorTotalReceberPercentual":13,"despesasVinculadas":534.76,"despesasVinculadasPercentual":17},"despesasVinculadas":{"iofTotal":11.74,"iofTotalPercentual":100,"iofAdicional":1.63,"iofAdicionalPercentual":0.3048096,"iofDiario":10.11,"iofDiarioPercentual":1.8905677,"encargos":523.02,"encargosPercentual":97.8046226,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":26,"cetMaximoCustoEfetivoTotalAnual":22.6483154,"cetMaximoCustoEfetivoTotalMensal":1.7158108}}},{"resumo":{"novoValorEmprestimo":4122.56,"valorEmprestimoPercentual":25,"parcela":158.56,"novaTaxa":1.65,"iofTotal":31.13,"custoEfetivoTotal":23.0936279,"valorTroco":1036.13,"valorFinanciado":3286.07,"prazo":26},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":4122.56,"valorTotalReceber":1036.13,"valorTotalReceberPercentual":25,"despesasVinculadas":867.62,"despesasVinculadasPercentual":21},"despesasVinculadas":{"iofTotal":31.13,"iofTotalPercentual":100,"iofAdicional":4.06,"iofAdicionalPercentual":0.4679468,"iofDiario":27.07,"iofDiarioPercentual":3.1200295,"encargos":836.49,"encargosPercentual":96.4120237,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":32,"cetMaximoCustoEfetivoTotalAnual":23.0936279,"cetMaximoCustoEfetivoTotalMensal":1.7465356}}},{"resumo":{"novoValorEmprestimo":5073.92,"valorEmprestimoPercentual":31,"parcela":158.56,"novaTaxa":1.65,"iofTotal":49.74,"custoEfetivoTotal":23.2471923,"valorTroco":1594.59,"valorFinanciado":3863.14,"prazo":32},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":5073.92,"valorTotalReceber":1594.59,"valorTotalReceberPercentual":31,"despesasVinculadas":1260.52,"despesasVinculadasPercentual":25},"despesasVinculadas":{"iofTotal":49.74,"iofTotalPercentual":100,"iofAdicional":6.25,"iofAdicionalPercentual":0.4958271,"iofDiario":43.49,"iofDiarioPercentual":3.4501634,"encargos":1210.78,"encargosPercentual":96.0540095,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":38,"cetMaximoCustoEfetivoTotalAnual":23.2471923,"cetMaximoCustoEfetivoTotalMensal":1.7571073}}},{"resumo":{"novoValorEmprestimo":6025.28,"valorEmprestimoPercentual":35,"parcela":158.56,"novaTaxa":1.65,"iofTotal":67.22,"custoEfetivoTotal":23.2876586,"valorTroco":2099.84,"valorFinanciado":4385.87,"prazo":38},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":6025.28,"valorTotalReceber":2099.84,"valorTotalReceberPercentual":35,"despesasVinculadas":1706.63,"despesasVinculadasPercentual":28},"despesasVinculadas":{"iofTotal":67.22,"iofTotalPercentual":100,"iofAdicional":8.23,"iofAdicionalPercentual":0.4822369,"iofDiario":58.99,"iofDiarioPercentual":3.4565196,"encargos":1639.41,"encargosPercentual":96.0612435,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":43,"cetMaximoCustoEfetivoTotalAnual":23.2876586,"cetMaximoCustoEfetivoTotalMensal":1.7598911}}},{"resumo":{"novoValorEmprestimo":6976.64,"valorEmprestimoPercentual":37,"parcela":158.56,"novaTaxa":1.65,"iofTotal":83.33,"custoEfetivoTotal":23.2789001,"valorTroco":2556.62,"valorFinanciado":4858.76,"prazo":44},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":6976.64,"valorTotalReceber":2556.62,"valorTotalReceberPercentual":37,"despesasVinculadas":2201.21,"despesasVinculadasPercentual":32},"despesasVinculadas":{"iofTotal":83.33,"iofTotalPercentual":100,"iofAdicional":10.03,"iofAdicionalPercentual":0.4556585,"iofDiario":73.30,"iofDiarioPercentual":3.3299867,"encargos":2117.88,"encargosPercentual":96.2143548,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":48,"cetMaximoCustoEfetivoTotalAnual":23.2789001,"cetMaximoCustoEfetivoTotalMensal":1.7592887}}},{"resumo":{"novoValorEmprestimo":7928.00,"valorEmprestimoPercentual":37,"parcela":158.56,"novaTaxa":1.65,"iofTotal":98.09,"custoEfetivoTotal":23.2494506,"valorTroco":2969.97,"valorFinanciado":5286.87,"prazo":50},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":7928.00,"valorTotalReceber":2969.97,"valorTotalReceberPercentual":37,"despesasVinculadas":2739.22,"despesasVinculadasPercentual":35},"despesasVinculadas":{"iofTotal":98.09,"iofTotalPercentual":100,"iofAdicional":11.66,"iofAdicionalPercentual":0.4256686,"iofDiario":86.43,"iofDiarioPercentual":3.1552778,"encargos":2641.13,"encargosPercentual":96.4190536,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":53,"cetMaximoCustoEfetivoTotalAnual":23.2494506,"cetMaximoCustoEfetivoTotalMensal":1.7572627}}},{"resumo":{"novoValorEmprestimo":8879.36,"valorEmprestimoPercentual":38,"parcela":158.56,"novaTaxa":1.65,"iofTotal":111.55,"custoEfetivoTotal":23.2115631,"valorTroco":3343.82,"valorFinanciado":5674.18,"prazo":56},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":8879.36,"valorTotalReceber":3343.82,"valorTotalReceberPercentual":38,"despesasVinculadas":3316.73,"despesasVinculadasPercentual":37},"despesasVinculadas":{"iofTotal":111.55,"iofTotalPercentual":100,"iofAdicional":13.13,"iofAdicionalPercentual":0.3958718,"iofDiario":98.42,"iofDiarioPercentual":2.9673805,"encargos":3205.18,"encargosPercentual":96.6367476,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":57,"cetMaximoCustoEfetivoTotalAnual":23.2115631,"cetMaximoCustoEfetivoTotalMensal":1.7546556}}},{"resumo":{"novoValorEmprestimo":9830.72,"valorEmprestimoPercentual":37,"parcela":158.56,"novaTaxa":1.65,"iofTotal":123.88,"custoEfetivoTotal":23.1723938,"valorTroco":3682.31,"valorFinanciado":6025.00,"prazo":62},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":9830.72,"valorTotalReceber":3682.31,"valorTotalReceberPercentual":37,"despesasVinculadas":3929.60,"despesasVinculadasPercentual":40},"despesasVinculadas":{"iofTotal":123.88,"iofTotalPercentual":100,"iofAdicional":14.46,"iofAdicionalPercentual":0.3679764,"iofDiario":109.42,"iofDiarioPercentual":2.7845073,"encargos":3805.72,"encargosPercentual":96.8475163,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":61,"cetMaximoCustoEfetivoTotalAnual":23.1723938,"cetMaximoCustoEfetivoTotalMensal":1.7519595}}},{"resumo":{"novoValorEmprestimo":10782.08,"valorEmprestimoPercentual":37,"parcela":158.56,"novaTaxa":1.65,"iofTotal":134.98,"custoEfetivoTotal":23.1327209,"valorTroco":3988.59,"valorFinanciado":6342.38,"prazo":68},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":10782.08,"valorTotalReceber":3988.59,"valorTotalReceberPercentual":37,"despesasVinculadas":4574.68,"despesasVinculadasPercentual":42},"despesasVinculadas":{"iofTotal":134.98,"iofTotalPercentual":100,"iofAdicional":15.67,"iofAdicionalPercentual":0.3425376,"iofDiario":119.31,"iofDiarioPercentual":2.6080513,"encargos":4439.70,"encargosPercentual":97.0494111,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":65,"cetMaximoCustoEfetivoTotalAnual":23.1327209,"cetMaximoCustoEfetivoTotalMensal":1.7492280}}},{"resumo":{"novoValorEmprestimo":11099.20,"valorEmprestimoPercentual":37,"parcela":158.56,"novaTaxa":1.65,"iofTotal":138.53,"custoEfetivoTotal":23.1206054,"valorTroco":4084.07,"valorFinanciado":6441.41,"prazo":70},"taxasDetalhadas":{"taxasCobradas":{"valorTotalPagar":11099.20,"valorTotalReceber":4084.07,"valorTotalReceberPercentual":37,"despesasVinculadas":4796.32,"despesasVinculadasPercentual":43},"despesasVinculadas":{"iofTotal":138.53,"iofTotalPercentual":100,"iofAdicional":16.05,"iofAdicionalPercentual":0.3346316,"iofDiario":122.48,"iofDiarioPercentual":2.5536244,"encargos":4657.79,"encargosPercentual":97.1117440,"tarifas":0,"seguros":0},"jurosCet":{"taxaJuros":1.65,"taxaJurosAnual":21.6994444,"valorJurosMensal":67,"cetMaximoCustoEfetivoTotalAnual":23.1206054,"cetMaximoCustoEfetivoTotalMensal":1.7483937}}}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/simulacao/d205da1b-b788-4571-ab7f-45372329e742?usarMargem=true&receberTrocoMaximo=true' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        RefinanciamentoBO.OutputCalcularSimulacaoRefinanciamento output = RefinanciamentoController.CalcularSimulacaoRefinanciamento('123456789', 'cockpit', '1', 'd205da1b-b788-4571-ab7f-45372329e742', true, true, 12, 200);
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Calcular Simulação de Refinanciamento'].size());
        System.AssertEquals(output.StatusAPI, 'OK');
        System.AssertEquals(output.ListOpcoesParcelas.size(), 10);
        System.AssertEquals(output.ListDetalhesPorParcela[0].QuantidadeDeParcelas, 20);
        System.AssertEquals(output.ListDetalhesPorParcela[0].NovaTaxa, 1.65);
        System.AssertEquals(output.ListDetalhesPorParcela[0].NovoValorParcela, 158.56);
        System.AssertEquals(output.ListDetalhesPorParcela[0].NovoValorTotal, 3171.20);
        System.AssertEquals(output.ListDetalhesPorParcela[0].ValorTroco, 417.63);
    }

    @isTest
    public static void GravarSimulacaoRefinanciamentoTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"ufBeneficio":"SC","custoEfetivoTotalMensal":1.7546556,"documento":{"numeroDocumento":"27806846662","tipoDocumento":"CPF"},"prazo":56,"iofAdicional":13.13,"nroSolicitacao":860873,"valorLiberado":3343.82,"valorTotal":8879.36,"taxaMensal":1.65,"codigoConvenio":2,"dataInicio":"2024-05-22T00:00:00-03:00","iofNormal":98.42,"dataUltimoVencimento":"2029-01-15T00:00:00-02:00","dadosContaLiberacao":{"digitoAgencia":"","digitoConta":"5","numeroConta":"56451","banco":"001","tipoCreditoConta":"C","codigoAgencia":"497"},"nomeBeneficiario":"Vicente Miguel Joao Martins","custoEfetivoTotalAnual":23.2115631,"numeroContrato":1000031138,"jurosAnual":21.6994444,"valorPrincipal":5674.18,"iofValorTotal":111.55,"codigoBeneficio":"4135447260","codigoCliente":307912,"jurosValorTotal":3205.18,"codigoProduto":312,"dataPrimeiroVencimento":"2024-07-10T00:00:00-03:00","valorFinanciado":5674.18,"valorSaldoDevedor":2218.81}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/simulacao' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        String bodyRequest = '{"propostaId":"d205da1b-b788-4571-ab7f-45372329e742","valorTotalReceber":1.0,"quantidadeParcelas":24,"valorParcelas":1149.99,"valorTotalPagar":2297.98,"cetAnualPercentual":22.0312500,"cetMensalPercentual":1.6730663,"despesasVinculadas":89.03,"despesasVinculadasPercentual":4,"encargos":206.81,"encargosPercentual":89.03,"valorIofAdicional":0.00,"iofAdicionalPercentual":0,"valorIofDiario":0.00,"iofDiarioPercentual":0,"seguros":0,"valorIofTotal":0.00,"valorJuros":89.03,"valorJurosMensal":45,"valorEmprestimoPercentual":1.0,"tarifas":0,"taxaJurosMensal":1.65,"taxaJurosAnual":21.6994444,"valorSaldoDevedor":2207.75,"valorPrincipal":2207.75,"valorTroco":0.00,"valorFinanciado":1.00,"dataSugerida":"2024-06-12T12:40:08.598Z"}';
        Test.StartTest();
        IntegrationConsignado.OutputGravarSimulacaoRefinanciamento output = RefinanciamentoController.GravarSimulacaoRefinanciamento('123456789', 'cockpit', '1', bodyRequest);
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Gravar Simulação de Refinanciamento'].size());
        System.AssertEquals(output.StatusAPI, 'OK');
        System.AssertEquals(output.ufBeneficio, 'SC');
        System.AssertEquals(output.prazo, 56);
        System.AssertEquals(output.taxaMensal, 1.65);
        System.AssertEquals(output.jurosAnual, 21.6994444);
    }

    @isTest
    public static void FinalizarSimulacaoRefinanciamentoTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"link":"https://consignadoinss.carrefoursolucoes.com.br/refin/f/da1c889c69a73c9b0c79"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/propostas/efetivacao' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        IntegrationConsignado.OutputFimSimulacaoRefinanciamento output = RefinanciamentoController.FinalizarSimulacaoRefinanciamento('123456789', 'cockpit', '1', 'd205da1b-b788-4571-ab7f-45372329e742');
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Finalizar Simulação de Refinanciamento'].size());
        System.AssertEquals(output.StatusAPI, 'OK');
        System.AssertEquals(output.link, 'https://consignadoinss.carrefoursolucoes.com.br/refin/f/da1c889c69a73c9b0c79');
    }

    @isTest
    public static void GetDadosBancariosDesembolsoTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"conta":564515,"cpf":"27806846662","banco":"001 - Banco do Brasil S.A.","contrato":1000031138,"nome":"Vicente Miguel Joao Martins","estadoSpb":"Processado","agencia":"497"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/propostas/dados-bancarios-desembolso/d205da1b-b788-4571-ab7f-45372329e742' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        IntegrationConsignado.OutputGetDadosBancarios output = RefinanciamentoController.GetDadosBancariosDesembolso('123456789', 'cockpit', '1', 'd205da1b-b788-4571-ab7f-45372329e742');
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Dados Bancarios Desembolso'].size());
        System.AssertEquals(output.StatusAPI, 'OK');
        System.AssertEquals(output.conta, '564515');
        System.AssertEquals(output.cpf, '27806846662');
        System.AssertEquals(output.banco, '001 - Banco do Brasil S.A.');
        System.AssertEquals(output.contrato, 1000031138);
        System.AssertEquals(output.nome, 'Vicente Miguel Joao Martins');
    }

    @isTest
    public static void GravarDadosBancariosAlternativosTest(){
        HttpResponse TokenCSFServicos = new HttpResponse();
        TokenCSFServicos.setStatusCode(200);
        TokenCSFServicos.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setStatusCode(200);
        responseAPI.setBody('{"conta":564515,"cpf":"27806846662","banco":"001 - Banco do Brasil S.A.","contrato":1000031138,"nome":"Vicente Miguel Joao Martins","estadoSpb":"Processado","agencia":"497"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
            '/csf-servicos' => TokenCSFServicos, 
            '/v1/refinanciamento/propostas/dados-bancarios-alternativos' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        
        Test.StartTest();
        IntegrationConsignado.OutputGravarDadosBancariosAlternativos output = RefinanciamentoController.GravarDadosBancariosAlternativos('123456789', 'cockpit', '1', 'd205da1b-b788-4571-ab7f-45372329e742', '000', '1111', '222222');
        Test.StopTest();

        System.AssertEquals(1, [SELECT id FROM LogIntegracao__c WHERE NomeServico__c = 'Gravar Dados Bancarios Alternativos'].size());
        System.AssertEquals(output.StatusAPI, 'OK');
    }

    @isTest
    public static void GetContaFinanceiraTest() {
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;

        Test.StartTest();
        RefinanciamentoBO.ContaFinanceiraTO rt = RefinanciamentoController.GetContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals(rt.NumeroConta, '11111111111');
        System.AssertEquals(rt.Nome, 'Teste');
        System.AssertEquals(rt.CPF, '123.456.789-12');
        System.AssertEquals(rt.StatusConta, 'NORM');
    }

    @isTest
    public static void CriarCasoConsignadoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.StatusConta__c = 'NORM';
        insert cf;

        String inputInfoConsignado = '{"ValorTrocoRefinanciamento":"R$ 150,20","ValorTotalRefinanciamento":"R$ 3000,,","TrocoRefinanciamento":true,"Telefone":"55799998800114","QuantidadeParcelasRefinanciamento":20,"NumeroContrato":"987654321","NovaTaxaRefinanciamento":"1.6% ao mês","NovaParcelaRefinanciamento":"R$ 230,65","NomeCliente":"Teste","LinkRefinanciamento":"https://consignadoinss.carrefoursolucoes.com.br/refin/f/da1c889c69a73c9b0c79","IdOfertaRefinanciemento":"d205da1b-b788-4571-ab7f-45372329e742"}';

        Test.startTest();
        Case caseRetorno = RefinanciamentoController.CriarCaso(cf.Id, acc.Id, '1', 'Customer Support', 'E-mail');
        Consignado__c consignadoRetorno =RefinanciamentoController.CriarConsignado(cf.Id, acc.Id, caseRetorno.Id, '1', inputInfoConsignado, '11999999999');
        Test.stopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
        System.AssertEquals(1, [SELECT COUNT() FROM Consignado__c]);
         System.AssertEquals('11999999999', [SELECT UltimoContato__c FROM Account WHERE Id =: acc.Id].UltimoContato__c);
    }
}