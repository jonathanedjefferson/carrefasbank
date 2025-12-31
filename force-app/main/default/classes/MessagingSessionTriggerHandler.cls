public without sharing class MessagingSessionTriggerHandler {
    public static void handleUpdate(Map<Id,MessagingSession>  newMap, Map<Id,MessagingSession> oldMap){
        Set<Id> sessionIdLst = newMap.keySet();
        List<MessagingSession> sessionLst = MessagingSessionDAO.getMenssagingSessionByListId(sessionIdLst);
        List<ChaveLigaDesliga__mdt> chaveLigaDesliga = ChaveLigaDesligaDAO.getInstance().getByDeveloperNameLike('IntegracaoMensagensEnhanced');
        If(!sessionLst.isEmpty()){
            for(MessagingSession session : sessionLst){
                MessagingSession oldSession = oldMap.get(session.Id);

                if(session.Conversation == null && !Test.isRunningTest()) continue;

                if((session.Status == 'Ended') && (session.Status != oldSession.Status) && (session.MessagingChannel.PlatformType == 'Enhanced' && chaveLigaDesliga[0].Ligado__c)){
                    MensagensEnhanced.assyncCriarMensagens(session.Id, session.Conversation.ConversationIdentifier, session.StartTime, session.EndTime);
                }
            }
        }                
    }
}