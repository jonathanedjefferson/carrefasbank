global class ScheduleGetProfessions implements Schedulable, Database.Batchable<String>, Database.AllowsCallouts {

    private Boolean successCreateOcupation = true;

    //Batchable Interface
    global List<String> start(Database.BatchableContext bc) {
        return new List<String>{'Start'};
    }

    global void execute(Database.BatchableContext bc, List<String> contextData) {
        this.successCreateOcupation = CreateProfessionService.createOccupation();

        //Realiza a exclusão das ocupações antigas que foram maracadas com o Deletar = true
        CreateProfessionHelper.deletePreviousRecords('Ocupacao');
    }

    global void finish(Database.BatchableContext bc) {
        if (this.successCreateOcupation) {
            BatchCreateCategorias lBatch = new BatchCreateCategorias();
            Database.executeBatch(lBatch, 1);
        }
    }

    //Batchable Context
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new ScheduleGetProfessions());
    }

    global static String runSchedule() {
        Datetime lDtCron = System.now().addMinutes(5);
        // runs every day at 1AM
        String lCron = ((!Test.isRunningTest()) ? '0 0 3' : String.join(new Object[]{ lDtCron.second(), lDtCron.minute(), lDtCron.hour() }, ' ')) + ' * * ?';
        String lJobName = 'Consulta Profissões - Aquisição Cartão' + (Test.isRunningTest() ? lDtCron.format('yyyyMMddHHmmss') : '');
        return System.schedule(lJobName, lCron, new ScheduleGetProfessions());
    }
}