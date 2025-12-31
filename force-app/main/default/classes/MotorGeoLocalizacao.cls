public with sharing class MotorGeoLocalizacao {
    public static MotorGeoLocalizacaoTO.resposneWrapper makeAPIRequest(String CEP, String categoria) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('motorGeoLocalizacao');
        String apiKey = config.apiKey__c;
        String calloutMethod = config.method__c;
		String endPoint = config.endpoint__c;
        
        String apiUrl = endPoint + '?category=' + categoria + '&zipcode=' + CEP;
        HttpRequest request = new HttpRequest();
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiKey);
        request.setEndpoint(apiUrl);

        Http http = new Http();
        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Loja mais próxima por CEP e categoria', apiUrl, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        if(response.getStatusCode() == 200) {
            List<MotorGeoLocalizacaoTO.resposneWrapper> responseBody = new List<MotorGeoLocalizacaoTO.resposneWrapper>();
            responseBody = (List<MotorGeoLocalizacaoTO.resposneWrapper>) Json.deserialize(response.getBody(), List<MotorGeoLocalizacaoTO.resposneWrapper>.class);
            responseBody[0].statusCode = response.getStatusCode();

            String todasLojas;
            for(MotorGeoLocalizacaoTO.resposneWrapper itemLoja: responseBody) {
                todasLojas += itemLoja.address.whatsappText;
                todasLojas += '\n';
                todasLojas += '\n';

            }

            responseBody[0].address.whatsappText = todasLojas;
            responseBody[0].quantidadeLojas = responseBody.size();
            return responseBody[0];
        } else {
            MotorGeoLocalizacaoTO.resposneWrapper responseBody = (MotorGeoLocalizacaoTO.resposneWrapper) Json.deserialize(response.getBody(), MotorGeoLocalizacaoTO.resposneWrapper.class);
            responseBody.statusCode = response.getStatusCode();
            return responseBody;
        }
    }}