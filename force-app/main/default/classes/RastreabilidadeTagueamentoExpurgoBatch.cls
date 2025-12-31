/**
 * @Author: Everymind
 * @Date: 13/03/2023
 * @Description: Classe Batch para expurgo de registros do objeto RastreabilidadeTagueamento 
 */
global without sharing class RastreabilidadeTagueamentoExpurgoBatch implements Database.Batchable<sObject>, Database.Stateful {

	/**
	 * @Description: Método para iniciar o batch sem especificar o tamanho de cada lote
	 */
	global static void start() {
		Database.executeBatch(new RastreabilidadeTagueamentoExpurgoBatch());
	}

	/**
	 * @Description: Método para iniciar o batch especificando o tamanho de cada lote
	 * @Params: Integer batchSize - Número que representa o tamanho de cada lote
	 */
	global static void start(Integer batchSize) {
		Database.executeBatch(new RastreabilidadeTagueamentoExpurgoBatch(), batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoRastreabilidade');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));

        return Database.getQueryLocator('SELECT ID, Tagueamento__c FROM RastreabilidadeTagueamento__c WHERE DataHora__c < :dataLimite');
    }

	global void execute(Database.BatchableContext BC, List<RastreabilidadeTagueamento__c> lstEvents) { 
		if(!lstEvents.isEmpty()){
			Delete lstEvents;
		}
    }

	global void finish(Database.BatchableContext BC) {}
}