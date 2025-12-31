public with sharing class CalendarioCarinaTriggerHandler {
    public static void handle(List <CalendarioCarinaFrasesSaudacao__c> listaItens) {
        List<Emoji_Calendario__c> emojis = [SELECT Id, Name, Emoji__c FROM Emoji_Calendario__c];
        for(CalendarioCarinaFrasesSaudacao__c calendarioItem: listaItens) {
            String frase = calendarioItem.Frase2__c;

            for(Emoji_Calendario__c item: emojis) {
                frase = frase.replace(item.Name, item.Emoji__c);
            }

            calendarioItem.Frase2__c = frase;
        }
    }
}