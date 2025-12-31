public  class MessagingSessionDAO {
    public static List<MessagingSession> getMenssagingSessionByListId(Set<Id> idLst){
        List<MessagingSession> sessionLst = new List<MessagingSession>();
        sessionLst = [  
            SELECT
                Id,
                conversation.ConversationIdentifier,
                StartTime,
                EndTime,
                Status,
                MessagingChannel.PlatformType
            FROM MessagingSession WHERE Id IN :idLst];

        return sessionLst;
    }
}