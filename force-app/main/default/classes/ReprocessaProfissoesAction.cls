public class ReprocessaProfissoesAction {
    @invocableMethod(label='Reprocessar Profissões')
    public static void manageActions(){
       Database.executeBatch(new ScheduleGetProfessions());
    }
}