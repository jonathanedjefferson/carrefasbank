@isTest
public class BlindagemCPFTest {

    @isTest
    public static void listarClientesTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemListarClientes');
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputFiltroListarCLientes filtro = new BlindagemTO.InputFiltroListarCLientes();
        filtro.tipoFiltro = 1;
        filtro.valor = '12345678900';

        Test.startTest();
        BlindagemTO.RetornoListarClientesBlindados retorno = BlindagemCPFController.listarClientes(filtro, 10, 1, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void listarClientesTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputFiltroListarCLientes filtro = new BlindagemTO.InputFiltroListarCLientes();
        filtro.tipoFiltro = 1;
        filtro.valor = '12345678900';

        Test.startTest();
        BlindagemTO.RetornoListarClientesBlindados retorno = BlindagemCPFController.listarClientes(filtro, 10, 1, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void obterClienteTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemObterCliente');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        BlindagemTO.RetornoClienteBlindado retorno = BlindagemCPFController.obterCliente('12345678900', 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void obterClienteTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        BlindagemTO.RetornoClienteBlindado retorno = BlindagemCPFController.obterCliente('12345678900', 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void criarClienteTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemCriarCliente');
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputCriarClienteBlindado cliente = new BlindagemTO.InputCriarClienteBlindado();
        cliente.cpf = '12345678900';
        cliente.nome = 'Teste';
        cliente.usuario = 'tester';
        cliente.descricao = 'desc';
        cliente.fullBlindagem = true;
        cliente.siglaUnidadeNegocio = 1;

        Test.startTest();
        BlindagemTO.RetornoCriarClienteBlindado retorno = BlindagemCPFController.criarCliente(cliente, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.isTrue(retorno.criadoComSucesso);
    }

    @isTest
    public static void criarClienteTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputCriarClienteBlindado cliente = new BlindagemTO.InputCriarClienteBlindado();
        cliente.cpf = '12345678900';
        cliente.nome = 'Teste';
        cliente.usuario = 'tester';
        cliente.descricao = 'desc';
        cliente.fullBlindagem = true;
        cliente.siglaUnidadeNegocio = 1;

        Test.startTest();
        BlindagemTO.RetornoCriarClienteBlindado retorno = BlindagemCPFController.criarCliente(cliente, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void criarClientesMassaTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemCriarClientesMassa');
        Test.setMock(HttpCalloutMock.class, mock);

        List<BlindagemTO.InputCriarClienteBlindado> clientes = new List<BlindagemTO.InputCriarClienteBlindado>();
        for(Integer i = 0; i < 2; i++) {
            BlindagemTO.InputCriarClienteBlindado cliente = new BlindagemTO.InputCriarClienteBlindado();
            cliente.cpf = '1234567890' + i;
            cliente.nome = 'Cliente ' + i;
            cliente.usuario = 'user' + i;
            cliente.descricao = 'desc';
            cliente.fullBlindagem = true;
            cliente.siglaUnidadeNegocio = 1;
            clientes.add(cliente);
        }

        Test.startTest();
        BlindagemTO.RetornoOperacaoEmMassa retorno = BlindagemCPFController.criarClientesMassa(clientes, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void criarClientesMassaTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        List<BlindagemTO.InputCriarClienteBlindado> clientes = new List<BlindagemTO.InputCriarClienteBlindado>();
        for(Integer i = 0; i < 2; i++) {
            BlindagemTO.InputCriarClienteBlindado cliente = new BlindagemTO.InputCriarClienteBlindado();
            cliente.cpf = '1234567890' + i;
            cliente.nome = 'Cliente ' + i;
            cliente.usuario = 'user' + i;
            cliente.descricao = 'desc';
            cliente.fullBlindagem = true;
            cliente.siglaUnidadeNegocio = 1;
            clientes.add(cliente);
        }

        Test.startTest();
        BlindagemTO.RetornoOperacaoEmMassa retorno = BlindagemCPFController.criarClientesMassa(clientes, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void removerClienteTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemRemoverCliente');
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputRemoverClienteBlindado cliente = new BlindagemTO.InputRemoverClienteBlindado();
        cliente.cpf = '12345678900';
        cliente.usuario = 'tester';
        cliente.siglaUnidadeNegocio = 1;

        Test.startTest();
        BlindagemTO.RetornoRemoverBlindagem retorno = BlindagemCPFController.removerCliente(cliente, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
        Assert.isTrue(retorno.sucesso);
    }

    @isTest
    public static void removerClienteTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        BlindagemTO.InputRemoverClienteBlindado cliente = new BlindagemTO.InputRemoverClienteBlindado();
        cliente.cpf = '12345678900';
        cliente.usuario = 'tester';
        cliente.siglaUnidadeNegocio = 1;

        Test.startTest();
        BlindagemTO.RetornoRemoverBlindagem retorno = BlindagemCPFController.removerCliente(cliente, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }

    @isTest
    public static void removerClientesMassaTestOk() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(200, 'MockBlindagemRemoverClientesMassa');
        Test.setMock(HttpCalloutMock.class, mock);

        List<BlindagemTO.InputRemoverClienteBlindado> clientes = new List<BlindagemTO.InputRemoverClienteBlindado>();
        for(Integer i = 0; i < 2; i++) {
            BlindagemTO.InputRemoverClienteBlindado cliente = new BlindagemTO.InputRemoverClienteBlindado();
            cliente.cpf = '1234567890' + i;
            cliente.usuario = 'user' + i;
            cliente.siglaUnidadeNegocio = 1;
            clientes.add(cliente);
        }

        Test.startTest();
        BlindagemTO.RetornoOperacaoEmMassa retorno = BlindagemCPFController.removerClientesMassa(clientes, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('OK', retorno.statusAPI);
    }

    @isTest
    public static void removerClientesMassaTestError() {
        MultiHttpCalloutMock mock = new MultiHttpCalloutMock();
        mock.addResponse(200, 'MockTokenServerToServer');
        mock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, mock);

        List<BlindagemTO.InputRemoverClienteBlindado> clientes = new List<BlindagemTO.InputRemoverClienteBlindado>();
        for(Integer i = 0; i < 2; i++) {
            BlindagemTO.InputRemoverClienteBlindado cliente = new BlindagemTO.InputRemoverClienteBlindado();
            cliente.cpf = '1234567890' + i;
            cliente.usuario = 'user' + i;
            cliente.siglaUnidadeNegocio = 1;
            clientes.add(cliente);
        }

        Test.startTest();
        BlindagemTO.RetornoOperacaoEmMassa retorno = BlindagemCPFController.removerClientesMassa(clientes, 'Cockpit');
        Test.stopTest();

        Assert.areEqual('ERROR', retorno.statusAPI);
    }
}