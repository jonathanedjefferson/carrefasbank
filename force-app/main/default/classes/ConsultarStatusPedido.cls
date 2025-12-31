public with sharing class ConsultarStatusPedido {
    public static ConsultarStatusPedidoTO.responseWrapper makeAPIRequest(String orderCode) {
        //a key da api é o orderCode passado na url do chamado
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Verificar Status do Pedido');

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        String apiUrl = config.endpoint__c + orderCode + '/tracking?viewType=PORTAL_BACKOFFICE';

        request.setMethod(config.method__c);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', config.token__c);
        request.setHeader('x-api-key', config.apiKey__c);

        HttpResponse response = http.send(request);

        LogIntegracaoBO.InsertLog('Verificar status do pedido', apiUrl, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        ConsultarStatusPedidoTO.responseWrapper result = new ConsultarStatusPedidoTO.responseWrapper();
        if(response.getStatusCode() == 200) {
            result = (ConsultarStatusPedidoTO.responseWrapper) JSON.deserialize(response.getBody(), ConsultarStatusPedidoTO.responseWrapper.class);
        } else {
            return null;
        }
        return result;
    }

    public static Boolean notaFiscalEmitida(String orderCode) {
        //lista de consignments, onde cada item dessa lista contém uma lista de status
        ConsultarStatusPedidoTO.responseWrapper resultado = makeAPIRequest(orderCode);
        if(resultado != null) {
            //for i varrendo a lista de consignments
            for(Integer i = 0; i < resultado.consignments.size(); i++) {
                //for j varrendo a lista de status do consignment[i]
                for(Integer j = 0; j < resultado.consignments[i].status.size(); j++) {
                    if(resultado.consignments[i].status[j].status == 'NFE') {
                        return True;
                    }
                }
            } 
        }

        return False;
    }
}