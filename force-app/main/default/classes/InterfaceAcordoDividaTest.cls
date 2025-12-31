/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceAcordoDivida                             100%            *
**************************************************************************/

@isTest
public class InterfaceAcordoDividaTest {
    @isTest
    public static void ConsultarSituacaoAcordoDividaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"situacao": {"codigo": 2,"descricao": "Cliente possui dívida"},"infosCliente": {"possuiEmail": true},"divida": {"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==","cpf": "08827626808","valor": 293.49,"dataEnquadramento": "2021-04-30T00:00:00"},"referenciaEmpresa": "001"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '79413706387';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusRetorno);
        System.AssertEquals('TRUE', retorno.get(0).possuiEmail);
        System.AssertEquals('QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==', retorno.get(0).identificadorAcordo);
        System.AssertEquals('R$293,49', retorno.get(0).valorDivida);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(200);
        responseConsultar.setBody('{"situacao": {"codigo": 3,"descricao": "Cliente possui acordo"},"infosCliente": {"possuiEmail": true},"contratos": [{"numeroContrato": "00000098103","nomeProduto": "MC INTL","acordos": [{"numeroAcordoAtual": "13932161","dataNegociacao": "2023-02-14T00:00:00","valorTotalDivida": 40376.78,"valorIOF": 0,"valorDesconto": 37308.63,"valorFinalAcordo": 3068.15,"numeroParcela": 30,"valorEntrada": 102.27,"valorDemaisParcelas": 102.27,"percentualDesconto": 92.40,"parcelas": [{"dataVencimento": "2023-06-14T00:00:00","numeroParcela": 0,"pagamentoEmProcessamento": 78,"statusEnum": 80,"valorParcela": 102.27,"linhaDigitavel": "","status": "Paga"},{"dataVencimento": "2023-07-01T00:00:00","numeroParcela": 1,"pagamentoEmProcessamento": 78,"statusEnum": 83,"valorParcela": 102.27,"linhaDigitavel": "36890.00101  93509.147661  08002.000209  8  93820000010227","copiaCola": "00020101021226970014br.gov.bcb.pix2575qr-h.cornerpix.com.br/08357240/v2/cobv/1f34d4ee-1978-454a-8e6d-df87d2b3f6125204000053039865802BR5903CSF6009SAO PAULO62070503***63049DA0","status": "A Pagar"},{"dataVencimento": "2023-08-01T00:00:00","numeroParcela": 2,"pagamentoEmProcessamento": 78,"statusEnum": 83,"valorParcela": 102.27,"linhaDigitavel": "","status": "A Pagar"}],"identificadorAcordo":"jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes="}],"status": "Ativo"}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '79413706387';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusRetorno);
        System.AssertEquals('29', retorno.get(0).numeroParcelaRestantes);
        System.AssertEquals('R$102,27', retorno.get(0).valorParcela);
        System.AssertEquals('01/07', retorno.get(0).diaVencimentoAtual);
        System.AssertEquals('VENCIDO', retorno.get(0).statusParcela);
        System.AssertEquals('3', retorno.get(0).situacaoCliente);
        System.AssertEquals('01/08', retorno.get(0).dataVencimentoProxParcela);
        
        System.AssertEquals('00020101021226970014br.gov.bcb.pix2575qr-h.cornerpix.com.br/08357240/v2/cobv/1f34d4ee-1978-454a-8e6d-df87d2b3f6125204000053039865802BR5903CSF6009SAO PAULO62070503***63049DA0', retorno.get(0).pix);
        System.AssertEquals('36890.00101  93509.147661  08002.000209  8  93820000010227', retorno.get(0).linhaDigitavel);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoEmDiaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(200);
        
        String body = '{"situacao": {"codigo": 3,"descricao": "Cliente possui acordo"},"infosCliente": {"possuiEmail": true},"contratos": [{"numeroContrato": "00000098103","nomeProduto": "MC INTL","acordos": [{"numeroAcordoAtual": "13932161","dataNegociacao": "2023-02-14T00:00:00","valorTotalDivida": 40376.7,"valorIOF": 0,"valorDesconto": 37308.6,"valorFinalAcordo": 3068.15,"numeroParcela": 30,"valorEntrada": 102.2,"valorDemaisParcelas": 102.2,"percentualDesconto": 92.40,"parcelas": [{"dataVencimento": "2023-06-14T00:00:00","numeroParcela": 0,"pagamentoEmProcessamento": 78,"statusEnum": 80,"valorParcela": 102.2,"linhaDigitavel": "","status": "Paga"},{"dataVencimento": "DATA-ATUALIZADA","numeroParcela": 1,"pagamentoEmProcessamento": 78,"statusEnum": 83,"valorParcela": 102.2,"linhaDigitavel": "36890.00101  93509.147661  08002.000209  8  93820000010227","copiaCola": "00020101021226970014br.gov.bcb.pix2575qr-h.cornerpix.com.br/08357240/v2/cobv/1f34d4ee-1978-454a-8e6d-df87d2b3f6125204000053039865802BR5903CSF6009SAO PAULO62070503***63049DA0","status": "A Pagar"},{"dataVencimento": "2023-10-01T00:00:00","numeroParcela": 2,"pagamentoEmProcessamento": 78,"statusEnum": 83,"valorParcela": 102.2,"linhaDigitavel": "","status": "A Pagar"}],"identificadorAcordo":"jjsWl6poL1v5jflxQ137LpFnNkmONQKGt3UZP0AIhbqOpP6MpwfVnXk36rdV2KvsZWCXeIqxkfFBRx2zhmTo+5PIrg3NAx/oWZJZMvwbNes="}],"status": "Ativo"}]}';
        body = body.replace('DATA-ATUALIZADA', Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() + 'T00:00:00');
        responseConsultar.setBody(body);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '79413706387';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        String diaVencimentoAtual = Util.formatDDMM(Date.today().day(), Date.today().month(), '/');
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusRetorno);
        System.AssertEquals('29', retorno.get(0).numeroParcelaRestantes);
        System.AssertEquals('R$102,20', retorno.get(0).valorParcela);
        System.AssertEquals(diaVencimentoAtual, retorno.get(0).diaVencimentoAtual);
        System.AssertEquals('EM DIA', retorno.get(0).statusParcela);
        System.AssertEquals('3', retorno.get(0).situacaoCliente);
        System.AssertEquals('01/10', retorno.get(0).dataVencimentoProxParcela);
        
        System.AssertEquals('00020101021226970014br.gov.bcb.pix2575qr-h.cornerpix.com.br/08357240/v2/cobv/1f34d4ee-1978-454a-8e6d-df87d2b3f6125204000053039865802BR5903CSF6009SAO PAULO62070503***63049DA0', retorno.get(0).pix);
        System.AssertEquals('36890.00101  93509.147661  08002.000209  8  93820000010227', retorno.get(0).linhaDigitavel);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoSemParcelasTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(200);
        
        String body = '{"situacao": {"codigo": 3,"descricao": "Cliente possui acordo"},"infosCliente": {"possuiEmail": true},"referenciaEmpresa": "001", "contratos": [{"numeroContrato": "66981195770","nomeProduto": "MC GOLD","acordos": [{"numeroAcordoAtual": "15300005","dataNegociacao": "2023-08-03T16:03:24","valorTotalDivida": 4932.32,"valorIOF": 45.06,"valorDesconto": 0,"valorFinalAcordo": 4977.38,"numeroParcela": 1,"valorEntrada": 4977.38,"valorDemaisParcelas": 4977.38,"percentualDesconto": 0,"parcelas": [{"dataVencimento": "2023-08-18T03:00:00","numeroParcela": 0,"pagamentoEmProcessamento": 83,"statusEnum": 80,"valorParcela": 4977.38,"linhaDigitavel": "36890.00101  93513.231519  75002.000208  6  00000000497738","qrCode":"iVBORw0KGgoAAAANSUhEUgAAAhIAAAISAQAAAACxRhsSAAAE70lEQVR4nO2dXYrrOBCFT40MebThLqCXYu/gLin0ku4O7KVkAQ3yY8DmzIN+4+6ZHriJbiYcPYTEkT8sKEqlo1LZiN9ty1+/jQDEEEMMMcQQQwwxxBCjMCy2Lly0KVzrgGXYzSbsFv5ZBsCmNfWf7vwcYojxD40kiZEk6R0xckP6IAG4tNLqGf4lvWN12/wsYxHj9Rlr9I58tw58HxyB1Qwjr5asE+Cc7ivO9/nGIsbrM2zqN2C8RCPk++DIeT0xhQExKnj0c4ghRt26w28COwz91bAMbjPAgPEXQKyDEevxhjs9hxhi/BdGT3IGYBMcSQ9g9MhB6m5Y3nJACoDk9ojnEEOMf2EsZmY2AMDawab1lFZPwYE62vnSwaa1g03Yw3L//s8hhhhfNx7a3G/g3G8A4Bj9aVrqp2+3dzzLWMR4XUbUpQDkiT5KUmHyD39wA2dE1aqYsuxUjEaMpJ96R6DPIWcfZdJaMPUuyqkxSHXyp2K0YiR/mtZRYcofvWN0oL6opvFnuU12KkYjRuVPOfc5PgXS9B6sM/rTNPnfBKmyUzEezkgxJlzwp8GBxrZV3hZIXSpTlp2K0YZR22llsX1c2xetNHrbpK4WK5aditGKYWduYcvezn43IOinuwE9aROAoKSO3IDlbYNNJUHlucYixisyPvnT4Cx9ca8ActIU5z6JA3m3Sv5UjMczcgR6I0nNQEqQ6smiqRb9NEQFmvfFaMPI630gLZeAsqIHcJOTWiWhUvmnYjRjpLW9TzM7U65pNMK+bEAVfypdSoy2jKM/rWb74F7D9mhUUpN0lVOqZKdiNGGkdVSJT/PO6GF/PxpwiWPlT8VozLDz5ZRzo67GdzPDMiDnnwLVUitcW3WOT4zWjOXtalEh9Y52JhlOoOT8Uyx2IsbLidW1uz+HGGJ83ap11JgUqmp6j9fI0jmqAUVifZaxiPG6jM/66Rfxaejn63ypqp/sVIyHM7KL3KojTyVV6uBAiz3XW1bPMhYxXpdR5/OHn9n+gtn2RZJK6ajBOpUnLUY7Ro5P0xHS6mQJaiU15p8WTVX+VIw/xFi7UA8lLvo9AGA38tLBptxlBhAPpz7mOcQQ49BC2QgbZwLotw6A27D8/Oi4DC4EowY4EOtuRP9hALpUduJuzyGGGN8zOK9m8dR+UE3T+f3x0iEUmaqWUFT+qRhtGdGfAm4DcDWMfu8w+uQsl59bR8AxFpVYT+Ebl7er/KkYrRh5fz8rT+WPIESRJV+qfABa74vRjlEdcA4z+5gF05hpko5JlzyUKrlKdipGE0Ztp9H+siXittxZn3dLPaB9UzFaMrJqj1Sth7mKdJZJ69oTQJWnKjsVow0j6VLcO2AdAPQfHcYZwDjvMACG0e8ICX/oPzpgtRvGs4xFjNdlHOv1lQqnpTZf7OdzfMr6bJ/8qRitGPX7TsIxfRJjOMnfxXB1GRxtWlOXXB7l2cYixisyju87qdWoQ/1TX1IAysEp+VMxWjDqc3yxfkSpJnnomvNQAEiXEuOPMpZhN74PALJhVi+WwmpWi1iPew4xxKjap9eXjL9+bHGBH9reAXDgMnx0GP2PzQC3cTGXlNVnGYsYr8v4/D4+f1M5spzaD53zzpT0UzEaMm7z+d3n43opqT/t/uciqNrfF6Mdw/h9n2/a8ixjEUMMMcQQQwwxxBDj/8/4G6qnLjjkSgObAAAAAElFTkSuQmCC","copiaCola":"00020101021226970014br.gov.bcb.pix2575qr-h.cornerpix.com.br/08357240/v2/cobv/5c62b6be-bb1f-4b82-b0c6-4f6ec50d30655204000053039865802BR5903CSF6009SAO PAULO62070503***63040F48","status": "Concluido"}],"identificadorAcordo": "0bkLsEZWyTR+n+/t43faVDcOqR0rjhb1kF/2GLztigQ7Is73DeMkYUN9CiQbNoXU0dyqGGjpLu1GRvRwJyJKt4ry0SSdFT6ucF+JLCf4HfEhHq9ck4ROey3vbGL1Wpt6"}],"status": "Ativo"}]}';
        responseConsultar.setBody(body);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '09933770764';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusRetorno);
        System.AssertEquals('SEM PENDENTE', retorno.get(0).statusParcela);
    }
    
    @isTest
    public static void ConsultarSituacaoClienteInexistenteTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(422);
        responseConsultar.setBody('{"codigo": 302, "mensagem": "Situação do Cliente Inválida"}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '79413706387';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('OK', retorno.get(0).statusRetorno);
        System.AssertEquals('302', retorno.get(0).situacaoCliente);
    }
    
    @isTest
    public static void ConsultarSituacaoAcordoErroTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConsultar= new HttpResponse();
        responseConsultar.setStatusCode(500);
        responseConsultar.setBody('');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/divida' => responseConsultar
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceAcordoDivida.RequestConsultarSituacao requestConsultarSituacao = new InterfaceAcordoDivida.RequestConsultarSituacao();      
        requestConsultarSituacao.idEmpresa = '1';
        requestConsultarSituacao.cpf = '79413706387';
        requestConsultarSituacao.canal = 'chat';
        
        List<InterfaceAcordoDivida.RequestConsultarSituacao> requestAcordoList = new List<InterfaceAcordoDivida.RequestConsultarSituacao>();
        requestAcordoList.add(requestConsultarSituacao);
        
        Test.StartTest();
        List<InterfaceAcordoDivida.ResponseConsultarSituacao> retorno = InterfaceAcordoDivida.ConsultarSituacaoAcordo(requestAcordoList);
        Test.StopTest();
        
        System.AssertEquals(1, retorno.size());
        System.AssertEquals('ERRO', retorno.get(0).statusRetorno);
    }
}