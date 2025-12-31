trigger BCSF_Atualizar_Chat_Transcript on LiveChatTranscript (after update) {
    //String Id = Trigger.new.get(obj.Id);
    /*
    for(LiveChatTranscript obj: Trigger.new) {
        LiveChatTranscript transcriptOld = Trigger.oldMap.get(obj.Id);
        
        if((transcriptOld.ChaveContaFinanceira__c != obj.ChaveContaFinanceira__c) || (transcriptOld.CPF__c != obj.CPF__c)){
            system.debug('If');
            Id idTranscript = obj.Id;
            ID jobID = System.enqueueJob(new BCSF_CTRL_Atualizar_Chat_Transcript(idTranscript));
        } else {
            system.debug('Else');
        }
    }
*/
}