trigger LogIntegracaoEventTrigger on LogIntegracaoEvent__e (after insert) {
    List<LogIntegracao__c> listLogsInsert = new List<LogIntegracao__c>();
    
    for (LogIntegracaoEvent__e item: Trigger.New) {
        LogIntegracao__c log = new LogIntegracao__c();
        log.NomeServico__c = item.NomeServico__c;
        log.URL__c = item.URL__c;
        log.Metodo__c = item.Metodo__c;
        log.RequestBody__c = item.RequestBody__c;
        log.CPF__c = item.CPF__c;
        log.Status__c = item.Status__c;
        log.ResponseBody__c = item.ResponseBody__c;
        log.UnidadeNegocio__c = item.UnidadeNegocio__c;
        log.Canal__c = item.Canal__c;
        log.UsuarioId__c = item.UserId__c;
        log.RequestHeaders__c = item.RequestHeaders__c;
        
        listLogsInsert.add(log);
    }

    insert listLogsInsert;
}