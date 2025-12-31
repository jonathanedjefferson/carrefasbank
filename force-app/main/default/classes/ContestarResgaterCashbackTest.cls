@isTest
private class ContestarResgaterCashbackTest {

    @isTest
    static void contestarResgateSucessoTest() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback'); // token
        calloutMock.addResponse(200); // sucesso

        Test.setMock(HttpCalloutMock.class, calloutMock);

        ContestarResgaterCashback.Input input = new ContestarResgaterCashback.Input();
        input.cpf = '32967501263';
        input.canal = 'Cockpit';
        input.unidadeNegocio = '';
        input.idTransacao = '123456';

        Test.startTest();
        List<ContestarResgaterCashback.Output> retorno =
            ContestarResgaterCashback.contestar(new List<ContestarResgaterCashback.Input>{ input });
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(true, retorno[0].sucesso);
        System.assertEquals('Contestação realizada com sucesso.', retorno[0].mensagem);
        System.assertEquals(false, retorno[0].erroData);
    }

    @isTest
    static void contestarResgateErro422Test() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback'); // token
        calloutMock.addResponse(422, 'MockContestacaoCashback'); // sem body => erroData não ativa

        Test.setMock(HttpCalloutMock.class, calloutMock);

        ContestarResgaterCashback.Input input = new ContestarResgaterCashback.Input();
        input.cpf = '11122233344';
        input.canal = 'Cockpit';
        input.unidadeNegocio = '1';
        input.idTransacao = 'TRX422';

        Test.startTest();
        List<ContestarResgaterCashback.Output> retorno =
            ContestarResgaterCashback.contestar(new List<ContestarResgaterCashback.Input>{ input });
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(false, retorno[0].sucesso);
        System.assertEquals(true, retorno[0].erroData);
    }

    @isTest
    static void contestarResgateErro500SemBodyTest() {
        MultiHttpCalloutMock calloutMock = new MultiHttpCalloutMock();
        calloutMock.addResponse(200, 'MockTokenCashback'); // token
        calloutMock.addResponse(500); // erro genérico

        Test.setMock(HttpCalloutMock.class, calloutMock);

        ContestarResgaterCashback.Input input = new ContestarResgaterCashback.Input();
        input.cpf = '00000000000';
        input.canal = 'Cockpit';
        input.unidadeNegocio = null;
        input.idTransacao = 'TRX999';

        Test.startTest();
        List<ContestarResgaterCashback.Output> retorno =
            ContestarResgaterCashback.contestar(new List<ContestarResgaterCashback.Input>{ input });
        Test.stopTest();

        System.assertEquals(1, retorno.size());
        System.assertEquals(false, retorno[0].sucesso);
        System.assertEquals(false, retorno[0].erroData);
        System.assert(retorno[0].mensagem.startsWith('Não foi possível contestar o resgate:'),
            'Esperava mensagem genérica iniciando com "Não foi possível contestar o resgate:"');
    }
}