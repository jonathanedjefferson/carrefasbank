global class PontoContatoTelefoneBatch implements Database.Batchable<sObject> {
    /***********************************************************************************
	* @Description: Método para iniciar o batch sem especificar o tamanho de cada lote *
	************************************************************************************/
    global static void start() {
		Database.executeBatch(new PontoContatoTelefoneBatch());
	}

    /*********************************************************************************
	* @Description: Método para iniciar o batch especificando o tamanho de cada lote *
	* @Params: Integer batchSize - Número que representa o tamanho de cada lote      *
	**********************************************************************************/
	global static void start(Integer batchSize) {
		Database.executeBatch(new PontoContatoTelefoneBatch(), batchSize);
	}

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ContaFinanceira__c, Telefone__c FROM PontoContatoTelefone__c WHERE LastModifiedDate >= YESTERDAY';
        
        PontoContato__c pontoContato = PontoContato__c.getInstance('PontoContato');
        if (pontoContato != null) {
            if (pontoContato.TodosRegistros__c) {
                query = 'SELECT ContaFinanceira__c, Telefone__c FROM PontoContatoTelefone__c';
            }
        }

        return Database.getQueryLocator(query);    
    }

    global void execute(Database.BatchableContext BC, list<PontoContatoTelefone__c> records){   
        System.debug('-------> '+ records.size());
        Map<Id, String> mapIdTelefone = new Map<Id, String>();        
        Set<Id> setContaFinanceira = new Set<Id>();

        for (PontoContatoTelefone__c item: records) {
            setContaFinanceira.add(item.ContaFinanceira__c);
            mapIdTelefone.put(item.ContaFinanceira__c, item.Telefone__c);
        }

        PontoContatoEmailTelefoneBO.UpdateTelefoneContaFinanceira(setContaFinanceira, mapIdTelefone);
    }
    
    global void finish(Database.BatchableContext BC){

    }
}