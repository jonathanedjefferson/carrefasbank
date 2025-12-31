public class GerarLinkDeCatalogo {
    public static GerarLinkDeCatalogoTO.ResponseWrapper gerarLink(String Items, String Categoria, String CEP) {

        //Metadado createLink
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('createLink');

        // Endpoint da APIgerarLink
        String url = config.endpoint__c;

        // Metodo utlizado (POST)
        String method = config.method__c;

        //Token ou apiKey
        String apiKey = config.apiKey__c;   
        
        
        // Headers necessários para a autenticação
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Accept', '*/*');
        headers.put('x-api-key', apiKey);	
        
        // Realiza a chamada POST para o endpoint
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }
        
       // request.put('x-api-key',apiKey);
        request.setTimeout(60000); //Muda Timeout para 1 Minuto
        
        // Cria um mapa para os campos que esperam valores de String
        Map<String, String> requestBody = new Map<String, String>();
        requestBody.put('produtos', Items);
        requestBody.put('categoria', Categoria);
        requestBody.put('cep', CEP);
        
        // Converte o mapa requestBody em JSON
        String requestBodyJson = JSON.serialize(requestBody);
      
 		request.setBody(requestBodyJson);

        HttpResponse response = new Http().send(request);
        

        GerarLinkDeCatalogoTO.ResponseWrapper result = new GerarLinkDeCatalogoTO.ResponseWrapper();

        // Verifica se a chamada foi bem-sucedida (código de resposta 200)
        if (response.getStatusCode() == 200) {
            System.debug('Sucesso: o body completo é esse:'+response.getBody());
            
            try{ 
                GerarLinkDeCatalogoTO.ResponseWrapper responseWrapper = (GerarLinkDeCatalogoTO.ResponseWrapper) JSON.deserialize(response.getBody(), GerarLinkDeCatalogoTO.ResponseWrapper.class);
                LogIntegracaoBO.InsertLog('Gerar link de catálogo', url, method, requestBodyJson, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
                result = responseWrapper; 
            } catch(Exception ex){
                LogIntegracaoBO.InsertLog('Gerar link de catálogo', url, method, requestBodyJson, 'vazio', '400', response.getBody(), 'CRF');
                return null;
            }
          
        } else {
            return null;
        }
        return result;
    }
}