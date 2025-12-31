public with sharing class calculaProximoDiaUtil {
    public static Date proximoDiaUtil(Integer quantidadeDias, Date inicio) {
        //adiciona dias na data informada até chegar na quantidade de dias passados desejada
        while(quantidadeDias > 0) {
            inicio = inicio.addDays(1);

            //caso seja um dia útil
            if(!isWeekend(DateTime.newInstance(inicio.year(), inicio.month(), inicio.day())) && !isHoliday(inicio)) {
                quantidadeDias -= 1;
            }

        }

        return inicio;
    }
    
    private static Boolean isWeekend(Datetime checkDate) {
        if((checkDate.format('E').equals('Sat') || checkDate.format('E').equals('Sun'))) {
            return True;
        } 
        return False;
    }

    private static Boolean isHoliday(Date checkDate) {
        List<Holiday> holidays = [SELECT Id FROM Holiday WHERE ActivityDate = :checkDate];
        if(holidays.isEmpty()) {
            return False;
        }
        return True;
    }
}