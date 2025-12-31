/*
 * @Author: Everymind
 * @Date: 21/03/2024
 * @Description: Classe Batch para fechar os casos abertos com o Tipo="Execução"
 */
global class FecharCasoExecucaoBatch implements Database.Batchable<sObject>{
    /**
	 * @Description: Método para iniciar o batch sem especificar o tamanho de cada lote
	 */
	global static void start() {
		Database.executeBatch(new FecharCasoExecucaoBatch());
	}

    /**
	 * @Description: Método para iniciar o batch especificando o tamanho de cada lote
	 * @Params: Integer batchSize - Número que representa o tamanho de cada lote
	 */
	global static void start(Integer batchSize) {
		Database.executeBatch(new FecharCasoExecucaoBatch(), batchSize);
	}


    global List<SObject> start(Database.BatchableContext bc) {
        List<LiveChatTranscript> listTranscript = [
            SELECT Id, Case.Status, Case.Type, CaseId
            FROM LiveChatTranscript
            WHERE Case.Status != 'Closed' AND Case.Type = 'Execução' AND (Status = 'Completed' OR Status = 'Missed') 
            LIMIT 2000
        ];

        List<MessagingSession > listMessaging = [
            SELECT Id, Case.Status, Case.Type, CaseId
            FROM MessagingSession 
            WHERE Case.Status != 'Closed' AND Case.Type = 'Execução' AND Status = 'Ended' 
            LIMIT 2000
        ];

        List<SObject> listRetorno = new List<SObject>();

        

        listRetorno.addAll(listTranscript);
        listRetorno.addAll(listMessaging);

        System.debug(listTranscript);
        System.debug(listMessaging);

        return listRetorno;
    }

    global void execute(Database.BatchableContext bc, list<SObject> records){
        try {
        List<Case> listToUpdate = new List<Case>();
       	Set<Id> setCaseId = new Set<Id>();
        
        for (SObject item: records) {           
            switch on String.valueOf(item.getSObjectType()) {
                when 'LiveChatTranscript' {
                    LiveChatTranscript transcript = (LiveChatTranscript) item;
                    setCaseId.add(String.valueOf(transcript.CaseId));
                }
                when 'MessagingSession' {
                    MessagingSession messaging = (MessagingSession) item;
                    setCaseId.add(String.valueOf(messaging.CaseId));
                }
            }
        }
        
        for(Id idCaso : setCaseId){
        	Case caso = new Case();
            caso.Id = idCaso;
        	caso.Status = 'Closed';
        	listToUpdate.add(caso);
        }

        
        for(Case caso : listToUpdate){
            System.debug('Antes: ' + caso.Id);
            System.debug('Antes: ' + caso.ProcessadoPeloBatch__c);
            caso.ProcessadoPeloBatch__c = true;
            System.debug('Depois: ' + caso.ProcessadoPeloBatch__c);
        }
        
        if (listToUpdate.size() > 0) {
            update listToUpdate;
        }
        }

        catch (Exception e) {
                // Log the error message
            System.debug('Error Message: ' + e.getMessage());
                // Log the stack trace
            System.debug('Stack Trace: ' + e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext bc){

    }
}