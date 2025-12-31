global class MarkDuplicatesBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Selecionar registros que ainda não foram processados
        return Database.getQueryLocator(
            'SELECT Id, NumeroConta__c, Deletar__c, Processado__c FROM ControleDeDuplicadas__c WHERE Processado__c = false ORDER BY NumeroConta__c'

        );
    }

    global void execute(Database.BatchableContext bc, List<ControleDeDuplicadas__c> scope) {
        Map<String, List<ControleDeDuplicadas__c>> duplicateGroups = new Map<String, List<ControleDeDuplicadas__c>>();

        for (ControleDeDuplicadas__c controle : scope) {
            if (!duplicateGroups.containsKey(controle.NumeroConta__c)) {
                duplicateGroups.put(controle.NumeroConta__c, new List<ControleDeDuplicadas__c>());
            }
            duplicateGroups.get(controle.NumeroConta__c).add(controle);
        }

        // Atualizar flags de Processado__c e Deletar__c
        List<ControleDeDuplicadas__c> updates = new List<ControleDeDuplicadas__c>();
        for (List<ControleDeDuplicadas__c> duplicateGroup : duplicateGroups.values()) {
            if (duplicateGroup.size() > 1) {
                for (ControleDeDuplicadas__c controle : duplicateGroup) {
                    controle.Deletar__c = true;
                }
            }
            for (ControleDeDuplicadas__c controle : duplicateGroup) {
                controle.Processado__c = true;
            }
            updates.addAll(duplicateGroup);
        }

        try {
            if (!updates.isEmpty()) {
                update updates;
            }
        } catch (Exception e) {
            System.debug('Erro ao atualizar registros: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch MarkDuplicatesBatch concluído com sucesso.');
    }
}