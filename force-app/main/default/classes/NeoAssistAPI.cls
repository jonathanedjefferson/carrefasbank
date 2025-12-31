public with sharing class NeoAssistAPI {
    public static NeoAssistApiTO.resposneWrapper makeAPIRequest(String name, String fieldU, String expertId, String Email, String numPedido, Integer categoryId, String observacao, String wfObservacao, Integer departamentoId, Integer prazo) {
        //Endpoint necessita de duas autenticações: appKey e appInstanceKey, e a identificação do expertId.
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Criar Chamado');
        String endpoint = config.endpoint__c;
        String appKey = config.apiKey__c;
        String appInstanceKey = config.appInstanceKey__c;
        String calloutMethod = config.method__c;

        String apiUrl = endpoint + '?AppKey=' + appKey + '&AppInstanceKey=' + appInstanceKey + '&ExpertID=' + expertId;

        //Data contém recebe o email do consumidor e o número do pedido em questão.
        NeoAssistApiTO.Data lstData = new NeoAssistApiTO.Data();
        lstData.EMail = Email;
        if(numPedido != null) {
            lstData.ProtocoloFieldA = numPedido;
        }

        if(name != null) {
            lstData.Name = name;
        }

        if(fieldU != null) {
            lstData.FieldU = fieldU;
        }
        
        NeoAssistApiTO.jsonData lstJson = new NeoAssistApiTO.jsonData();
        lstJson.CategoryID = categoryId;
        lstJson.Origin = 8;
        lstJson.ClassificacaoCRM = '';
        lstJson.rbEncaminhar = 'W';
        lstJson.WFObservacao = wfObservacao;
        lstJson.Observacao = observacao;
        lstJson.Prazo = prazo;
        lstJson.AguardandoComplemento = 'on';
        lstJson.DepartamentoID = departamentoId;
        lstJson.Data = lstData;

        NeoAssistApiTO neoBody = new NeoAssistApiTO();
        neoBody.jsonData = lstJson;
        
        String body = JSON.serialize(neoBody);
        HttpRequest request = new HttpRequest();
        request.setMethod(calloutMethod);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(apiUrl);
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Criar chamado NeoAssist', apiUrl, calloutMethod, body, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');

        if (response.getStatusCode() == 200) {
            //Sucesso.
            NeoAssistApiTO.resposneWrapper responseBody = (NeoAssistAPITo.resposneWrapper) Json.deserialize(response.getBody(), NeoAssistAPITo.resposneWrapper.class);
            responseBody.Status = response.getStatusCode();
            return responseBody;
        } else {
            //Erro.
            NeoAssistAPITO.resposneWrapper responseBody = new NeoAssistAPITO.resposneWrapper();
            responseBody.Status = response.getStatusCode();
            return responseBody;
        }
    }
}