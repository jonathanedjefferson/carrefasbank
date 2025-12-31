public with sharing class NeoAssistAPIAnexo {
    public static NeoAssistApiTO.resposneWrapper makeAPIRequest(String name, String fieldU, String fileId, String expertId, String Email, String numPedido, Integer categoryId, String observacao, String wfObservacao, Integer departamentoId, Integer prazo, String idEmpresa, String extencaoArquivo, Integer origin, String aguardandoComplemento, String resolverProtocolo, String assunto) {
        ContentVersion contentVersion = getFileContent(fileId);

        try {
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
            lstJson.Origin = origin;
            lstJson.ClassificacaoCRM = '';
            lstJson.rbEncaminhar = 'W';
            lstJson.WFObservacao = wfObservacao;
            lstJson.Observacao = observacao;
            lstJson.Prazo = prazo;
            lstJson.AguardandoComplemento = aguardandoComplemento;
            lstJson.ResolverProtocolo = resolverProtocolo != null ? resolverProtocolo : '';
            lstJson.DepartamentoID = departamentoId;
            lstJson.Data = lstData;
            lstJson.Assunto = assunto;

            Blob fileContentBlob = contentVersion.VersionData;
            String jsonDataString = JSON.serialize(lstJson);
            String boundary = '----WebKitFormBoundary' + String.valueOf(System.currentTimeMillis());
            String boundaryTime = '--' + String.valueOf(DateTime.now().getTime());
            String fileName = 'file.' + extencaoArquivo;
            String fileContent = EncodingUtil.base64Encode(fileContentBlob); //base64 encoded

            Blob formData = HttpHexFormBuilder.build()
                    .writeParam( 'jsonData', jsonDataString )
                    .writeFile( 'ChamadoAnexo', fileName, fileContent )
                    .getFormAsBlob();

            HttpRequest request = new HttpRequest();
            request.setMethod(calloutMethod);
            request.setHeader('Content-Type', HttpHexFormBuilder.GetContentType());
            request.setEndpoint(apiUrl);
            request.setBodyAsBlob(formData);

            Http http = new Http();
            HttpResponse response = http.send(request);
            LogIntegracaoBO.InsertLog('Criar chamado NeoAssist com anexo', apiUrl, calloutMethod, 'formData', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), idEmpresa);

            System.debug('TESTE Body: ' + jsonDataString);
            System.debug('TESTE Body: ' + request.getBody());

            if (response.getStatusCode() == 200) {
                //Sucesso.
                NeoAssistApiTO.resposneWrapper responseBody = (NeoAssistAPITo.resposneWrapper) Json.deserialize(response.getBody(), NeoAssistAPITo.resposneWrapper.class);
                responseBody.Status = response.getStatusCode();
                deleteFileContent(contentVersion.ContentDocumentId);
                return responseBody;
            } else {
                //Erro.
                NeoAssistAPITO.resposneWrapper responseBody = new NeoAssistAPITO.resposneWrapper();
                responseBody.Status = response.getStatusCode();
                deleteFileContent(contentVersion.ContentDocumentId);
                return responseBody;
            }
        } catch(Exception e) {
            deleteFileContent(contentVersion.ContentDocumentId);
            NeoAssistAPITO.resposneWrapper responseBody = new NeoAssistAPITO.resposneWrapper();
            responseBody.Status = 500;
            return responseBody;
        }
    }

    private static ContentVersion getFileContent(String fileId) {
        ContentVersion cv = [SELECT VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :fileId LIMIT 1];
        return cv;
    }

    @future
    private static void deleteFileContent(Id contentDocumentId) {
        ContentDocument contentDocument = new ContentDocument();
        contentDocument.Id = contentDocumentId;
        delete contentDocument;
    }
}