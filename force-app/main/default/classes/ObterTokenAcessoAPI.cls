/*
    @responsavel: Guilherme Brito
    @contato: guilgomes@deloitte.com
    @descricao: Classe responsável pela obtenção do token de acesso às APIs do Banco Carrefour. O access token estará disponível para utilização no fluxo 'BCSF FL Obter token de acesso'.
*/

public class ObterTokenAcessoAPI {

    public class Response {
        @InvocableVariable(label='Token de acesso')
        public String AccessToken;
    }

    public class Input{
        @InvocableVariable
        public String canal;
    }

    @InvocableMethod(label='Obter token de acesso API')
    public static List<Response> getAccessToken(List<Input> inputs) {
        List<Response> resList = new List<Response>();
        try {

            CarrefourAPICallout__mdt mdt;
            if(Test.isRunningTest()){
                mdt = (CarrefourAPICallout__mdt)Json.deserialize('{"Method__c": "POST","Endpoint__c": "123","Path__c" : "123","Body__c": "123"}', CarrefourAPICallout__mdt.class);
            } else {
                mdt = [SELECT Method__c, Endpoint__c, Path__c ,Body__c FROM CarrefourAPICallout__mdt where DeveloperName='ObterTokenAPI'];
            }

            //PEGANDO METADADO CUSTOM organizationType
            organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

            HttpRequest req = new HttpRequest();
            req.setMethod(mdt.Method__c);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setHeader('x-uat',UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : '');
            req.setEndpoint(mdt.Endpoint__c + mdt.Path__c);
            req.setBody(mdt.Body__c);

            Http http = new Http();
            HTTPResponse response = http.send(req);
            String jsonStr = response.getBody();
            List<String> jsonSplit = jsonStr.Split('"');
    
            Response res = new Response();
            res.AccessToken = jsonSplit[3];
            resList.add(res);

            // REGISTRANDO LOG DE INTEGRAÇÃO
            LogIntegracaoBO.InsertLog(
                'getAccessToken', 
                mdt.Endpoint__c + mdt.Path__c, 
                mdt.Method__c, 
                mdt.Body__c, 
                null, 
                String.valueOf(response.getStatusCode()), 
                response.getBody(),
                null,
                inputs[0].canal.capitalize()
            );
                        
            return resList;
        } catch(Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return null;
        } 
    } 
}