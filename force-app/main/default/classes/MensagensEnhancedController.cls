public with sharing class MensagensEnhancedController {

    public static ConversationEntries.ResponseAPI getConversationEntries(String conversationIdentifier, Long startTimestamp){
        return ConversationEntries.getConversationEntries(conversationIdentifier, startTimestamp);
    }

}