/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceConfirmarAcordo                            100%          *
**************************************************************************/

@isTest
public class InterfaceConfirmarAcordoTest {

    @isTest
    public static void ConfirmarAcordoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseConfirmarAcordo= new HttpResponse();
        responseConfirmarAcordo.setStatusCode(200);
        responseConfirmarAcordo.setBody('{"codigoAcordo": "14032292","diaVencimentoDemaisParcelas": 30,"linhaDigitavel": "36890.00101  93509.148313  31002.000201  1  00000000110149","numeroContrato": "66989227674","parcelamentoEscolhido": {"valorDesconto": 2203.00,"percentualDesconto": 40.25,"valorParcela": 1101.49,"quantidadeParcelas": 2},"valorAcordo": 3686.81,"vencimentoPrimeiraParcela": "2023-06-30T00:00:00","identificador": "hq5jLIRDKbHufK6gNsVKBM3muK1/o0FWNtCZiYSefZrBRI6SmbaLwZqcQDno6dPGKO0t+i80IgLcGhwkjdyhtg=="}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/acordo/confirmar' => responseConfirmarAcordo 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceConfirmarAcordoDivida.RequestConfirmarAcordo requestConfirmarAcordo = new InterfaceConfirmarAcordoDivida.RequestConfirmarAcordo();   
        requestConfirmarAcordo.identificadorPlano = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==';
        requestConfirmarAcordo.canalAcordo = 'WHATSAPP';
        requestConfirmarAcordo.formaPagamento = '0';
        requestConfirmarAcordo.idEmpresa = '1';
        requestConfirmarAcordo.cpf = '09933770764';
        requestConfirmarAcordo.canal = 'chat';
        
        List<InterfaceConfirmarAcordoDivida.RequestConfirmarAcordo> requestConfirmarAcordoList = new List<InterfaceConfirmarAcordoDivida.RequestConfirmarAcordo>();
        requestConfirmarAcordoList.add(requestConfirmarAcordo);
        
        Test.StartTest();
        List<InterfaceConfirmarAcordoDivida.ResponseConfirmarAcordo> retornoConfirmar = InterfaceConfirmarAcordoDivida.ConfirmarAcordo(requestConfirmarAcordoList);
        Test.StopTest();
        
        InterfaceConfirmarAcordoDivida.ResponseConfirmarAcordo retorno = retornoConfirmar[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(null, retorno.pix);
        System.AssertEquals('36890.00101  93509.148313  31002.000201  1  00000000110149', retorno.linhaDigitavel);
        System.AssertEquals('hq5jLIRDKbHufK6gNsVKBM3muK1/o0FWNtCZiYSefZrBRI6SmbaLwZqcQDno6dPGKO0t+i80IgLcGhwkjdyhtg==', retorno.identificadorAcordo);

    }
    
}