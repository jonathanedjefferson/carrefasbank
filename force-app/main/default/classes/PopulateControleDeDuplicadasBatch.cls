global class PopulateControleDeDuplicadasBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, NumeroConta__c FROM ContaFinanceira__c');
    }

    global void execute(Database.BatchableContext bc, List<ContaFinanceira__c> scope) {
        List<ControleDeDuplicadas__c> controles = new List<ControleDeDuplicadas__c>();
        Integer batchSize = 200;
        
        // Loop para criar os registros no objeto ControleDeDuplicadas__c
        for (ContaFinanceira__c conta : scope) {
            ControleDeDuplicadas__c controle = new ControleDeDuplicadas__c(
                IdContaDuplicada__c = conta.Id,
                NumeroConta__c = conta.NumeroConta__c,
                Processado__c = false
            );
            controles.add(controle);

            // Inserir registros em lotes para evitar limite de governança
            if (controles.size() == batchSize) {
                processInsert(controles);
                controles.clear();
            }
        }
        
        // Inserir os registros restantes
        if (!controles.isEmpty()) {
            processInsert(controles);
        }
    }

    private void processInsert(List<ControleDeDuplicadas__c> controles) {
        try {
            Database.SaveResult[] results = Database.insert(controles, false);
            
            // Verificar os resultados
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Erro ao inserir registro: ' + results[i].getErrors()[0].getMessage());
                }
            }
        } catch (Exception e) {
            System.debug('Erro inesperado durante o insert: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch PopulateControleDeDuplicadasBatch concluído com sucesso.');
    }
}