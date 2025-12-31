@isTest
private class AjusteCashbackTest {

    @isTest
    static void ajusteCashbackSucessoTest() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback');
        calloutMock.addResponse(200); // sucesso

        Test.setMock(HttpCalloutMock.class, calloutMock);

        AjusteCashback.Input input = new AjusteCashback.Input();
        input.cpf = '12345678900';
        input.canal = 'Cockpit';
        input.unidadeNegocio = '';
        input.idTransacao = 'ABC123';
        input.dueAmount = '100.50';
        input.dueAmountBank = '100.50';

        List<AjusteCashback.Input> inputs = new List<AjusteCashback.Input>{ input };

        Test.startTest();
        List<AjusteCashback.Output> retorno = AjusteCashback.ajustar(inputs);
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(true, retorno[0].sucesso);
        System.assertEquals('Ajuste realizado com sucesso.', retorno[0].mensagem);

        LogIntegracao__c log = [
            SELECT Id, CPF__c, Metodo__c, NomeServico__c 
            FROM LogIntegracao__c 
            WHERE CPF__c = '12345678900' 
            AND NomeServico__c = 'Ajuste de Cashback' 
            LIMIT 1
        ];
        System.assertEquals('Ajuste de Cashback', log.NomeServico__c);
    }

    @isTest
    static void ajusteCashbackErroGenericoTest() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback');
        calloutMock.addResponse(500); // erro

        Test.setMock(HttpCalloutMock.class, calloutMock);

        AjusteCashback.Input input = new AjusteCashback.Input();
        input.cpf = '99999999999';
        input.canal = 'Cockpit';
        input.unidadeNegocio = '';
        input.idTransacao = 'XYZ789';
        input.dueAmount = '150.00';
        input.dueAmountBank = '150.00';

        List<AjusteCashback.Input> inputs = new List<AjusteCashback.Input>{ input };

        Test.startTest();
        List<AjusteCashback.Output> retorno = AjusteCashback.ajustar(inputs);
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(false, retorno[0].sucesso);
        System.assert(retorno[0].mensagem.contains('Erro ao ajustar cashback'));

        LogIntegracao__c log = [
            SELECT Id, CPF__c, Metodo__c 
            FROM LogIntegracao__c 
            WHERE CPF__c = '99999999999' 
            AND NomeServico__c = 'Ajuste de Cashback' 
            LIMIT 1
        ];
        System.assertEquals('99999999999', log.CPF__c);
    }

    @isTest
    static void ajusteCashbackErroDataAtualTest() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback');
        calloutMock.addResponse(422, 'MockAjusteCashback');

        Test.setMock(HttpCalloutMock.class, calloutMock);

        AjusteCashback.Input input = new AjusteCashback.Input();
        input.cpf = '11122233344';
        input.canal = 'Cockpit';
        input.unidadeNegocio = 'RJ';
        input.idTransacao = 'DATAHOJE';
        input.dueAmount = '75.00';
        input.dueAmountBank = '70.00';

        List<AjusteCashback.Input> inputs = new List<AjusteCashback.Input>{ input };

        Test.startTest();
        List<AjusteCashback.Output> retorno = AjusteCashback.ajustar(inputs);
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(false, retorno[0].sucesso);
        System.assertEquals('Não é possível realizar o ajuste na data atual.', retorno[0].mensagem);

        LogIntegracao__c log = [
            SELECT Id, CPF__c, Metodo__c 
            FROM LogIntegracao__c 
            WHERE CPF__c = '11122233344' 
            AND NomeServico__c = 'Ajuste de Cashback' 
            LIMIT 1
        ];
        System.assertEquals('11122233344', log.CPF__c);
    }
}