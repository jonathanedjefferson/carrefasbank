trigger MessagingSessionTrigger on MessagingSession (after update) {
        if((Trigger.isUpdate) && Trigger.isAfter) {
            MessagingSessionTriggerHandler.handleUpdate(Trigger.newMap, Trigger.oldMap);
        }
}