public with sharing class MensagensEnhanced {
    
    public static void criarMesagens(String msgSessionId,String conversationIdentifier, Datetime startTime, Datetime endTime){
            Long startTimestamp = startTime.getTime();

            ConversationEntries.ResponseAPI response = MensagensEnhancedController.getConversationEntries(conversationIdentifier, startTimestamp);

            Integer ordem = 1;

            List<MensagensEnhanced__c> msgLst = new List<MensagensEnhanced__c>();

           for(ConversationEntries.CoversationEntry conversation : response.conversationEntries){
                DateTime dataClient = conversation.sender.role == 'EndUser' || conversation.sender.role == 'System' ? DateTime.newInstance(conversation.clientTimestamp * 1000)  : DateTime.newInstance(conversation.clientTimestamp);
                if(dataClient > endTime) continue;       
                MensagensEnhanced__c msg = new MensagensEnhanced__c();
                msg.AppType__c =  conversation.sender.appType;
                msg.DataHora__c = dataClient;
                msg.MensagemTexto__c = conversation.messageText;
                msg.OrdemMensagem__c = ordem;
                msg.Role__c = conversation.sender.role;
                msg.SessaoMessaging__c = msgSessionId;
                msgLst.add(msg);

                ordem =  ordem + 1;
            } 

            if(!msgLst.isEmpty()){
                insert msgLst;
            }
    }

    @future(callout=true)
    public static void assyncCriarMensagens(String sessionId, String conversationId, Datetime startTime, Datetime endTime){
        criarMesagens(sessionId, conversationId, startTime, endTime);
    }

}