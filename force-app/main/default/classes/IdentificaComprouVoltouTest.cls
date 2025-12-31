@isTest
private class IdentificaComprouVoltouTest {
    @isTest
    private static void identificaClienteComprouVoltouSuccessCashback() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF2');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '32967501263';
        input.phone = '5561999624307';
        input.bussinessUnit = '1';
        input.origin = 'Whatsapp';
        
        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('OK', lLstOutputs[0].statusAPI, 'A execução deve retornar sucesso');
        Assert.areEqual(true, lLstOutputs[0].hasComprouVoltou, 'O cliente Comprou Voltou deve ser identificado quando há contratos ativos para o produto');
        Assert.areEqual('Ativo', lLstOutputs[0].contractStatus, 'Deve retornar o status da contratação quando há contratos cashback ativos para o cliente');
        Assert.areEqual(true, lLstOutputs[0].hasCreditCard, 'Deve retornar true quando identificar o cartão');
        Assert.areEqual(true, lLstOutputs[0].hasSecurityPhone, 'Deve retornar true quando identificar o celular seguro correspondente');
        Assert.areEqual(true, lLstOutputs[0].hasAccessToApp, 'Deve retornar true quando o status correspondente ao cartão estiver dentro do permitido');
    }

    @isTest
    private static void identificaClienteComprouVoltouNotFoundCashback() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '48283917200';
        input.phone = '55932761946';
        input.bussinessUnit = '1';
        input.origin = 'Whatsapp';
        
        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('OK', lLstOutputs[0].statusAPI, 'A execução deve retornar sucesso');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'O cliente Comprou Voltou não será identificado quando não há contratos ativos para o produto');
        Assert.isNull(lLstOutputs[0].contractStatus, 'Não deve retornar o status da contratação quando não for identificado contrato cashback');
        Assert.areEqual(false, lLstOutputs[0].hasCreditCard, 'Deve retornar false quando não for identificado cartão');
        Assert.areEqual(false, lLstOutputs[0].hasSecurityPhone, 'Deve retornar false quando não houver contatos para avaliar');
        Assert.areEqual(false, lLstOutputs[0].hasAccessToApp, 'Deve retornar false quando não for identificado cartão');
    }

    @isTest
    private static void identificaClienteComprouVoltouIntegrationError() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(500);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '15909189085';
        input.phone = '5561999624307';
        input.bussinessUnit = '1';
        input.origin = 'Whatsapp';

        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('ERROR', lLstOutputs[0].statusAPI, 'A execução deve retornar falha quando há erros na integração');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Não irá executar quando há falhas');
    }

    @isTest
    private static void identificaClienteComprouVoltouNotFound() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(404);

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '15909189085';
        input.phone = '5561999624307';
        input.bussinessUnit = '1';
        input.origin = 'Whatsapp';

        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('NOTFOUND', lLstOutputs[0].statusAPI, 'A execução deve retornar falha quando há erros na integração');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Não irá executar quando há falhas');
    }

    @isTest
    private static void identificaClienteComprouVoltouEmptyContracts() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitByCPF5');

        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '38698970079';
        input.phone = '5561999624307';
        input.bussinessUnit = '1';
        input.origin = 'Whatsapp';

        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('OK', lLstOutputs[0].statusAPI, 'A execução deve retornar sucesso na execução');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Deve retornar false quando não há contratos a serem avaliados');
        Assert.isNull(lLstOutputs[0].contractStatus, 'Não deve retornar o status da contratação quando não há contratos a serem avaliados');
    }

    @isTest
    private static void identificaClienteComprouVoltouEmptyParams() {
        IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '';
        input.phone = '';
        input.bussinessUnit = '';
        input.origin = 'Whatsapp';
        
        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('ERROR', lLstOutputs[0].statusAPI, 'A execução deve retornar falha quando o CPF não é informado');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Não irá executar quando o CPF estiver vazio');
    }

    @isTest
    private static void identificaClienteComprouVoltouEmptyInput() {
        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>());
        Test.stopTest();

        Assert.areEqual('ERROR', lLstOutputs[0].statusAPI, 'A execução deve retornar falha quando não há inputs inseridos');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Não irá executar quando não há inputs');
    }

    @isTest
    private static void identificaClienteComprouVoltouEmptyInputChat() {
       IdentificaComprouVoltou.Input input = new IdentificaComprouVoltou.Input();
        input.cpf = '';
        input.phone = '';
        input.bussinessUnit = '';
        input.origin = 'Chat';
        
        Test.startTest();
        List<IdentificaComprouVoltou.Output> lLstOutputs = IdentificaComprouVoltou.identificaClienteComprouVoltou(new List<IdentificaComprouVoltou.Input>{input});
        Test.stopTest();

        Assert.areEqual('ERROR', lLstOutputs[0].statusAPI, 'A execução deve retornar falha quando o CPF não é informado');
        Assert.areEqual(false, lLstOutputs[0].hasComprouVoltou, 'Não irá executar quando o CPF estiver vazio');
    }
}