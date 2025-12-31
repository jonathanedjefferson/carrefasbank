/************************************************************************************************************
*   @Author: Everymind                                                                                      *
*   @Date: 25/05/2023                                                                                       *
*   @Description: Classe Batch para expurgo de registros do objeto ContentDocument que inciam com  'fatura' *
************************************************************************************************************/
global class ContentDocumentExpurgoBatch implements Database.Batchable<sObject>, Database.Stateful {

     /****************************************************************************************************
	*   @Description: Método para iniciar o batch sem especificar o tamanho de cada lote                *
	*****************************************************************************************************/
	global static void start() {
		Database.executeBatch(new ContentDocumentExpurgoBatch());
	}

	/****************************************************************************************************
	*   @Description: Método para iniciar o batch especificando o tamanho de cada lote                  *
	*   @Params: Integer batchSize - Número que representa o tamanho de cada lote                       *
	*****************************************************************************************************/
	global static void start(Integer batchSize) {
		Database.executeBatch(new ContentDocumentExpurgoBatch(), batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoContentDocument');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));
        return Database.getQueryLocator('SELECT Id, CreatedDate, Title FROM ContentDocument WHERE CreatedDate < :dataLimite');
    }

	global void execute(Database.BatchableContext BC, List<ContentDocument> lstContentDocument) { 
        List<ContentDocument> lstDocumentosDeletar = new List<ContentDocument>();

        for(ContentDocument document : lstContentDocument){
            if(document.Title.toUpperCase().startsWith('FATURA')){
                lstDocumentosDeletar.add(document);
            }
        }

        if(!lstDocumentosDeletar.isEmpty()){
            delete lstDocumentosDeletar;
        }
    }

	global void finish(Database.BatchableContext BC) {}
}