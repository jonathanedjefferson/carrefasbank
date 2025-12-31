public with sharing class ConsultarChaveNF {
    public static ConsultarChaveNFTO.Retorno makeAPIRequest(String orderCode) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Consultar chave NF');
        String apiUrl = config.endpoint__c + orderCode + '?viewType=AREA_LOGADA';

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(config.method__c);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', config.token__c);
        request.setHeader('x-api-key', config.apiKey__c);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Consultar chave NF', apiUrl, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        ConsultarChaveNFTO retorno = (ConsultarChaveNFTO) JSON.deserialize(response.getBody(), ConsultarChaveNFTO.class);
        ConsultarChaveNFTO.Retorno resultado = new ConsultarChaveNFTO.Retorno();
        resultado.statusCode = response.getStatusCode();
        resultado.orderCode = orderCode;

        if(response.getStatusCode() == 200) {
            if(retorno.payments.size() >= 1) {
                resultado.paymentMethod = retorno.payments[0].paymentMethod;
            }

            if(retorno.consignments.size() >= 1) {
                if(retorno.consignments[0].invoices.size() >= 1) {
                    resultado.key = retorno.consignments[0].invoices[0].key;
                }
            }  
        }

        return resultado;
    }
}