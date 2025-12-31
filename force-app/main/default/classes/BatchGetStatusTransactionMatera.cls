global with sharing class BatchGetStatusTransactionMatera implements Database.Batchable<Case>, Database.AllowsCallouts, Schedulable {
    private static final Id MATERA_QUEUEID;
    private static final Set<String> CASE_SUBJECTS;
    private static final Set<String> CASE_EVENTS;
    static {
        List<QueueSObject> lLstQueueMatera = [SELECT QueueId FROM QueueSObject WHERE Queue.DeveloperName = 'Matera'];
        MATERA_QUEUEID = lLstQueueMatera[0].QueueId;

        CASE_SUBJECTS = new Set<String>{'Pagamento', 'Desenrola'};
        CASE_EVENTS = new Set<String>{'Reembolso', 'Devolução desenrola'};
    }

    //Batchable Interface
    global List<Case> start(Database.BatchableContext bc) {
        List<Case> lLstCase = [SELECT Id, Finalizacao__c, Status, IdLiquidacaoFinanceiraMatera__c FROM Case 
            WHERE OwnerId =: MATERA_QUEUEID AND Assunto__c IN: CASE_SUBJECTS 
            AND Evento__c IN: CASE_EVENTS AND Finalizacao__c = null AND IdLiquidacaoFinanceiraMatera__c != null
            AND Status = 'Em tratativa'];

        return lLstCase;
    }

    global void execute(Database.BatchableContext bc, List<Case> contextData) {
        if (!checkAvailableTime()) {
            return;
        }

        for (Case iCase : contextData) {
            IntegrationMatera.StatusTransaction response = IntegrationMatera.getTransactionStatus(iCase.IdLiquidacaoFinanceiraMatera__c, 'Cockpit');

            if ('ERROR'.equals(response.statusAPI)) {
                continue;
            }

            updateCaseStatus(iCase, response);
        }

        Database.update(contextData);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Execução da consulta do status da transação no Matera finalizado!');
    }

    //Schedulable Interface
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchGetStatusTransactionMatera(), 1);
    }

    global static String runSchedule() {
        Datetime lDtCron = System.now().addMinutes(5);
        // runs every day at 4AM
        String lCron = ((!Test.isRunningTest()) ? '0 0 4' : String.join(new Object[]{ lDtCron.second(), lDtCron.minute(), lDtCron.hour() }, ' ')) + ' * * ?';
        String lJobName = 'Consulta Status Liquidação Financeira - Matera' + (Test.isRunningTest() ? lDtCron.format('yyyyMMddHHmmss') : '');
        return System.schedule(lJobName, lCron, new BatchGetStatusTransactionMatera());
    }

    private Boolean checkAvailableTime() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Integração Matera'];

        if (bh == null) {
            return false;
        }

        DateTime currentDateTime = DateTime.now().addHours(-3);

        return Test.isRunningTest() ? true : BusinessHours.isWithin(bh.Id, currentDateTime);
    }

    private void updateCaseStatus(Case iCase, IntegrationMatera.StatusTransaction response) {
        //Transação Cancelada
        if ('CANCELADO'.equalsIgnoreCase(response.statusAPI) && response.error[0].message.contains('não existe')) {
            iCase.Finalizacao__c = 'Devolvido';
            return;
        }

        String situacaoSPB = response.data.situacaoSPB;

        //Transação Rejeitada
        if ('DOC DEVOLVIDO PELO SPB'.equalsIgnoreCase(situacaoSPB)) {
            iCase.Finalizacao__c = 'Devolvido';
            return;
        }

        //Transação aprovada
        if ('CONCLUIDO'.equalsIgnoreCase(situacaoSPB)) {
            iCase.Finalizacao__c = 'Liquidado';
            iCase.Status = 'Closed';
            return;
        }

        //Caso não se enquadre em nenhum status será considerado pendente
        return;
    }
}