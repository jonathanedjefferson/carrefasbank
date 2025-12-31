@isTest
private class CloseTabEndChatControllerTest {
    @isTest 
    static void getMinutosTest() {
        Test.startTest();
        Decimal minutos = CloseTabEndChatController.getMinutos();
        Test.stopTest();
        System.assertNotEquals(0, minutos);
        System.assertNotEquals(null, minutos);
    }
}