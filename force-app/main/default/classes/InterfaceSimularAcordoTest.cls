/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - InterfaceSimularAcordo                            100%            *
*    - InterfaceSimularAcordoChat                            100%            *
**************************************************************************/

@isTest
public class InterfaceSimularAcordoTest {

    @isTest
    public static void SimularAcordoTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseSimularAcordo= new HttpResponse();
        responseSimularAcordo.setStatusCode(200);
        responseSimularAcordo.setBody('{"planoParcelamentoParceirosDto": [{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=","valorDeDesconto": 33.8,"percentualDesconto": 88,"valorParcela": 36.63,"quantidadeParcelas": 1},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 6.09,"quantidadeParcelas": 9},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.49,"quantidadeParcelas": 10},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.01,"quantidadeParcelas": 11},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 4.6,"quantidadeParcelas": 12},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3","valorDeDesconto": 61.97,"percentualDesconto": 78,"valorParcela": 5.12,"quantidadeParcelas": 13}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/acordo/simular' => responseSimularAcordo 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceSimularAcordoDivida.RequestSimularAcordo requestSimularAcordo = new InterfaceSimularAcordoDivida.RequestSimularAcordo();   
        requestSimularAcordo.identificadorAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==';
        requestSimularAcordo.vencimentoPrimeiraParcela = '12/09/2023';
        requestSimularAcordo.quantidadeParcelas = 10;
        requestSimularAcordo.idEmpresa = '1';
        requestSimularAcordo.cpf = '09933770764';
        requestSimularAcordo.canal = 'chat';

        List<InterfaceSimularAcordoDivida.RequestSimularAcordo> requestAcordoList = new List<InterfaceSimularAcordoDivida.RequestSimularAcordo>();
        requestAcordoList.add(requestSimularAcordo);
        
        Test.StartTest();
        List<InterfaceSimularAcordoDivida.ResponseSimularAcordo> retornoSimular = InterfaceSimularAcordoDivida.SimularAcordo(requestAcordoList);
        Test.StopTest();
        
        InterfaceSimularAcordoDivida.ResponseSimularAcordo retorno = retornoSimular[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(6, retorno.numeroOpcoesDisponiveis);
    }
    
    @isTest
    public static void SimularAcordoParcelaAVistaTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseSimularAcordo= new HttpResponse();
        responseSimularAcordo.setStatusCode(200);
        responseSimularAcordo.setBody('{"planoParcelamentoParceirosDto":[{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmicwuWXr7TcuwsBdf9K1l+U=","valorDeDesconto":1413.15,"percentualDesconto":73,"valorParcela":1413.15,"quantidadeParcelas":1},{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmtEqFHi4WA+oKrb/VAW/7lo=","valorDeDesconto":1739.26,"percentualDesconto":67,"valorParcela":124.23,"quantidadeParcelas":14},{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmm8KrnG0wDJaoUD3zlppbvI=","valorDeDesconto":1739.26,"percentualDesconto":67,"valorParcela":115.95,"quantidadeParcelas":15},{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmqm4LoVHvHD68RHNauSp0Oc=","valorDeDesconto":1739.26,"percentualDesconto":67,"valorParcela":108.7,"quantidadeParcelas":16},{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmu1h1LSvN7p4LH63u4FrLzw=","valorDeDesconto":1739.26,"percentualDesconto":67,"valorParcela":102.3,"quantidadeParcelas":17},{"identificador":"Za6KfBh6m2QOCOzjjLWTX5dkqAykJQBU1cJ4p9pMThz2vB8WebZiUjFkXu9krmSAqExjJCltovnRBWq62o3vmt3shnhbafvAZ/zhwI+k5VM=","valorDeDesconto":1739.26,"percentualDesconto":67,"valorParcela":96.62,"quantidadeParcelas":18}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/acordo/simular' => responseSimularAcordo 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceSimularAcordoDivida.RequestSimularAcordo requestSimularAcordo = new InterfaceSimularAcordoDivida.RequestSimularAcordo();   
        requestSimularAcordo.identificadorAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==';
        requestSimularAcordo.vencimentoPrimeiraParcela = '12/09/2023';
        requestSimularAcordo.quantidadeParcelas = 1;
        requestSimularAcordo.idEmpresa = '1';
        requestSimularAcordo.cpf = '09933770764';
        requestSimularAcordo.canal = 'chat';

        List<InterfaceSimularAcordoDivida.RequestSimularAcordo> requestAcordoList = new List<InterfaceSimularAcordoDivida.RequestSimularAcordo>();
        requestAcordoList.add(requestSimularAcordo);
        
        Test.StartTest();
        List<InterfaceSimularAcordoDivida.ResponseSimularAcordo> retornoSimular = InterfaceSimularAcordoDivida.SimularAcordo(requestAcordoList);
        Test.StopTest();
        
        InterfaceSimularAcordoDivida.ResponseSimularAcordo retorno = retornoSimular[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(6, retorno.numeroOpcoesDisponiveis);
    }

    @isTest
    public static void SimularAcordoChatTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseSimularAcordo= new HttpResponse();
        responseSimularAcordo.setStatusCode(200);
        responseSimularAcordo.setBody('{"planoParcelamentoParceirosDto": [{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRzQLdyp+1cdgAM1G/AACDgM=","valorDeDesconto": 33.8,"percentualDesconto": 88,"valorParcela": 36.63,"quantidadeParcelas": 1},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwbYQqmQ7za+P0BplEVl3U8=","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 6.09,"quantidadeParcelas": 9},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRx/JoeFDTpRUZUtYUXaElMdE36OGzz7wnw3ws2gVS1K3","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.49,"quantidadeParcelas": 10},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRw/UkwYv/dxvKhQCgJ8p94QcVFcYTcNjpiErvTbsk2q5","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 5.01,"quantidadeParcelas": 11},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoRwBtLmsCz6Vx3u4Q3q1JLnWdpaKeQzRbNUouhUWo9nid","valorDeDesconto": 50.71,"percentualDesconto": 82,"valorParcela": 4.6,"quantidadeParcelas": 12},{"identificador": "QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9cEpcVVZbo3MHO90oOgqoR7TZtE84E3HefqGknsyQ2lRTq57ZKSqNqgpwF6C0EWb3","valorDeDesconto": 61.97,"percentualDesconto": 78,"valorParcela": 5.12,"quantidadeParcelas": 13}]}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/csf-servicos' => responseServerToServer, 
                'api/v1/parceiros/acordo/simular' => responseSimularAcordo 
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        InterfaceSimularAcordoDividaChat.RequestSimularAcordo requestSimularAcordo = new InterfaceSimularAcordoDividaChat.RequestSimularAcordo();   
        requestSimularAcordo.identificadorAcordo = 'QpvI1FDWhOtZZvi7FUyfIGt/m0K8kzIxpRGEjQy/81VzWe+pb9JWnP+ScvVyYrk9icxtN0qTioSHfraBQ5WbHw==';
        requestSimularAcordo.vencimentoPrimeiraParcela = '12/09/2023';
        requestSimularAcordo.quantidadeParcelas = 10;
        requestSimularAcordo.idEmpresa = '1';
        requestSimularAcordo.cpf = '09933770764';
        requestSimularAcordo.canal = 'chat';

        List<InterfaceSimularAcordoDividaChat.RequestSimularAcordo> requestAcordoList = new List<InterfaceSimularAcordoDividaChat.RequestSimularAcordo>();
        requestAcordoList.add(requestSimularAcordo);
        
        Test.StartTest();
        List<InterfaceSimularAcordoDividaChat.ResponseSimularAcordo> retornoSimular = InterfaceSimularAcordoDividaChat.SimularAcordo(requestAcordoList);
        Test.StopTest();
        
        InterfaceSimularAcordoDividaChat.ResponseSimularAcordo retorno = retornoSimular[0];
        System.AssertEquals('OK', retorno.statusRetorno);
        System.AssertEquals(6, retorno.numeroOpcoesDisponiveis);
    }
}