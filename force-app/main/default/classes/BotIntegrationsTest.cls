/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS SEGINTES CLASSES ABAIXO:    *
*    - BotIntegrations              95%                                  *
*    - ServerToServerServices       100%                                 *
*    - UltimosLancamentos           100%                                 *
**************************************************************************/
@isTest
public class BotIntegrationsTest {
    @isTest
    public static void GetFaturasAbertasTest(){
        Test.setMock(HttpCalloutMock.class, new UltimosLancamentosHttpCalloutMock());
        HttpResponse response = Util.executarHttpRequest('String strEndPoint', 'GET', new Map<String, String>(), 'String strBody', 40000);

        List<BotIntegrations.InputFaturasAbertas> listInput = new List<BotIntegrations.InputFaturasAbertas>();
        BotIntegrations.InputFaturasAbertas input = new BotIntegrations.InputFaturasAbertas();
        input.CPF = '12345678914';
        input.NumeroConta = '1234654884';
        input.Token = '12345678914';
        input.canal = 'chat';
        listInput.add(input);

        Test.StartTest();
        List<BotIntegrations.OutputFaturasAbertas> FaturasAbertas = BotIntegrations.GetFaturasAbertas(listInput);
        Test.StopTest();

        System.AssertEquals(1, FaturasAbertas.size());
    }
    
    @isTest
    public static void GetTokenServerToServerTest(){
        Test.setMock(HttpCalloutMock.class, new ServerToServerHttpCalloutMock());
        HttpResponse response = Util.executarHttpRequest('String strEndPoint', 'POST', new Map<String, String>(), 'String strBody', 40000);
        
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = 'canal';
        listInputToken.add(inputToken);

        Test.StartTest();
        List<ServerToServerServices.ResponseToken> ResponseToken = ServerToServerServices.GetTokenServerToServer(listInputToken);
        Test.StopTest();
        System.AssertEquals(ResponseToken[0].access_token, 'Tw6Ec4c2EKlOGSbP5IdTvQ9c4477yamofNFl1PiW_qX0sBBqiANalJTvh8107sSyCRgfpFr_5YNqWj_HGjY5Jl5h7ayl7tuBSdpWdr0IaJL7dvqj0zvuN8jOhafAWoVyW_rtsf_Iucnz4ymyrGEtW5_N3jYGm5t44qpzJymu2UzLH72zPTVjq0jJjaNdRh2ORvfvnLRMB7kwFSUlJe36y8R5nUES32057yxarPh6cKkXEuIK3F5Bx34TtWQvagxDFiaFl_GMsmDfslIqHbM8d3Hca8JBqII2GE1e231XySCy8Eic68u8cs4hhp96mKUptwHRqkl1nnmKp39ySqpP5Q');
    }
}