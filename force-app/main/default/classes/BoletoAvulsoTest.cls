/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BeletoAvulso                 100%                                 *
*    - BeletoAvulsoController       100%                                 *
**************************************************************************/
@isTest
public class BoletoAvulsoTest {
   
   @isTest
   public static void obterParametrosIniciaisOkTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseParametrosIniciais = new HttpResponse();
      responseParametrosIniciais.setStatusCode(200);
      responseParametrosIniciais.setBody('{"valorMinimo": 10.00, "valorMaximo": 10485.1, "boletosValidos": [ { "id": 141833, "codigoBarras": "36893987700000000000001263000559495900100020", "linhaDigitavel": "36890.00122 63000.559493 59001.000200 3 98770000000000", "dataEmissao": "2024-10-17T09:27:24.053", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141834, "codigoBarras": "36897987700000000000001263000557274700100020", "linhaDigitavel": "36890.00122 63000.557275 47001.000201 7 98770000000000", "dataEmissao": "2024-10-17T09:38:18.133", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141835, "codigoBarras": "36893987700000000000001263000559619300100020", "linhaDigitavel": "36890.00122 63000.559611 93001.000202 3 98770000000000", "dataEmissao": "2024-10-17T10:08:53.57", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141838, "codigoBarras": "36891987700000000000001263000633289100100010", "linhaDigitavel": "36890.00122 63000.633283 91001.000107 1 98770000000000", "dataEmissao": "2024-10-17T14:49:24.797", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 42.00 }, { "id": 141839, "codigoBarras": "36899987700000000000001263000633412500100010", "linhaDigitavel": "36890.00122 63000.633411 25001.000104 9 98770000000000", "dataEmissao": "2024-10-17T15:03:47.5", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 40.00 }, { "id": 141840, "codigoBarras": "36891987700000000000001263000633535900100010", "linhaDigitavel": "36890.00122 63000.633536 59001.000101 1 98770000000000", "dataEmissao": "2024-10-17T15:10:57.91", "dataVencimento": "2024-10-22T00:00:00", "valorBoleto": 40.00 } ]}');

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputParametrosIniciais retorno = BoletoAvulsoController.obterParametrosIniciais('10000045616', '25455513680', '2', 'cockpit', 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual(10.00, retorno.valorMinimo, 'O valor mínimo deve ser igual ao configurado no mock');
      Assert.areEqual(10485.1, retorno.valorMaximo, 'O valor máximo deve ser igual ao configurado no mock');
      Assert.areEqual('OK', retorno.statusAPI, 'O status da API deve ser OK');
      Assert.isNotNull(retorno.boletosValidos, 'Os boleto válidos devem ser retornados');
   }

   @isTest
   public static void obterParametrosIniciaisErrorTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseParametrosIniciais = new HttpResponse();
      responseParametrosIniciais.setStatusCode(400);

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputParametrosIniciais retorno = BoletoAvulsoController.obterParametrosIniciais('10000045616', '25455513680', '2', 'cockpit', 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('ERROR', retorno.statusAPI, 'O status da API deve ser ERROR');
   }

   @isTest
    public static void obterParametrosIniciaisSaldoInsuficienteTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');

        HttpResponse responseParametrosIniciais = new HttpResponse();
        responseParametrosIniciais.setStatusCode(422);
        responseParametrosIniciais.setBody('{"mensagem":"Cliente não elegível para geração de boleto, valor da dívida menor que o valor mínimo. Conta: 10000055912."}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/boleto/avulso/parametros-iniciais' => responseParametrosIniciais
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputParametrosIniciais retorno = BoletoAvulsoController.obterParametrosIniciais('10000045616', '25455513680', '2', 'cockpit', 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('OK', retorno.statusAPI, 'O status da API deve ser OK');
      Assert.isTrue(retorno.saldoDevedorInsuficiente, 'O saldo devedor é insuficiente');
   }  

   @isTest
   public static void gerarBoletoAvulsoOkTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseGerarBoleto = new HttpResponse();
      responseGerarBoleto.setStatusCode(200);
      responseGerarBoleto.setBody('{ "codigoBarras": "36891987700000000000001263000633289100100010", "linhaDigitavel": "36890.00122 63000.633283 91001.000107 1 98770000000000", "linhaDigitavelCarrefour": "40000.000000.002210.240001.000004.561656", "dataVencimentoBoleto": "2024-10-22", "indicadorBoletoRegistrado": true, "boletoHtml" : "GNvbGxhcHNlO3dpZHRoOiAxMDAlO30NCgkgIC5ib3JkYXNEYXNURHN7Ym9yZGVyLWxlZnQ6IDFweCBzb2xpZCBibGFjaztib3JkZXItcmlnaHQ6IDFweCBzb2xpZCBibGFjazt9DQo", "boletoPdf": "JVBERi0xLjQKJdPr6eEKMSAwIG9iago8PC9DcmVhdG9yIChDaHJvbWl1bSkKL1Byb2R1Y2VyIChTa2lhL1BERiBtMTIwKQovQ3JlYXRpb25EYXRl" }');

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/avulso' => responseGerarBoleto
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputGerarBoleto retorno = BoletoAvulsoController.gerarBoletoAvulso('10000045616', '25455513680', '2', 'cockpit', null, 10.50, 2, 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('OK', retorno.statusAPI, 'O status de api deve ser OK');
      Assert.areEqual('36891987700000000000001263000633289100100010', retorno.codigoBarras, 'O código de barras deve ser o mesmo configurado no mock');
      Assert.areEqual('2024-10-22', retorno.dataVencimentoBoleto, 'A data de vencimento deve ser a mesma configurada no mock');
   }

    @isTest
   public static void gerarBoletoAvulsoErrorTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseGerarBoleto = new HttpResponse();
      responseGerarBoleto.setStatusCode(400);

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/avulso' => responseGerarBoleto
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputGerarBoleto retorno = BoletoAvulsoController.gerarBoletoAvulso('10000045616', '25455513680', '2', 'cockpit', null, 10.50, 2, 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('ERROR', retorno.statusAPI, 'O status de api deve ser ERROR');
   }

   @isTest
   public static void enviarBoletoAvulsoOkTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseEnviarEmail = new HttpResponse();
      responseEnviarEmail.setStatusCode(200);

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/enviar-email' => responseEnviarEmail
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputEnviarBoleto retorno = BoletoAvulsoController.enviarBoleto('10000045616', '25455513680', '2', 'cockpit', 'teste@carrefour.com', new List<String>{'141838'}, 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('OK', retorno.statusAPI, 'O status de api deve ser OK');
   }

   @isTest
   public static void enviarBoletoAvulsoErrorTest(){
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
      
      HttpResponse responseEnviarEmail = new HttpResponse();
      responseEnviarEmail.setStatusCode(400);

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/boleto/enviar-email' => responseEnviarEmail
      };

      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      BoletoAvulso.OutputEnviarBoleto retorno = BoletoAvulsoController.enviarBoleto('10000045616', '25455513680', '2', 'cockpit', 'teste@carrefour.com', new List<String>{'141838'}, 'cockpit', 'ouvidoria', '111');
      Test.StopTest();

      Assert.areEqual('ERROR', retorno.statusAPI, 'O status de api deve ser ERROR');
   }


   @isTest
   public static void AlterarEmailTest() {
      HttpResponse responseServerToServer = new HttpResponse();
      responseServerToServer.setStatusCode(200);
      responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
      
      HttpResponse responseAPI = new HttpResponse();
      responseAPI.setBody('{"email":"teste.teste@gmail.com"}');
      responseAPI.setStatusCode(200);

      Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
               '/idp/server-to-server' => responseServerToServer, 
               '/api/v1/conta/37000081481/atualizar-email' => responseAPI
      };
      Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

      Test.StartTest();
      String cpf = '04544371457';
      String unidade = '1';
      String canal = 'cockpit';
      String email = 'teste.teste@gmail.com';
      String numeroConta = '37000081481';
      String area = 'ouvidoria';
      String sistema = 'ouvidoria';

      Boolean retorno = BoletoAvulsoController.atualizarEmail(cpf, unidade, canal, email, numeroConta, area, sistema);
      Test.StopTest();

      LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alteração de E-mail' LIMIT 1];

      System.AssertEquals(true            , retorno);
      System.AssertEquals('04544371457'   , log.CPF__c);
      System.AssertEquals('POST'          , log.Metodo__c);
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
         BoletoAvulsoController.criarCaso('Ouvidoria', cf.Id, acc.Id, '1', 'Whatsapp', 'Execução', 'Fatura', 'Antecipar fatura');
      Test.StopTest();

      System.AssertEquals(1, [SELECT COUNT() FROM Case]);
   }
}