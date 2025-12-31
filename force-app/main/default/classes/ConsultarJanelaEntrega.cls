public with sharing class ConsultarJanelaEntrega {
    public static List<ConsultarJanelaEntregaTO> makeAPIRequest(String carrierId, Datetime initialDate, Integer daysToAdd) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Consultar janela de entrega');
        String apiUrl = config.endpoint__c + '?filters%5BisLocked%5D=false&filters%5Bstatus%5D%5B0%5D=pending&filters%5Bstatus%5D%5B1%5D=inProgress&filters%5BcarrierId%5D='+ carrierId +'&filters%5Bdate%5D%5Bfrom%5D=' + convertDateToString(initialDate) + '&filters%5Bdate%5D%5Bto%5D=' + convertDateToString(initialDate.addDays(daysToAdd));
        String calloutMethod = config.method__c;
        System.debug(apiUrl);
        String apiToken = config.token__c;
        String janisApiKey = config.apiKey__c;
        String janisApiSecret = config.password__c;
        String janisClient = config.username__c;
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(calloutMethod);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('janis-api-key', janisApiKey);
        request.setHeader('janis-api-secret', janisApiSecret);
        request.setHeader('janis-client', janisClient);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Consultar janela de entrega', config.endpoint__c, config.method__c, apiUrl, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');


        if(response.getStatusCode() == 200) {
            List<ConsultarJanelaEntregaTO> retorno = (List<ConsultarJanelaEntregaTO>) JSON.deserialize(response.getBody(), List<ConsultarJanelaEntregaTO>.class);
            for(ConsultarJanelaEntregaTO janelasEntrega: retorno) {
                janelasEntrega.statusCode = response.getStatusCode();
            }
            
            return retorno;
        }

        List<ConsultarJanelaEntregaTO> newList = new List<ConsultarJanelaEntregaTO>();
        ConsultarJanelaEntregaTO newReturn = new ConsultarJanelaEntregaTO();
        newReturn.statusCode = response.getStatusCode();
        newReturn.dateStart = response.getBody();
        newList.add(newReturn);
        return newList;
    }

    public static String convertDateToString(Datetime startDate) {
        String pattern = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
        String formattedDateTime = startDate.format(pattern);
        return formattedDateTime;
    }
}