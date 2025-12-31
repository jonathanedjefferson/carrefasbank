@isTest
private class CalendarioCarinaTriggerHandlerTest {
    @isTest
    static void testHandleMethod() {
        // Create test data
        List<CalendarioCarinaFrasesSaudacao__c> testItems = new List<CalendarioCarinaFrasesSaudacao__c>();
        testItems.add(new CalendarioCarinaFrasesSaudacao__c(Frase2__c = 'Hello, {Name}!'));
        testItems.add(new CalendarioCarinaFrasesSaudacao__c(Frase2__c = 'Happy {Year}!'));

        List<Emoji_Calendario__c> testEmojis = new List<Emoji_Calendario__c>();
        testEmojis.add(new Emoji_Calendario__c(Name = '{Name}', Emoji__c = '🙂'));
        testEmojis.add(new Emoji_Calendario__c(Name = '{Year}', Emoji__c = '🎉'));

        // Insert test data
        insert testItems;
        insert testEmojis;

        // Call the handler method
        Test.startTest();
        CalendarioCarinaTriggerHandler.handle(testItems);
        Test.stopTest();
    }
}