@isTest
private class MelhorDiaCompraBotTest {
    @isTest
    public static void MelhorDiaCompraBotTestTrue() {
        Test.setMock(HttpCalloutMock.class, new MelhorDiaComprasHttpCalloutMock());
        
        MelhorDiaCompraBot.InputMelhorDia input = new MelhorDiaCompraBot.InputMelhorDia();
        input.CPF = '11111111111';
        input.Token = 'teste';
        input.Conta = '123456';
        input.canal = 'chat';

        List<MelhorDiaCompraBot.InputMelhorDia> inputList = new List<MelhorDiaCompraBot.InputMelhorDia> {input};
        Test.startTest();
        List<MelhorDiaCompraBot.OutputMelhorDia> outputList = MelhorDiaCompraBot.getMelhorDiaCompra(inputList);
        Test.stopTest();

        System.debug(outputList);

        System.assertEquals(true, outputList[0].statusMelhorDiaCompra);
    }
}