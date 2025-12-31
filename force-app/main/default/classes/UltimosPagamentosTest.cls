/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - UltimosPagamentos              95%                                  *
*    - ServerToServerServices       100%                                 *
*    - UltimosLancamentos           100%                                 *
**************************************************************************/
@isTest
public class UltimosPagamentosTest {
    @isTest
    public static void GetUltimosPagamentosSemLancamentos(){
        HttpResponse response = new HttpResponse();
        response.setHeader('cpf', '37871490079');
        response.setHeader('Authorization', 'Bearer TokenExemplo');
        response.setBody('[{"data": "2029-01-10T00:00:00","valor": {"valor": 1000,"moeda": "R$"},"numeroCartao": "5438821484883897","descricaoLancamento": {"parcelamentoSerno": 0,"idLancamento": "10002128154","origMsgType": "TXIN","reasonCode": "1010","msgType": "0420","procCode": "000000","valor": {"valor": 1000,"moeda": "R$"},"descricao": "ESTORNO","glTrxnTypeSerno": 3532,"postingDate": "2029-01-10","tipoPagamento": "Pagamento"},"agrupamentoLancamentos": [],"descricao": "ESTORNO","descricaoGrupo": null,"chaveParticaoTransacao": "1029031","detalheLancamentoParcela": {"quantidadeParcelas": null,"numeroParcelaTransacao": null,"parcelamentoSerno": 0,"parcelaIndice": 0,"parcelamentoPartitionKey": 0}}]');
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/api/v1.0/contas/37000076291/faturas/aberta/lancamentos' => response
        };
        
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
    
        
        List<UltimosPagamentos.InputUltimosPagamentos> requestList  = new List<UltimosPagamentos.InputUltimosPagamentos>();
        UltimosPagamentos.InputUltimosPagamentos request = new UltimosPagamentos.InputUltimosPagamentos();   
        request.NumeroConta = '37000076291';
        request.unidadeNegocio = '1';
        request.CPF = '37871490079 ';
        request.canal = 'chat';
        request.Token = '12345678914';
        requestList.add(request);
        
        Test.StartTest();
        List<UltimosPagamentos.OutputUltimosPagamentos> retornoList = UltimosPagamentos.GetUltimosPagamentos(requestList);
        Test.StopTest();
        
        UltimosPagamentos.OutputUltimosPagamentos retorno = retornoList[0];
        System.AssertEquals('SEM LANCAMENTOS', retorno.StatusAPI);
    }

    @isTest
    public static void GetUltimosPagamentosComLancamentos(){
        HttpResponse response = new HttpResponse();
        response.setHeader('cpf', '52123530506');
        response.setHeader('Authorization', 'Bearer TokenExemplo');
        response.setBody('[{"data":"2029-02-11T00:00:00","valor":{"valor":-50,"moeda":"R$"},"numeroCartao":"5438821062233432","descricaoLancamento":{"parcelamentoSerno":0,"idLancamento":"10002183488","origMsgType":"ISOM","reasonCode":"","msgType":"0220","procCode":"000000","valor":{"valor":-50,"moeda":"R$"},"descricao":"Transacao Manual","glTrxnTypeSerno":3520,"postingDate":"2029-02-11","tipoPagamento":"Compra"},"agrupamentoLancamentos":[],"descricao":"Transacao Manual","descricaoGrupo":null,"chaveParticaoTransacao":"1029059","detalheLancamentoParcela":{"quantidadeParcelas":null,"numeroParcelaTransacao":null,"parcelamentoSerno":0,"parcelaIndice":0,"parcelamentoPartitionKey":0}},{"data":"2029-02-11T00:00:00","valor":{"valor":1401.78,"moeda":"R$"},"numeroCartao":"5438821062233432","descricaoLancamento":{"parcelamentoSerno":0,"idLancamento":"10002183188","origMsgType":"PAYMT","reasonCode":"ppix","msgType":"0220","procCode":"230000","valor":{"valor":1401.78,"moeda":"R$"},"descricao":"Pagamento de Fatura via PIX","glTrxnTypeSerno":119097,"postingDate":"2029-02-11","tipoPagamento":"Pagamento"},"agrupamentoLancamentos":[],"descricao":"Pagamento de Fatura via PIX","descricaoGrupo":null,"chaveParticaoTransacao":"1029059","detalheLancamentoParcela":{"quantidadeParcelas":null,"numeroParcelaTransacao":null,"parcelamentoSerno":0,"parcelaIndice":0,"parcelamentoPartitionKey":0}},{"data":"2029-02-11T00:00:00","valor":{"valor":1000,"moeda":"R$"},"numeroCartao":"5438821062233432","descricaoLancamento":{"parcelamentoSerno":0,"idLancamento":"10002181929","origMsgType":"TXIN","reasonCode":"1010","msgType":"0420","procCode":"000000","valor":{"valor":1000,"moeda":"R$"},"descricao":"ESTORNO","glTrxnTypeSerno":3532,"postingDate":"2029-02-11","tipoPagamento":"Pagamento"},"agrupamentoLancamentos":[],"descricao":"ESTORNO","descricaoGrupo":null,"chaveParticaoTransacao":"1029059","detalheLancamentoParcela":{"quantidadeParcelas":null,"numeroParcelaTransacao":null,"parcelamentoSerno":0,"parcelaIndice":0,"parcelamentoPartitionKey":0}},{"data":"2029-02-11T00:00:00","valor":{"valor":-1000,"moeda":"R$"},"numeroCartao":"5438821062233432","descricaoLancamento":{"parcelamentoSerno":0,"idLancamento":"10002181926","origMsgType":"TXIN","reasonCode":"1010","msgType":"0220","procCode":"000000","valor":{"valor":-1000,"moeda":"R$"},"descricao":"ATC","glTrxnTypeSerno":3520,"postingDate":"2029-02-11","tipoPagamento":"Compra"},"agrupamentoLancamentos":[],"descricao":"ATC","descricaoGrupo":null,"chaveParticaoTransacao":"1029059","detalheLancamentoParcela":{"quantidadeParcelas":null,"numeroParcelaTransacao":null,"parcelamentoSerno":0,"parcelaIndice":0,"parcelamentoPartitionKey":0}}]');
        response.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/api/v1.0/contas/10000059781/faturas/aberta/lancamentos' => response
        };
        
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
    
        
        List<UltimosPagamentos.InputUltimosPagamentos> requestList  = new List<UltimosPagamentos.InputUltimosPagamentos>();
        UltimosPagamentos.InputUltimosPagamentos request = new UltimosPagamentos.InputUltimosPagamentos();   
        request.NumeroConta = '10000059781';
        request.unidadeNegocio = '1';
        request.CPF = '52123530506';
        request.canal = 'chat';
        request.Token = '12345678914';
        requestList.add(request);
        
        Test.StartTest();
        List<UltimosPagamentos.OutputUltimosPagamentos> retornoList = UltimosPagamentos.GetUltimosPagamentos(requestList);
        Test.StopTest();
        
        UltimosPagamentos.OutputUltimosPagamentos retorno = retornoList[0];
        System.AssertEquals('OK', retorno.StatusAPI);
    }

    @isTest
    public static void GetUltimosPagamentosErro(){
        HttpResponse response = new HttpResponse();
        response.setHeader('cpf', '52123530506');
        response.setHeader('Authorization', 'Bearer TokenExemplo');
        response.setBody('[{"data": "2029-01-10T00:00:00","valor": {"valor": ,"moeda": ""},"numeroCartao": "","descricaoLancamento": {"parcelamentoSerno": 0,"idLancamento": "","origMsgType": "","reasonCode": "","msgType": "","procCode": "","valor": {"valor": ,"moeda": ""},"descricao": "","glTrxnTypeSerno": ,"postingDate": "","tipoPagamento": ""},"agrupamentoLancamentos": [],"descricao": "","descricaoGrupo": ,"chaveParticaoTransacao": "","detalheLancamentoParcela": {"quantidadeParcelas": ,"numeroParcelaTransacao": ,"parcelamentoSerno": ,"parcelaIndice": ,"parcelamentoPartitionKey":}}]');
        response.setStatusCode(404);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/api/v1.0/contas/10000059781/faturas/aberta/lancamentos' => response
        };
        
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
    
        
        List<UltimosPagamentos.InputUltimosPagamentos> requestList  = new List<UltimosPagamentos.InputUltimosPagamentos>();
        UltimosPagamentos.InputUltimosPagamentos request = new UltimosPagamentos.InputUltimosPagamentos();   
        request.NumeroConta = '10000059781';
        request.unidadeNegocio = '1';
        request.CPF = '52123530506';
        request.canal = 'chat';
        request.Token = '12345678914';
        requestList.add(request);
        
        Test.StartTest();
        List<UltimosPagamentos.OutputUltimosPagamentos> retornoList = UltimosPagamentos.GetUltimosPagamentos(requestList);
        Test.StopTest();
        
        UltimosPagamentos.OutputUltimosPagamentos retorno = retornoList[0];
        System.AssertEquals('ERROR', retorno.StatusAPI);
    }
}