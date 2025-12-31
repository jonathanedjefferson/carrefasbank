/****************************************************************************************************************
*   @Author: Everymind                                                                                          *
*   @Date: 20/12/2023                                                                                           *
*   @Description: Classe Batch para expurgo de registros do objeto ContentDocument que inciam com  'varejonf'   *
****************************************************************************************************************/
global class ExpurgoFileVarejoBatch implements Database.Batchable<sObject> {

    /****************************************************************************************************
	*   @Description: Método para iniciar o batch sem especificar o tamanho de cada lote                *
	*****************************************************************************************************/
    global static void start(){
        Database.executeBatch(new ExpurgoFileVarejoBatch());
    }

    /****************************************************************************************************
	*   @Description: Método para iniciar o batch especificando o tamanho de cada lote                  *
	*   @Params: Integer batchSize - Número que representa o tamanho de cada lote                       *
	*****************************************************************************************************/
    global static void start(Integer batchSize){
        Database.executeBatch(new ExpurgoFileVarejoBatch(), batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        PeriodoBatchExpurgo__c ultimosDias = PeriodoBatchExpurgo__c.getInstance('DiasExpurgoContentDocument');
        Date dataLimite = Date.today().addDays(-Integer.valueOf(ultimosDias.DiasExpurgo__c));
        return Database.getQueryLocator('SELECT Id, Title, CreatedDate FROM ContentDocument WHERE CreatedDate < :dataLimite');
    }
    
    global void execute(Database.BatchableContext bc, List<ContentDocument> listResult) {
        List<ContentDocument> listDocumentDelet = new List<ContentDocument>();
        
        for (ContentDocument item: listResult) {
            if(item.Title.toUpperCase().startsWith('VAREJONF')){
                listDocumentDelet.add(item);
            }
        }

        if (listDocumentDelet.size() > 0) {
            delete listDocumentDelet;
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
}