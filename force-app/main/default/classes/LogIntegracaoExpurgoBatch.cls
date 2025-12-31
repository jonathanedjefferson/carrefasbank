/****************************************************************************************************
*   @Author: Everymind                                                                              *
*   @Date: 25/05/2023                                                                               *
*   @Description: Classe Batch para expurgo de registros do objeto RastreabilidadeTagueamento       *
*****************************************************************************************************/
global class LogIntegracaoExpurgoBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    /****************************************************************************************************
	*   @Description: Método para iniciar o batch sem especificar o tamanho de cada lote                *
	*****************************************************************************************************/
	global static void start() {
		Database.executeBatch(new LogIntegracaoExpurgoBatch());
	}

	/****************************************************************************************************
	*   @Description: Método para iniciar o batch especificando o tamanho de cada lote                  *
	*   @Params: Integer batchSize - Número que representa o tamanho de cada lote                       *
	*****************************************************************************************************/
	global static void start(Integer batchSize) {
		Database.executeBatch(new LogIntegracaoExpurgoBatch(), batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoLogIntegracao');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));

        return Database.getQueryLocator('SELECT Id, CreatedDate FROM LogIntegracao__c WHERE CreatedDate < :dataLimite');
    }

	global void execute(Database.BatchableContext BC, List<LogIntegracao__c> lstEvents) { 
		if(!lstEvents.isEmpty()){
			Delete lstEvents;
		}
    }

	global void finish(Database.BatchableContext BC) {}
}