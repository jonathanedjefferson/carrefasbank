public with sharing class BuscarLinkContrato {

    public static WarrantyResponse buscarGarantiaPedido(String orderId, String brand) {
        // Pegando as configurações no Custom Metadata
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Buscar Link Contrato');
        String calloutMethod = config.method__c; // Esperado: 'GET'
        String endPoint = config.endPoint__c + orderId + '/warranty';
        String apiToken = config.apiKey__c;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(calloutMethod);
        request.setHeader('x-api-key', apiToken);
        request.setHeader('Accept', 'application/json');
        request.setHeader('auth-key', config.token__c);
        request.setHeader('brand', brand);

        HttpResponse response = new Http().send(request);
        System.debug('Buscar Garantia Pedido - Response: ' + response.getBody());

        LogIntegracaoBO.InsertLog(
            'BuscarLinkContrato',
            endPoint,
            calloutMethod,
            'vazio',
            'vazio',
            String.valueOf(response.getStatusCode()),
            response.getBody(),
            'CRF'
        );

        if (response.getStatusCode() == 200) {
            return (WarrantyResponse) JSON.deserialize(response.getBody(), WarrantyResponse.class);
        }

        return null;
    }

    public class WarrantyResponse {
        public String linkTicket;
    }
}