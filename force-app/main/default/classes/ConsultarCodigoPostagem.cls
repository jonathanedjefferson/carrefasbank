public with sharing class ConsultarCodigoPostagem {
    public static ConsultarCodigoPostagemTO.Retorno makeAPIRequest(String orderCode) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Consultar código postagem');
        String apiUrl = config.endpoint__c + orderCode;
        String calloutMethod = config.method__c;
        String apiToken = config.token__c;

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', apiToken);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Consultar código de postagem', apiUrl, calloutMethod, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        ConsultarCodigoPostagemTO resultado = (ConsultarCodigoPostagemTO) JSON.deserialize(response.getBody(), ConsultarCodigoPostagemTO.class);
        System.debug(resultado);
        ConsultarCodigoPostagemTO.Retorno retorno = new ConsultarCodigoPostagemTO.Retorno();
        
        retorno.statusCode = response.getStatusCode();
        retorno.orderId = orderCode;

        if(retorno.statusCode == 200 && resultado.orders.size() >= 1) {
            for(ConsultarCodigoPostagemTO.Order_additional_fields campo: resultado.orders[0].order_additional_fields) {
                 if(campo.code == 'codigo-postagem-reversa') {
                    retorno.codigoPostagem = campo.value;
                 } else if (campo.code == 'shipping-priority-name') {
                    retorno.shippingPriorityName = campo.value;
                 }
            }
            retorno.lastUpdatedDate = resultado.orders[0].last_updated_date;
            retorno.orderLineState = resultado.orders[0].order_lines[0].order_line_state;
            retorno.orderLineStateReasonCode = resultado.orders[0].order_lines[0].order_line_state_reason_code;
            retorno.orderLineStateReasonLabel = resultado.orders[0].order_lines[0].order_line_state_reason_label;
            if(resultado.orders[0].order_lines[0].shipped_date != null) {
                retorno.shippedDate = resultado.orders[0].order_lines[0].shipped_date;
            }
            retorno.shippingDeadline = resultado.orders[0].shipping_deadline;
        }

        return retorno;
    }
}