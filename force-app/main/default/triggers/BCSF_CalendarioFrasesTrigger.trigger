trigger BCSF_CalendarioFrasesTrigger on Calendario_Frases_Saudacoes__c (before insert, before update) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        BCSF_CarinaPhraseCalendarBO.updateEmojiPhrase(Trigger.new);
    }
}