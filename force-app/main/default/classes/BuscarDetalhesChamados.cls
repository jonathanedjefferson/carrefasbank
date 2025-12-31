public class BuscarDetalhesChamados {
    public static List<BuscarDetalhesChamadosTO.ResponseWrapper> getDetalhesChamadoPorProtocolo(String CPF, String email, String period, Date startPeriod, Date endPeriod) {
        String statusCode;
        String statusName;
        
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Detalhes de Chamados');
        String endPoint = config.endpoint__c;
        String appKey = config.apiKey__c;
        String appInstanceKey = config.appInstanceKey__c;
        
        String url;
        if(email != null) {
            url = endPoint + '?AppKey='+ appKey +'&AppInstanceKey='+ appInstanceKey+ '&customerEmail=' + email + '&tipo_filtro=AND&sortColumn=TimeUpdate&sortDirection=DESC';
        } else if (CPF != null) {
            url = endPoint + '?AppKey='+ appKey +'&AppInstanceKey='+ appInstanceKey+ '&customerField[customerFieldU]=' + CPF + '&tipo_filtro=AND&sortColumn=TimeUpdate&sortDirection=DESC';
        }

        if (period != null) {
            url += '&Period=' + period;
            
            if (period == '-1') {
                url += '&DateStartPeriod=' + startPeriod.year() + '-' + startPeriod.month() + '-' + startPeriod.day() + '&DateEndPeriod=' + endPeriod.year() + '-' + endPeriod.month() + '-' + endPeriod.day();
            }
        }
        
        String method = config.method__c;
        
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/json');
        headers.put('Authorization', 'apphub 16259192f636b712c45139eb90e77c8d:67ec4a06c2238b495072ce7bdc3975d7');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }
        
        HttpResponse response = new Http().send(request);
        List<String> listString = response.getBody().split('"SubOrigem"');

        LogIntegracaoBO.InsertLog('Detalhes chamados NeoAssist', endPoint, config.method__c, url, CPF, String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        List<BuscarDetalhesChamadosTO.ResponseWrapper> result = new List<BuscarDetalhesChamadosTO.ResponseWrapper>();
        
        if (response.getStatusCode() == 200) {
            BuscarDetalhesChamadosTO.ResponseWrapper responseWrapper = (BuscarDetalhesChamadosTO.ResponseWrapper) JSON.deserialize(response.getBody().replace('"Date"', '"Date_Z"'), BuscarDetalhesChamadosTO.ResponseWrapper.class);
            for(Integer i = 1; i < listString.size(); i++) { 
                responseWrapper.data[i - 1].bodyProtocolo = listString[i];
            }
            result.add(responseWrapper);
        } else {
            System.debug('Erro ao chamar a API. Código de status: ' + response.getStatusCode());
            System.debug('Corpo da resposta: ' + response.getBody());
        }
        
        return result;
    }
}