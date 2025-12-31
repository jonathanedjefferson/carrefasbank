/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - Util                         100%                                 *
**************************************************************************/
@isTest
public class UtilTest {
    @isTest
    public static void executarHttpRequestPOSTTest(){
        Test.setMock(HttpCalloutMock.class, new ServerToServerHttpCalloutMock());
        
        Test.StartTest();
        HttpResponse response = Util.executarHttpRequest('String strEndPoint', 'POST', new Map<String, String>(), 'String strBody', 40000);
        Test.StopTest();
        
        String actualValue = response.getBody();
        String expectedValue = '{"access_token": "Tw6Ec4c2EKlOGSbP5IdTvQ9c4477yamofNFl1PiW_qX0sBBqiANalJTvh8107sSyCRgfpFr_5YNqWj_HGjY5Jl5h7ayl7tuBSdpWdr0IaJL7dvqj0zvuN8jOhafAWoVyW_rtsf_Iucnz4ymyrGEtW5_N3jYGm5t44qpzJymu2UzLH72zPTVjq0jJjaNdRh2ORvfvnLRMB7kwFSUlJe36y8R5nUES32057yxarPh6cKkXEuIK3F5Bx34TtWQvagxDFiaFl_GMsmDfslIqHbM8d3Hca8JBqII2GE1e231XySCy8Eic68u8cs4hhp96mKUptwHRqkl1nnmKp39ySqpP5Q","expires_in": 3600,"refresh_expires_in": 1800,"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIyMTdlODc3ZS0xNjQ4LTRjYzMtOWFjMi1jYzliNjM5MDNjYzcifQ.eyJqdGkiOiJhODNmZGFkOC1jOGNkLTQwMmMtYjI1Zi1mOGNiNzBlNzRkNzgiLCJleHAiOjE2NzYzMTE2MzgsIm5iZiI6MCwiaWF0IjoxNjc2MzA5ODM4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9jc2Ytc2VydmVyLXRvLXNlcnZlciIsImF1ZCI6Imh0dHBzOi8va2V5Y2xvYWstaG9tLmNzZmNwdi53Y29ycC5jYXJyZWZvdXIuY29tL2F1dGgvcmVhbG1zL2NzZi1zZXJ2ZXItdG8tc2VydmVyIiwic3ViIjoiODg5YWFhNjctODJiNC00NGI0LWIyMjYtZDU4ZmZmYzUxYzZlIiwidHlwIjoiUmVmcmVzaCIsImF6cCI6InNhbGVzZm9yY2Utc2VydmljZXNjbG91ZCIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6ImU0MWI2MjJjLWJmOGYtNGU4Yi1hODkwLThiNTRkMTA5NWNiNCIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIn0.8VopYZfZF7fazR-oO0czqDEBzfd_JK0jLJm5YMboQns","token_type": "bearer","not-before-policy": 0,"session_state": "e41b622c-bf8f-4e8b-a890-8b54d1095cb4","scope": "profile"}';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    public static void executarHttpRequestGETTTest(){
        Test.setMock(HttpCalloutMock.class, new ServerToServerHttpCalloutMock());
        Map<String, String> header = new Map<String, String> {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Cookie' => 'incap_ses_1218_2400284=NWlwBv01iErhbWmFazXnEI0zhWIAAAAAaNqNnManGXUp6inBuasQoQ==;4'
        };

        Test.StartTest();
        HttpResponse response = Util.executarHttpRequest('String strEndPoint', 'GET', header, 'String strBody', 40000);
        Test.StopTest();

        String actualValue = response.getBody();
        String expectedValue = '{"access_token": "Tw6Ec4c2EKlOGSbP5IdTvQ9c4477yamofNFl1PiW_qX0sBBqiANalJTvh8107sSyCRgfpFr_5YNqWj_HGjY5Jl5h7ayl7tuBSdpWdr0IaJL7dvqj0zvuN8jOhafAWoVyW_rtsf_Iucnz4ymyrGEtW5_N3jYGm5t44qpzJymu2UzLH72zPTVjq0jJjaNdRh2ORvfvnLRMB7kwFSUlJe36y8R5nUES32057yxarPh6cKkXEuIK3F5Bx34TtWQvagxDFiaFl_GMsmDfslIqHbM8d3Hca8JBqII2GE1e231XySCy8Eic68u8cs4hhp96mKUptwHRqkl1nnmKp39ySqpP5Q","expires_in": 3600,"refresh_expires_in": 1800,"refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIyMTdlODc3ZS0xNjQ4LTRjYzMtOWFjMi1jYzliNjM5MDNjYzcifQ.eyJqdGkiOiJhODNmZGFkOC1jOGNkLTQwMmMtYjI1Zi1mOGNiNzBlNzRkNzgiLCJleHAiOjE2NzYzMTE2MzgsIm5iZiI6MCwiaWF0IjoxNjc2MzA5ODM4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9jc2Ytc2VydmVyLXRvLXNlcnZlciIsImF1ZCI6Imh0dHBzOi8va2V5Y2xvYWstaG9tLmNzZmNwdi53Y29ycC5jYXJyZWZvdXIuY29tL2F1dGgvcmVhbG1zL2NzZi1zZXJ2ZXItdG8tc2VydmVyIiwic3ViIjoiODg5YWFhNjctODJiNC00NGI0LWIyMjYtZDU4ZmZmYzUxYzZlIiwidHlwIjoiUmVmcmVzaCIsImF6cCI6InNhbGVzZm9yY2Utc2VydmljZXNjbG91ZCIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6ImU0MWI2MjJjLWJmOGYtNGU4Yi1hODkwLThiNTRkMTA5NWNiNCIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIn0.8VopYZfZF7fazR-oO0czqDEBzfd_JK0jLJm5YMboQns","token_type": "bearer","not-before-policy": 0,"session_state": "e41b622c-bf8f-4e8b-a890-8b54d1095cb4","scope": "profile"}';
        System.assertEquals(expectedValue, actualValue);
    }

    @isTest
    public static void validaCelularTest() {
        IdentificaClienteTO.TelefoneTO phone1 = new IdentificaClienteTO.TelefoneTO();
        phone1.numero = '91055985';
        phone1.ddd = '11';
        phone1.celularSeguro = true;
        phone1.numeroSerie = 5;

        IdentificaClienteTO.TelefoneTO phone2 = new IdentificaClienteTO.TelefoneTO();
        phone2.numero = '991055985';
        phone2.ddd = '11';
        phone2.celularSeguro = true;
        phone2.numeroSerie = 5;

        Test.StartTest();
        Boolean boolPhone1 = Util.validaCelular('11991055985', phone1);
        Boolean boolPhone2 = Util.validaCelular('11991055985', phone2);
        Test.StopTest();

        System.assertEquals(boolPhone1, false);
        System.assertEquals(boolPhone2, true);
    }

    @isTest
    public static void formataNumeroCelularTest() {
        Test.StartTest();
        String phone1 = Util.formataNumeroCelular('11991055985');
        String phone2 = Util.formataNumeroCelular('1191055985');
        String phone3 = Util.formataNumeroCelular('91055985');
        Test.StopTest();

        System.assertEquals(phone1, '11991055985');
        System.assertEquals(phone2, '11991055985');
        System.assertEquals(phone3, '991055985');
    }

    @isTest
    public static void formatCelularTest() {
        Test.StartTest();
        String phone1 = Util.formatCelular('11991055985');
        String phone2 = Util.formatCelular('1191055985');
        String phone3 = Util.formatCelular('991055985');
        String phone4 = Util.formatCelular('91055985');
        String phone5 = Util.formatCelular('5534991055985');
        Test.StopTest();

        System.assertEquals(phone1, '(11) 99105-5985');
        System.assertEquals(phone2, '(11) 9105-5985');
        System.assertEquals(phone3, '99105-5985');
        System.assertEquals(phone4, '9105-5985');
        System.assertEquals(phone5, '(34) 99105-5985');
    }

    @isTest
    public static void formatCEPTest() {
        Test.StartTest();
        String cep1 = Util.formatCEP('38400066');
        String cep2 = Util.formatCEP('78899-999');
        String cep3 = Util.formatCEP('999');
        Test.StopTest();

        System.assertEquals(cep1, '38400-066');
        System.assertEquals(cep2, '78899-999');
        System.assertEquals(cep3, '999');
    }
    
    @isTest
    public static void mascararEmailTest() {
        Test.StartTest();
        String email1 = Util.mascararEmail('');
        String email2 = Util.mascararEmail('usario_4560@gmai.com');
        String email3 = Util.mascararEmail('usuario.test@carrefour.com');
        Test.StopTest();

        System.assertEquals(email1, '');
        System.assertEquals(email2, 'usa********@gmai.com');
        System.assertEquals(email3, 'usu*********@carrefour.com');
    }
    
    
    @isTest
    public static void formatDDMMTest() {
        Test.StartTest();
        String data1 = Util.formatDDMM(1, 2, '-');
        String data2 = Util.formatDDMM(10, 12, '/');
        Test.StopTest();

        System.assertEquals(data1, '01-02');
        System.assertEquals(data2, '10/12');
    }
    
    @isTest
    public static void formatYYYYMMDDTest() {
        Test.StartTest();
        String data1 = Util.formatYYYYMMDD('31-12-2022', '-', '/');
        String data2 = Util.formatYYYYMMDD('19/10/2024', '/', '-');
        Test.StopTest();

        System.assertEquals(data1, '2022/12/31');
        System.assertEquals(data2, '2024-10-19');
    }
    
    @isTest
    public static void stringToDateTest() {
        Test.StartTest();
        Date data1 = Util.stringToDate('01/09/2023', '/');
        Date data2 = Util.stringToDate('19-10-2024', '-');
        Date data3 = Util.stringToDate('', '/');
        Date data4 = Util.stringToDate('texto/10/202a', '-');
        Test.StopTest();

        System.assertEquals(data1, Date.newInstance(2023, 9, 1));
        System.assertEquals(data2, Date.newInstance(2024, 10, 19));
        System.assertEquals(data3, null);
        System.assertEquals(data4, null);
    }
    
    @isTest
    public static void getDateAcordoTest() {
        Test.StartTest();
        String data1 = Util.getDateAcordo(0);
        Test.StopTest();
        
        Date start =  Date.today();
        Integer day = start.day();
        Integer month = start.month();
        String toReturn =  String.valueOf(day).leftPad(2, '0')  + '/' + String.valueOf(month).leftPad(2, '0')  + '/' + start.year();      
        System.assertEquals(data1, toReturn);
    }
    
        
    @isTest
    public static void isValidDateAcordooTest() {
        Date start =  Date.today();
        start =  start.addDays(5);
        String dataTest=  start.day() + '/' + start.month() + '/' + start.year();  
        
        Test.StartTest();
        boolean isValid1 = Util.isValidDateAcordo(1, 10, dataTest);
        boolean isValid2 = Util.isValidDateAcordo(1, 3, dataTest);
        Test.StopTest();
        
        System.assertEquals(isValid1, true);
        System.assertEquals(isValid2, false);
    }

    
    @isTest
    public static void obterDDDTelefoneTest(){
        Test.StartTest();
        String ddd1 = Util.obterDDDTelefone('5511991919867'); 
        String ddd2 = Util.obterDDDTelefone('551191919867'); 
        String ddd3 = Util.obterDDDTelefone('11991919867');
        String ddd4 = Util.obterDDDTelefone('991919867'); 
        Test.StopTest();

        Assert.areEqual('11', ddd1, 'sucesso: código país + ddd + telefone 9 dígitos');
        Assert.areEqual('11', ddd2, 'sucesso: código país + ddd + telefone 8 dígitos');
        Assert.areEqual('11', ddd3, 'ddd retornado com sucesso quando é: ddd + telefone');
        Assert.areEqual(null, ddd4, 'nenhum valor retornado para ddd pois o telefone não possui ddd');

    }

    @isTest
    public static void obterNumeroTelefoneTest(){
        Test.StartTest();
        String telefone1 = Util.obterNumeroTelefone('5511991919867');
        String telefone2 = Util.obterNumeroTelefone('551191919867'); 
        String telefone3 = Util.obterNumeroTelefone('11991919867');
        String telefone4 = Util.obterNumeroTelefone('991919867');
        Test.StopTest();
        
        Assert.areEqual('991919867', telefone1, 'sucessso: código país + ddd + telefone 9 dígitos');
        Assert.areEqual('91919867', telefone2, 'sucessso: código país + ddd + telefone 8 dígitos');
        Assert.areEqual('991919867', telefone3, 'número do telefone retornado com sucesso quando é: ddd + telefone');
        Assert.areEqual('991919867', telefone4, 'numero do telefone retornado com sucesso quando for passado somente o número');
    }

    @isTest
    public static void formatDateStringTest(){
        Test.StartTest();
        String dataParaFormatar1 = Util.formatDateString('2024-10-02', '-', '-');
        String dataParaFormatar2 = Util.formatDateString('2024/10/02', '/', '/');
        Test.StopTest();
        
        System.assertEquals(dataParaFormatar1, '10-02-2024');
        System.assertEquals(dataParaFormatar2, '10/02/2024');

    }

    @isTest
    public static void mascararTelefoneTest(){
        Test.StartTest();
        String telefoneMascarado1 = Util.mascararTelefone('');
        String telefoneMascarado2 = Util.mascararTelefone('3432815687');
        String telefoneMascarado3 = Util.mascararTelefone('34991005471');
        Test.StopTest();
        
        System.assertEquals(telefoneMascarado1, '');
        System.assertEquals(telefoneMascarado2, '(**) *****-5687');
        System.assertEquals(telefoneMascarado3, '(**) *****-5471');
    }

    @isTest
    public static void formatMMDDTest(){
        Test.StartTest();
        String data1 = Util.formatMMDD('2024-10-02', '-', '-');
        String data2 = Util.formatMMDD('2023/02/28', '/', '-');
        Test.StopTest();
        
        System.assertEquals(data1, '02-10');
        System.assertEquals(data2, '28-02');
    }

    @isTest
    public static void formatarDataTest(){
        Test.StartTest();
        String data1 = Util.formatarData(Date.newInstance(2024, 10, 2));
        String data2 = Util.formatarData(Date.newInstance(2023, 2, 28));
        Test.StopTest();
        
        System.assertEquals(data1, '02/10/2024');
        System.assertEquals(data2, '28/02/2023');
    }

    @isTest
    public static void formatYYYYMMDD2Test(){
        Test.StartTest();
        String data1 = Util.formatYYYYMMDD(Date.newInstance(2024, 10, 2), '-');
        String data2 = Util.formatYYYYMMDD(Date.newInstance(2023, 2, 28), '/');
        Test.StopTest();
        
        System.assertEquals(data1, '2024-10-02');
        System.assertEquals(data2, '2023/02/28');
    }

    @isTest
    public static void obterSobrenomeTest(){
        Test.StartTest();
        String sobrenome = Util.obterSobrenome('MARCIA GOMES DA SILVA');
        Test.StopTest();
        Assert.areEqual('GOMES DA SILVA', sobrenome, 'Deve ser retornado o sobrenome');
    }

    @isTest
    public static void formatDateDDMMYYYYTest(){
        Test.StartTest();
        String dataFormatada = Util.formatDateDDMMYYYY(Date.valueOf('2025-01-14'), '/');
        Test.StopTest();

        Assert.areEqual('14/01/2025', dataFormatada, 'A deve retornar no formato esperado');
    }
    
}