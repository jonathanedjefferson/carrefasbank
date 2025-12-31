global class ExpurgoCalendarioFrasesBatch implements Database.Batchable<sObject> {
    global static void start(){
        Database.executeBatch(new ExpurgoCalendarioFrasesBatch());
    }

    global static void start(Integer batchSize){
        Database.executeBatch(new ExpurgoCalendarioFrasesBatch(), batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, DataString__c, CreatedDate FROM CalendarioCarinaFrasesSaudacao__c');
    }
    
    global void execute(Database.BatchableContext bc, List<CalendarioCarinaFrasesSaudacao__c> listaCalendarios) {
        List<CalendarioCarinaFrasesSaudacao__c> listaExpurgo = new List<CalendarioCarinaFrasesSaudacao__c>();
        Date dataAtual = System.today();
        Integer mesAtual = dataAtual.month();

        for(CalendarioCarinaFrasesSaudacao__c objCalendario: listaCalendarios) {
            List<String> partesData = objCalendario.DataString__c.split('/');
            Integer mesCalendario = Integer.valueOf(partesData[1]);

            if(mesCalendario <= (mesAtual - 2)) {
                listaExpurgo.add(objCalendario);
            }
        }

        DELETE listaExpurgo;
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('ExpurgoCalendarioFrasesBatch rodou corretamente!');
    }
}