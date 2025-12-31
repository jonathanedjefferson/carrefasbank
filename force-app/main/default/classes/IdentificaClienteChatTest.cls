/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - IdentificaClienteChat                                 100%        *
*    - IdentificaClienteChatDAO                              80%         *
*    - IdentificaClienteChatHelper                           91%         *
**************************************************************************/

@isTest
public class IdentificaClienteChatTest {

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
    public static void IdentificarClienteTestOK(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setBody('{"data":{"cliente":{"dadosSociais":[{"nomePrimeiro":"MARIANA","nomeMeio":"RAMOS","nomeUltimo":"REIS","nomeSocial":"","nomeCompleto":"MARIANA RAMOS REIS","dataDeNascimento":"1981-06-22T03:00:00Z","nomeMae":"DORALICE FLORES OLIVEIRA","genero":"M","numeroConta":"37000001646"}],"contaCartao":{"contratos":[{"valorLimiteTotal":50000,"valorLimiteDisponivel":48500.68,"numeroContaSerno":"813268","cartoes":[{"id":"894928","numeroCartao":"5300.XXXX.XXXX.9402","statusCartao":"NORM","ehPrimario":true}],"numeroConta":"37000001646","unidadeNegocio":"CSF","dataAberturaConta":"2023-08-04","statusConta":"NORM"}]},"contato":{"dadosContato":[{"numeroConta":"37000001646","telefones":[{"ddd":"19","numero":"994268795","celularSeguro":false},{"ddd":"11","numero":"33334444","celularSeguro":false},{"ddd":"11","numero":"44443333","celularSeguro":false},{"ddd":"11","numero":"932761946","celularSeguro":true}],"emails":[{"endereco":"teste@gmail.com"}]}]},"cpf":"25600049765"}}}');
        responseIdentifica.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChaveContaFinanceira__c = '37000001646';
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input aa = new IdentificaClienteChatHelper.Input();
        aa.RoutableId = lct.Id;
        aa.idEmpresa = '1';
        aa.unidadeNegocio = 'CSF';
        listInput.add(aa);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identifica Cliente' LIMIT 1];
        System.AssertEquals('25600049765', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);

        System.AssertEquals(retorno[0].ClienteIdentificado, true);
        System.AssertEquals(retorno[0].CpfCliente, '25600049765');
        System.AssertEquals(retorno[0].Email, 'teste@gmail.com');
        System.AssertEquals(retorno[0].EmailMascarado, 'tes**@gmail.com');
        System.AssertEquals(retorno[0].IdCartaoPrimario, '894928');
        System.AssertEquals(retorno[0].PrimeiroNome, 'MARIANA');
        System.AssertEquals(retorno[0].StatusCodeApi, 200);
        System.AssertEquals(retorno[0].TemCelularSeguro, true);
        System.AssertEquals(retorno[0].NumeroCelularSeguro, '(**) *****-1946');
        System.AssertEquals(retorno[0].LimiteTotal, 'R$ 50.000,00');
        System.AssertEquals(retorno[0].LimiteDisponivel, 'R$ 48.500,68');
        System.AssertEquals(retorno[0].nomeMae, 'DORALICE FLORES OLIVEIRA');
        System.AssertEquals(retorno[0].genero, 'M');
        System.AssertEquals(retorno[0].ddd, '11');
        System.AssertEquals(retorno[0].telefone, '932761946');
    }


    @isTest
    public static void IdentificarClienteTestError(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(404);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input aa = new IdentificaClienteChatHelper.Input();
        aa.RoutableId = lct.Id;
        aa.idEmpresa = '1';
        aa.unidadeNegocio = 'CSF';
        listInput.add(aa);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, Status__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identifica Cliente' LIMIT 1];
        System.AssertEquals('25600049765', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);
        System.AssertEquals('404', log.Status__c);

        System.AssertEquals(retorno[0].StatusCodeApi, 404);
    }

    @isTest
    public static void IdentificarClienteContaExistente(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setBody('{"data":{"cliente":{"dadosSociais":[{"nomePrimeiro":"MARIANA","nomeMeio":"RAMOS","nomeUltimo":"REIS","nomeSocial":"","nomeCompleto":"MARIANA RAMOS REIS","dataDeNascimento":"1981-06-22T03:00:00Z","nomeMae":"DORALICE FLORES OLIVEIRA","genero":"M","numeroConta":"37000113748"}],"contaCartao":{"contratos":[{"valorLimiteTotal":50000,"valorLimiteDisponivel":48500.68,"numeroContaSerno":"813268","cartoes":[{"id":"894928","numeroCartao":"5300.XXXX.XXXX.9402","statusCartao":"NORM","ehPrimario":true}],"numeroConta":"37000113748","unidadeNegocio":"CSF","dataAberturaConta":"2023-08-04","statusConta":"NORM"}]},"contato":{"dadosContato":[{"numeroConta":"37000113748","telefones":[{"ddd":"19","numero":"994268795","celularSeguro":false},{"ddd":"11","numero":"33334444","celularSeguro":false},{"ddd":"11","numero":"44443333","celularSeguro":false},{"ddd":"11","numero":"932761946","celularSeguro":true}],"emails":[{"endereco":"teste@gmail.com"}]}]},"cpf":"98390073277"}}}');
        responseIdentifica.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChaveContaFinanceira__c = '37000113748';
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input inputDados = new IdentificaClienteChatHelper.Input();
        inputDados.RoutableId = lct.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Identifica Cliente' LIMIT 1];
        System.AssertEquals('98390073277', log.CPF__c);
        System.AssertEquals('POST', log.Metodo__c);

        System.AssertEquals(retorno[0].ClienteIdentificado, true);
        System.AssertEquals(retorno[0].CpfCliente, '98390073277');
        System.AssertEquals(retorno[0].Email, 'teste@gmail.com');
        System.AssertEquals(retorno[0].EmailMascarado, 'tes**@gmail.com');
        System.AssertEquals(retorno[0].IdCartaoPrimario, '894928');
        System.AssertEquals(retorno[0].PrimeiroNome, 'MARIANA');
        System.AssertEquals(retorno[0].StatusCodeApi, 200);
        System.AssertEquals(retorno[0].TemCelularSeguro, true);
        System.AssertEquals(retorno[0].NumeroCelularSeguro, '(**) *****-1946');
        System.AssertEquals(retorno[0].LimiteTotal, 'R$ 50.000,00');
        System.AssertEquals(retorno[0].LimiteDisponivel, 'R$ 48.500,68');
        System.AssertEquals(retorno[0].nomeMae, 'DORALICE FLORES OLIVEIRA');
        System.AssertEquals(retorno[0].genero, 'M');
        System.AssertEquals(retorno[0].ddd, '11');
        System.AssertEquals(retorno[0].telefone, '932761946');
    }

    @isTest
    public static void sobrenomeVazioTest(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setBody('{"data":{"cliente":{"dadosSociais":[{"nomePrimeiro":"MARIANA","nomeMeio":"","nomeUltimo":"","nomeSocial":"","nomeCompleto":"MARIANA RAMOS REIS","dataDeNascimento":"1981-06-22T03:00:00Z","nomeMae":"DORALICE FLORES OLIVEIRA","genero":"M","numeroConta":"37000113748"}],"contaCartao":{"contratos":[{"valorLimiteTotal":50000,"valorLimiteDisponivel":48500.68,"numeroContaSerno":"813268","cartoes":[{"id":"894928","numeroCartao":"5300.XXXX.XXXX.9402","statusCartao":"NORM","ehPrimario":true}],"numeroConta":"37000113748","unidadeNegocio":"CSF","dataAberturaConta":"2023-08-04","statusConta":"NORM"}]},"contato":{"dadosContato":[{"numeroConta":"37000113748","telefones":[{"ddd":"19","numero":"994268795","celularSeguro":false},{"ddd":"11","numero":"33334444","celularSeguro":false},{"ddd":"11","numero":"44443333","celularSeguro":false},{"ddd":"11","numero":"932761946","celularSeguro":true}],"emails":[{"endereco":"teste@gmail.com"}]}]},"cpf":"98390073277"}}}');
        responseIdentifica.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChaveContaFinanceira__c = '37000113748';
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input inputDados = new IdentificaClienteChatHelper.Input();
        inputDados.RoutableId = lct.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        Account result = [SELECT Id, FirstName, LastName FROM Account WHERE CPF__c = '98390073277' LIMIT 1];

        Assert.areEqual('MARIANA', result.FirstName);
        Assert.areEqual('RAMOS REIS', result.LastName);
    }

     @isTest
    public static void nomeMeioNuloTest(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setBody('{"data":{"cliente":{"dadosSociais":[{"nomePrimeiro":"MARIANA RAMOS","nomeUltimo":"REIS","nomeSocial":"","nomeCompleto":"MARIANA RAMOS REIS","dataDeNascimento":"1981-06-22T03:00:00Z","nomeMae":"DORALICE FLORES OLIVEIRA","genero":"M","numeroConta":"37000113748"}],"contaCartao":{"contratos":[{"valorLimiteTotal":50000,"valorLimiteDisponivel":48500.68,"numeroContaSerno":"813268","cartoes":[{"id":"894928","numeroCartao":"5300.XXXX.XXXX.9402","statusCartao":"NORM","ehPrimario":true}],"numeroConta":"37000113748","unidadeNegocio":"CSF","dataAberturaConta":"2023-08-04","statusConta":"NORM"}]},"contato":{"dadosContato":[{"numeroConta":"37000113748","telefones":[{"ddd":"19","numero":"994268795","celularSeguro":false},{"ddd":"11","numero":"33334444","celularSeguro":false},{"ddd":"11","numero":"44443333","celularSeguro":false},{"ddd":"11","numero":"932761946","celularSeguro":true}],"emails":[{"endereco":"teste@gmail.com"}]}]},"cpf":"98390073277"}}}');
        responseIdentifica.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        //insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChaveContaFinanceira__c = '37000113748';
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input inputDados = new IdentificaClienteChatHelper.Input();
        inputDados.RoutableId = lct.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        Account result = [SELECT Id, FirstName, LastName FROM Account WHERE CPF__c = '98390073277' LIMIT 1];

        Assert.areEqual('MARIANA', result.FirstName);
        Assert.areEqual('RAMOS REIS', result.LastName);
    }

    @isTest
    public static void verificarRetornoCartoesWCNP(){
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setBody('{ "data":{ "cliente":{ "dadosSociais":[ { "nomePrimeiro":"RODRIGO", "nomeMeio":"CARDOSO", "nomeUltimo":"CASTRO", "nomeSocial":"", "dataDeNascimento":"1979-09-01T03:00:00Z", "nomeMae":"LINDA CARDOSO CASTRO", "genero":"M", "nomeCompleto":"RODRIGO CARDOSO CASTRO", "numeroConta":"37000062127", "tipoEnvioFatura":"1" } ], "contaCartao":{ "contratos":[ { "valorLimiteTotal":50000, "valorLimiteDisponivel":0, "numeroContaSerno":"865814", "statusGeralCartaoPrimario":"NORM", "classificacaoStatusConta":0, "aumentoAutomaticoDeLimite":true, "cartoes":[ { "dataAtivacao":"2029-06-09T03:00:00.000Z", "nomeCartao":"RODRIGO C CASTRO", "nomeProduto":"MC HIBRIDO GOLD BASICO I", "idProduto":"10", "tipoCartao":"C", "bandeira":"MASTERCARD", "id":"944286", "numeroCartao":"5300.XXXX.XXXX.0689", "numeroCartaoCompleto":"5300332814720689", "statusCartao":"WCNP", "tipoTitularidade":"TITULAR", "nomePortador":"RODRIGO CARDOSO CASTRO", "ehPrimario":true, "ehAtivo":true, "ehVirtual":false }, { "dataAtivacao":"0001-01-02T00:00:00.000Z", "nomeCartao":"CARLA CASTRO", "nomeProduto":"MC HIBRIDO GOLD BASICO I", "idProduto":"10", "tipoCartao":"C", "bandeira":"MASTERCARD", "id":"955604", "numeroCartao":"5300.XXXX.XXXX.7861", "numeroCartaoCompleto":"5300332902547861", "statusCartao":"WCNP", "tipoTitularidade":"DEPENDENTE", "nomePortador":"CARLA CASTRO", "ehPrimario":false, "ehAtivo":false, "ehVirtual":false } ], "numeroConta":"37000062127", "unidadeNegocio":"CSF", "dataAberturaConta":"2026-06-23", "statusConta":"NORM" } ] }, "contato":{ "dadosContato":[ { "numeroConta":"37000062127", "telefones":[ { "ddd":"19", "numero":"994268795", "celularSeguro":false }, { "ddd":"11", "numero":"33334444", "celularSeguro":false }, { "ddd":"11", "numero":"44443333", "celularSeguro":false }, { "ddd":"11", "numero":"943732861", "celularSeguro":true } ], "emails":[ { "endereco":"teste@gmail.com" } ] } ] }, "cpf":"87031354463" } } }');
        responseIdentifica.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/salesforce/clientes/identificacao/chat' => responseIdentifica
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ChaveContaFinanceira__c = '37000062127';
        lct.Token__c = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIzZWEwMWYzYS0xZjdmLTQ2NjUtYjNhNi02ZjFmMzY2ZDRjYmQiLCJleHAiOjE2OTUzMzkxNjksIm5iZiI6MCwiaWF0IjoxNjk1MzM3MzY5LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6MjU2MDAwNDk3NjUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjEyOWViYWFjLTZmNzgtNDVjNi05ZWQ2LTZiNjEyZjM4OGUyOSIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6IjI1NjAwMDQ5NzY1IiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiMjU2MDAwNDk3NjUiLCJlbWFpbCI6IjI1NjAwMDQ5NzY1In0.XL62Yf5I3bqxuFfJ8WPi23MJSUHkqSQfH8IdOGjquXFoH4a1BnIr9aQXMvqjsg5tpAIksWTMqLqhDCuPuU5yiqtxERDdMFNCdKIaMgsjdut0tlXCOWan1wew8X25iv_2Q5yMTB5fjRldRQnKYEco4sviMwEFYgmsd0pd9LvqTQyVa996JMzGqofxE-PoEFUVPSqe8PywKsx6qGviBfz8ij2tHzQwQFqmQ4wo5uSeJUEgaHuXOsb0bYB0UHuNNOKpflOrgfqQi6sEBzWl7eNwUCBZvyfax7ovGfuUNiKexJm06z3TZFzBgR5QZDWiAmyGGuo8zmtRH1RTObVgPe72sA';
        insert lct;

        List<IdentificaClienteChatHelper.Input> listInput = new List<IdentificaClienteChatHelper.Input>();
        IdentificaClienteChatHelper.Input inputDados = new IdentificaClienteChatHelper.Input();
        inputDados.RoutableId = lct.Id;
        inputDados.idEmpresa = '1';
        inputDados.unidadeNegocio = 'CSF';
        listInput.add(inputDados);

        Test.StartTest();
        List<IdentificaClienteChatHelper.Output> retorno = IdentificaClienteChatHelper.IdentificarCliente(listInput);
        Test.StopTest();

        Assert.areEqual('944286,955604', retorno[0].idCartoesBloqueadosLst);
    }
}