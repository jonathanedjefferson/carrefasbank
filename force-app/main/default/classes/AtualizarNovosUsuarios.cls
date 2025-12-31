public class AtualizarNovosUsuarios {
    
    public static Response atualizarUsuario(String fullnumber, String midiachannel, String partner) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Atualizar novos usuários');
        
        String Token;
        if(!Test.isRunningTest()) {
            Token = TokenWhatsApp.generateTokenWhatsAppCallout();
        } else {
            Token = 'teste'; 
        } 
        
        String url = config.endpoint__c;
        String method = config.method__c;
    
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Accept', '*/*');
        headers.put('Authorization', 'Bearer ' + Token);
        // headers.put('x-api-key', xApiKey);
        
        Map<String, String> requestBody = new Map<String, String>();
        requestBody.put('fullnumber', fullnumber);
        requestBody.put('midiachannel', midiachannel);
        requestBody.put('partner', partner);
        String body = JSON.serialize(requestBody);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + Token);
        request.setbody(body);
        
        HttpResponse response = new Http().send(request);
        LogIntegracaoBO.InsertLog('Atualizar novos usuários', url, method, body, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'SAMS');
        Response result = new Response();
        
        
        if (response.getStatusCode() == 200) {
            
            Response responseWrapper = (Response) JSON.deserialize(response.getBody(), Response.class);
            result = responseWrapper;
            
        } else {
            result = null;
        }
        
        system.debug('Resultado: ' + result);
        return result;
    }
    public class Request {
        public String fullNumber;
        public String midiachannel;
        public String partner;
        
        public Request(String fullNumber, String midiachannel, String msnbr1){
            fullNumber = this.fullNumber;
            midiachannel = this.midiachannel;
            partner = this.partner;
        }
    }
    public class Response {
        public String status;
        public String statusmsg;
        public String msnbr1;
    }
}