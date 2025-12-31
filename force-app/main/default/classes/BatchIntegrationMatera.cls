global with sharing class BatchIntegrationMatera implements Database.Batchable<Case>, Database.AllowsCallouts, Schedulable{
    private static final Id MATERA_QUEUEID;
    private static final List<String> CASE_SUBJECTS;
    private static final List<String> CASE_EVENTS;
    static {
        List<QueueSObject> lLstQueueMatera = [SELECT QueueId FROM QueueSObject WHERE Queue.DeveloperName = 'Matera'];
        MATERA_QUEUEID = lLstQueueMatera[0].QueueId;

        List<CaseIntegrations__c> lLstSettings = [SELECT Assunto__c, Evento__c FROM CaseIntegrations__c WHERE Name = 'Matera' LIMIT 1];

        CASE_SUBJECTS = lLstSettings[0].Assunto__c.split(';');
        CASE_EVENTS = lLstSettings[0].Evento__c.split(';');
    }

    //Batchable Interface
    global List<Case> start(Database.BatchableContext bc) {
        List<Case> lLstCase = [SELECT Id, CaseNumber, Status, IdLiquidacaoFinanceiraMatera__c, Quantidade__c, DataHora__c,
            Banco__r.NumeroCodigo__c, NumeroAgencia__c, NumeroConta__c, DigitoConta__c, TipoConta__c, NomeCompleto__c, 
            NumeroDocumento__c, Valor__c, ContaDebitar__c FROM Case 
            WHERE OwnerId =: MATERA_QUEUEID AND Assunto__c IN: CASE_SUBJECTS 
            AND Evento__c IN: CASE_EVENTS AND IdLiquidacaoFinanceiraMatera__c = null
            AND Status = 'Em tratativa' AND (Quantidade__c = null OR Quantidade__c < 3)];

        return lLstCase;
    }

    global void execute(Database.BatchableContext bc, List<Case> contextData) {
        if (!checkAvailableTime()) {
            return;
        }

        for (Case iCase : contextData) {
            IntegrationMatera.SendTransactionResponse response = IntegrationMatera.sendDocTedMatera(iCase, 'Cockpit');
            if ('ERROR'.equals(response.statusAPI) || String.isBlank(response.data.idLiquidacao)) {
                iCase.Quantidade__c = iCase.Quantidade__c == null ? 1 : iCase.Quantidade__c + 1;
                iCase.DataHora__c = DateTime.now();
                continue;
            }

            iCase.IdLiquidacaoFinanceiraMatera__c = response.data.idLiquidacao;
            iCase.Quantidade__c = iCase.Quantidade__c == null ? 1 : iCase.Quantidade__c + 1;
            iCase.DataHora__c = DateTime.now();
        }

        Database.update(contextData);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Execução da Integração com o Matera finalizado!');
    }

    //Schedulable Interface
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchIntegrationMatera(), 1);
    }

    global static String runSchedule() {
        Datetime lDtCron = System.now().addMinutes(5);
        // runs every day at 7AM
        String lCron = ((!Test.isRunningTest()) ? '0 0 7' : String.join(new Object[]{ lDtCron.second(), lDtCron.minute(), lDtCron.hour() }, ' ')) + ' * * ?';
        String lJobName = 'Envio Liquidação Financeira - Matera' + (Test.isRunningTest() ? lDtCron.format('yyyyMMddHHmmss') : '');
        return System.schedule(lJobName, lCron, new BatchIntegrationMatera());
    }

    private Boolean checkAvailableTime() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Integração Matera'];

        if (bh == null) {
            return false;
        }

        DateTime currentDateTime = DateTime.now().addHours(-3);

        return Test.isRunningTest() ? true : BusinessHours.isWithin(bh.Id, currentDateTime);
    }
}