trigger LiveChatTranscriptTrigger on LiveChatTranscript (before update) {
    LiveChatTranscriptHandler HANDLER = new LiveChatTranscriptHandler(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);

    if (Trigger.isBefore) {
        if(Trigger.isUpdate){
            HANDLER.beforeUpdate();
        }
    }
}