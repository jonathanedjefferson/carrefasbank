@IsTest 
public class BCSF_CLS_CalloutFaturasTest {
    public class MakeHTTPCallMockGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            if (req.getEndpoint() != 'localhost'){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"some-key":"some-value"}');
                res.setStatusCode(200);
                return res;
            }
            else{
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Test Error');
                throw e;
            }
        }
    }
    
    @isTest 
    static void TestCallout() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MakeHTTPCallMockGenerator());
        
        String retFaturaAberta = BCSF_CLS_CalloutFaturas.buscarFaturaAberta('123456', '123456', '1', 'cockpit');
        Test.stopTest();
    }
    
    @isTest 
    static void TestCallout2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MakeHTTPCallMockGenerator());
        
        String retFaturaFechada = BCSF_CLS_CalloutFaturas.buscarFaturaFechada('37000072894', '33509205430', '2', 'cockpit');
        Test.stopTest();
    }
    
    @isTest 
    static void TestCallout3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MakeHTTPCallMockGenerator());
        
        BCSF_CLS_CalloutFaturas.buscarDetalhesFatura('123456', '123456', '1', '6', 'cockpit');
        Test.stopTest();
    }
    
    @IsTest 
    static void testParse() {
        Test.startTest();        
        String json = '{ \"faturaDetalhada\": { \"tipoFatura\": \"Aberta\", \"valorFatura\": { \"valor\": 0, \"moeda\": \"string\" }, \"dataVencimento\": \"2022-05-23T18:03:12.980Z\", \"totalDescontos\": { \"valor\": 0, \"moeda\": \"string\" }, \"totalDescontosUltimoAno\": {\"valor\": 0, \"moeda\": \"string\" }, \"pagamentoMinimo\": { \"valor\": 0, \"moeda\": \"string\" }, \"pagamentoEfetuado\": { \"valor\": 0, \"moeda\": \"string\" }, \"linhaDigitavel\": \"string\", \"codigoBarras\": \"string\", \"lancamentos\": [{ \"numeroCartao\": \"string\", \"idTransacao\": \"string\", \"chaveParticaoTransacao\": \"string\", \"dataTransacao\": \"2025-04-08\", \"dataProcessamento\": \"string\", \"tipoLancamento\": \"Compra\", \"descricao\": \"string\", \"reasonCode\": \"string\", \"valor\": { \"valor\": 0, \"moeda\": \"string\" }, \"idCategoria\": \"Supermercado\", \"nomeCategoria\": \"string\", \"identificadorOnUs\": \"OffUs\", \"quantidadeParcelas\": 0, \"numeroParcela\": 0, \"detalhesLancamentoParcela\": { \"quantidadeParcelas\": 0, \"numeroParcelaTransacao\": 0,\"parcelamentoSerno\": 0, \"parcelaIndice\": 0, \"parcelamentoPartitionKey\": 0}, \"idTransacaoVinculada\": \"string\", \"descontos\": [ { \"nomeProduto\": \"string\", \"quantidadeProdutos\": 0, \"valorTotalDesconto\": { \"valor\": 0, \"moeda\": \"string\" } } ], \"modoTransacao\": \"string\", \"codigoAutorizacao\": \"string\", \"numeroConta\": \"string\", \"dataVencimentoFatura\": \"2022-05-23T18:03:12.980Z\", \"modoTransacaoNumerico\": \"string\" } ] }}';
        BCSF_DetalhesFaturaService obj = BCSF_DetalhesFaturaService.parse(json);
        Test.stopTest();
        System.assert(obj != null);
    }

    @isTest 
    static void testCriarCaso() {

        Account acc = new Account();
        acc.Name = 'Teste Account';
        acc.CPF__c = '12345678900';
        insert acc;

        ContaFinanceira__c cF = new ContaFinanceira__c();
        cF.NumeroConta__c = '123333333';
        cF.NomeCliente__c = acc.Id;
        insert cf;

        Case c = new Case();
        c.CampoControle__c = true;
        c.Description = 'Teste';
        c.NomeContato__c = 'Teste';
        c.CPFContato__c = '42104961033';
        insert c;
		
      	List<BCSF_CLS_CalloutFaturas.DetalhesFatura> lstDetalhes = new List<BCSF_CLS_CalloutFaturas.DetalhesFatura>();
        BCSF_CLS_CalloutFaturas.DetalhesFatura det = new BCSF_CLS_CalloutFaturas.DetalhesFatura();
        det.chaveParticaoTransacao = '2001-01-01';
        det.dataProcessamento = '2001-01-01';
        det.dataTransacao = '2001-01-01';
        det.dataVencimentoFatura = '2001-01-01';
        det.descricao = 'E';
        det.faturaIndisponivel = true;
        det.idTransacao = 'A';
        det.moeda = 'C';
        det.numeroCartao = 'D';
        det.numeroConta = 'E';
        det.reasonCode = 'AAA';
        det.tipoLancamento = 'A';
        det.valor = 10;
        lstDetalhes.add(det);

        BCSF_CLS_CalloutFaturas.DetalhesEstorno detalhesEstorno = new BCSF_CLS_CalloutFaturas.DetalhesEstorno();
        detalhesEstorno.casoId = c.Id;
        detalhesEstorno.descricao = 'Caso Teste';
        detalhesEstorno.accountid = acc.Id;
        detalhesEstorno.contafinanceiraid = cF.Id;
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
        
        BCSF_CLS_CalloutFaturas.criaOuVinculaCaso(JSON.serialize(detalhesEstorno), JSON.serialize(lstDetalhes));
        
        detalhesEstorno.casoId = null;
        BCSF_CLS_CalloutFaturas.criaOuVinculaCaso(JSON.serialize(detalhesEstorno), JSON.serialize(new List<BCSF_CLS_CalloutFaturas.DetalhesFatura>()));
    }
}