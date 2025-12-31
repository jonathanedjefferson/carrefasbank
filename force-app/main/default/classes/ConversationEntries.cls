public class ConversationEntries {
    public static String getAccessToken(){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SalesforceAuth');

        String endpoint = config.Endpoint__c + config.Path__c;
        String body = config.Body__c;
        String metodo = config.Method__c;
    
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            metodo, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'x-uat' => config.UAT__c

            }, 
            body, 
            Integer.valueof(config.Timeout__c));

        LogIntegracaoBO.InsertLog(
            'Autenticação Salesforce', 
            endpoint, 
            metodo, 
            body, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            'Whatsapp'
         ); 
    
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
        
        if (objHttpResponse.getStatusCode() == 200) {
            return (String) result.get('access_token');
        } else {
            throw new CalloutException('Erro ao autenticar API: ' + objHttpResponse.getStatusCode());
        }
    }

    public static ResponseAPI getConversationEntries(String conversationIdentifier, Long startTime){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConversationEntries');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{conversationIdentifier}', conversationIdentifier).replace('{startTimestamp}', String.valueOf(startTime));
        String metodo = config.Method__c;
        String body = config.Body__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            metodo,
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ getAccessToken(),
                'x-uat' => config.UAT__c

            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Mensagens Enhanced', 
            endpoint, 
            metodo, 
            body, 
            null, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            'Whatsapp'
         );

        if (objHttpResponse.getStatusCode() == 200) {
            return (ResponseAPI) System.JSON.deserialize(objHttpResponse.getBody(), ResponseAPI.class);
        } else{
            throw new CalloutException('Erro ao obter registros: ' + objHttpResponse.getStatusCode());
        }

    }

    public class ResponseAPI{
        public List<CoversationEntry> conversationEntries;
    }

    public class CoversationEntry{
        public Integer clientDuration;
        public Long clientTimestamp;
        public String identifier;
        public String messageText;
        public List<String> relatedRecords;
        public Sender sender;
        public Long serverReceivedTimestamp;
    }

    public class Sender{
        public String appType;
        public String role;
        public String subject;
    }
 
}