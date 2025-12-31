@isTest
private class BCSF_ArrayParserTest {
    public static testMethod void TestConvert() {
        Test.startTest();
        List<BCSF_ArrayParser.Request> listRequest = new List<BCSF_ArrayParser.Request>();
    	BCSF_ArrayParser.Request req = new BCSF_ArrayParser.Request();

        req.jsonStringToConvert = '[{"name":"Ford","models":["Fiesta","Focus","Mustang"]},{"name":"BMW","models":["320","X3","X5"]},{"name":"Fiat","models":["500","Panda"]}]';
    	
        listRequest.add(req);
        List<BCSF_ArrayParser.Response> listResult = BCSF_ArrayParser.execute(listRequest);
        System.assert(listResult[0].JSONCollection01.size() == 3, 'O método responsável por converter JSONs em Lista de JSONs não funcionou corretamente.');
        
        Test.stopTest();
    }
}