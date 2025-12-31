@isTest
public class GetFileFaturaTest {
    
    @isTest
    public static void getFileFaturatest(){
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockDownloadFaturaComCriptografia');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        List<GetFileFaturaHelper.Input> inputLst = new List<GetFileFaturaHelper.Input>();

        GetFileFaturaHelper.Input input = new GetFileFaturaHelper.Input();
        input.numeroConta = '10000019496';
        input.idEmpresa = '1';
        input.idFatura = 1245;
        input.cpf = '49926079857';
        input.mesRefFatura = '07-2028';
        input.canal = 'whatsapp';
        inputLst.add(input);

        Test.StartTest();
        List<GetFileFaturaHelper.OutputFatura> output = GetFileFaturaHelper.GetFileFatura(inputLst);
        Test.StopTest();

        Assert.areEqual('OK', output[0].StatusApi, 'api retornou sucesso.');
        Assert.isNotNull([SELECT Id FROM ContentVersion Where Id = :output[0].idFile], 'arquivo criado com sucesso.');
    }

}