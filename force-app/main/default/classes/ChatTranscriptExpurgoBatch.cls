/****************************************************************************************************
*   @Author: Everymind                                                                              *
*   @Date: 16/04/2025                                                                               *
*   @Description: Classe Batch para expurgo de registros do objeto LiveChatTranscript               *
*****************************************************************************************************/
global class ChatTranscriptExpurgoBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    /****************************************************************************************************
	*   @Description: Método para iniciar o batch sem especificar o tamanho de cada lote                *
	*****************************************************************************************************/
	global static void start() {
		Database.executeBatch(new ChatTranscriptExpurgoBatch());
	}

	/****************************************************************************************************
	*   @Description: Método para iniciar o batch especificando o tamanho de cada lote                  *
	*   @Params: Integer batchSize - Número que representa o tamanho de cada lote                       *
	*****************************************************************************************************/
	global static void start(Integer batchSize) {
		Database.executeBatch(new ChatTranscriptExpurgoBatch(), batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoLiveChatTranscript');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));

        return Database.getQueryLocator('SELECT Id, CreatedDate FROM LiveChatTranscript WHERE CreatedDate < :dataLimite');
    }

	global void execute(Database.BatchableContext BC, List<LiveChatTranscript> lstEvents) { 
		if(!lstEvents.isEmpty()){
			Delete lstEvents;
		}
    }

	global void finish(Database.BatchableContext BC) {}
}