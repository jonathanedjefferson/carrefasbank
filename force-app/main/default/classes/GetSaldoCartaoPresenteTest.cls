@isTest
public class GetSaldoCartaoPresenteTest {
    @isTest 
    public static void getSaldoSucess() {
        FlowGetSaldoCartaoPresente.Input input = new FlowGetSaldoCartaoPresente.Input();
        input.brand = 'CARREFOUR';
        input.numeroCartao = '5041615642379869';
        input.senha = '2985';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Get Saldo Catao Presente');
        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            config.Endpoint__c.replace('{numeroCartao}', input.numeroCartao).replace('{senha}', input.senha), 
            'Sucesso', 
            '{"id":"5041615642379869-2985","balance":100.0,"emissionDate":"2026-08-07 23:59:59","expiringDate":"2026-08-07 23:59:59"}',
            200,
            new Map<String,String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<FlowGetSaldoCartaoPresente.Output> retorno = FlowGetSaldoCartaoPresente.getSaldo(new List<FlowGetSaldoCartaoPresente.Input>{input});
        Test.stopTest();

        System.assertEquals('5041615642379869-2985', retorno[0].id);
        System.assertEquals('Success', retorno[0].statusMessage);
    }

    @isTest 
    public static void getSaldoError() {
        FlowGetSaldoCartaoPresente.Input input = new FlowGetSaldoCartaoPresente.Input();
        input.brand = 'CARREFOUR';
        input.numeroCartao = '5041615642379869';
        input.senha = '2985';

        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Get Saldo Catao Presente');
        MockGeneric mock = new MockGeneric();
        mock.CreateMock(
            config.Endpoint__c.replace('{numeroCartao}', input.numeroCartao).replace('{senha}', input.senha), 
            'Erroe', 
            '{"timestamp":"2025-08-25T17:21:20.424+00:00","status":422,"error":"Unprocessable Entity","message":"error [422] trying to contact with customer tools: The card is expired.","path":"/v1/card/cartao-presente"}',
            422,
            new Map<String,String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<FlowGetSaldoCartaoPresente.Output> retorno = FlowGetSaldoCartaoPresente.getSaldo(new List<FlowGetSaldoCartaoPresente.Input>{input});
        Test.stopTest();

        System.assertEquals('error [422] trying to contact with customer tools: The card is expired.', retorno[0].statusMessage);
    }
}