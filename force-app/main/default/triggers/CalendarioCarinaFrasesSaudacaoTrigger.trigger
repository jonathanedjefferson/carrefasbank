trigger CalendarioCarinaFrasesSaudacaoTrigger on CalendarioCarinaFrasesSaudacao__c (before insert, before update) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        CalendarioCarinaTriggerHandler.handle(Trigger.new);
    }
}