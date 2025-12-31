global class UpdateCasesBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, IdContaDuplicada__c, NumeroConta__c FROM ControleDeDuplicadas__c WHERE Deletar__c = true');
    }

    global void execute(Database.BatchableContext bc, List<ControleDeDuplicadas__c> scope) {
        Map<String, String> originalAccounts = new Map<String, String>();

        // Encontrar as contas originais
        for (ControleDeDuplicadas__c controle : scope) {
            List<ContaFinanceira__c> accounts = [SELECT Id FROM ContaFinanceira__c WHERE NumeroConta__c = :controle.NumeroConta__c AND Id != :controle.IdContaDuplicada__c AND IdConta__c != NULL];
            if (!accounts.isEmpty()) {
                originalAccounts.put(controle.IdContaDuplicada__c, accounts[0].Id);
            }
        }

        // Atualizar os casos
        List<Case> casesToUpdate = new List<Case>();
        for (String duplicateId : originalAccounts.keySet()) {
            List<Case> cases = [SELECT Id FROM Case WHERE ContaFinanceira__c = :duplicateId];
            for (Case caseRecord : cases) {
                caseRecord.ContaFinanceira__c = originalAccounts.get(duplicateId);
                casesToUpdate.add(caseRecord);
            }
        }

        update casesToUpdate;
    }

    global void finish(Database.BatchableContext bc) {
    }
}