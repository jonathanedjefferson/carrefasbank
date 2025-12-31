public class NeoAssistAPIUpdateChamados {
    public static void sendRequestAPIUpdateCalls(String protocolo, String observacao) {
       
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('NeoAssist API updateChamados');
        String endpoint = config.endpoint__c+'?AppKey='+config.apiKey__c+'&AppInstanceKey='+config.appInstanceKey__c+'&ExpertID='+config.expertId__c;
        System.debug(endpoint);

        NeoAssistUpdateChamadosTO.jsonData lstJson = new NeoAssistUpdateChamadosTO.jsonData();
        // lstJson.CategoryID = '409118';
        lstJson.ExpertID = config.expertId__c;
        lstJson.Origin = '8';
        lstJson.Observacao = observacao;
        lstJson.Protocolo = protocolo;
        lstJson.AguardandoComplemento = 'on';
        lstJson.ResponderChamado = 'on';
        
        NeoAssistUpdateChamadosTO body = new NeoAssistUpdateChamadosTO();
        body.jsonData = lstJson;
        System.debug(body);
        String neobody = JSON.serialize(body);
        System.debug(neobody);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(config.method__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(neobody);
        System.debug(request.getHeader('Content-Type'));
        HttpResponse response = new Http().send(request);

        LogIntegracaoBO.InsertLog('Update chamados NeoAssist', endpoint, config.method__c, neobody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            System.debug('Chamado atualizado com sucesso!');
        }else {
            String errorMessage = 'Erro ' + response.getStatusCode() + ': ' + response.getStatus();
            System.debug(errorMessage);
        }
    }
}