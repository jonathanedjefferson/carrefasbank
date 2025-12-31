global class PontoContatoEmailBatch implements Database.Batchable<sObject> {
    /***********************************************************************************
	* @Description: Método para iniciar o batch sem especificar o tamanho de cada lote *
	************************************************************************************/
    global static void start() {
		Database.executeBatch(new PontoContatoEmailBatch());
	}

    /*********************************************************************************
	* @Description: Método para iniciar o batch especificando o tamanho de cada lote *
	* @Params: Integer batchSize - Número que representa o tamanho de cada lote      *
	**********************************************************************************/
	global static void start(Integer batchSize) {
		Database.executeBatch(new PontoContatoEmailBatch(), batchSize);
	}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ContaFinanceira__c, Email__c FROM PontoContatoEmail__c WHERE LastModifiedDate >= YESTERDAY';
        
        PontoContato__c pontoContato = PontoContato__c.getInstance('PontoContato');
        if (pontoContato != null) {
            if (pontoContato.TodosRegistros__c) {
                query = 'SELECT ContaFinanceira__c, Email__c FROM PontoContatoEmail__c';
            }
        }

        return Database.getQueryLocator(query);    
    }

    global void execute(Database.BatchableContext BC, list<PontoContatoEmail__c> records){   
        Map<Id, String> mapIdEmail = new Map<Id, String>();        
        Set<Id> setContaFinanceira = new Set<Id>();

        for (PontoContatoEmail__c item: records) {
            setContaFinanceira.add(item.ContaFinanceira__c);
            mapIdEmail.put(item.ContaFinanceira__c, item.Email__c);
        }

        PontoContatoEmailTelefoneBO.UpdateEmailContaFinanceira(setContaFinanceira, mapIdEmail);
    }
    
    global void finish(Database.BatchableContext BC){

    }
}