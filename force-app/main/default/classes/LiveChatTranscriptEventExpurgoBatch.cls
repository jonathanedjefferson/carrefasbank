/**
 * @Author: Everymind
 * @Date: 17/01/2023
 * @Description: Classe Batch para expurgo de registros do objeto LiveChatTranscriptEvent 
 */
global without sharing class LiveChatTranscriptEventExpurgoBatch implements Database.Batchable<sObject>, Database.Stateful {

	/**
	 * @Description: Método para iniciar o batch sem especificar o tamanho de cada lote
	 */
	global static void start() {
		Database.executeBatch(new LiveChatTranscriptEventExpurgoBatch());
	}

	/**
	 * @Description: Método para iniciar o batch especificando o tamanho de cada lote
	 * @Params: Integer batchSize - Número que representa o tamanho de cada lote
	 */
	global static void start(Integer batchSize) {
		Database.executeBatch(new LiveChatTranscriptEventExpurgoBatch(), batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgo');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));

        return Database.getQueryLocator('SELECT ID, CreatedDate FROM LiveChatTranscriptEvent WHERE CreatedDate < :dataLimite');
    }

	global void execute(Database.BatchableContext BC, List<LiveChatTranscriptEvent> lstEvents) { 
		if(!lstEvents.isEmpty()){
			Delete lstEvents;
		}
    }

	global void finish(Database.BatchableContext BC) {}
}