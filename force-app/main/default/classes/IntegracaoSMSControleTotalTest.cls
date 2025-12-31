@isTest 
public class IntegracaoSMSControleTotalTest {

    @isTest
    public static void consultarContratosSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockConsultarContratosSMSControle');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        IntegracaoSMSControleTotal.OutputConsultarContrato retorno = BCSF_cmp_SMSControleController.consultarContratos(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(1, retorno.contratos.size());
        System.assertEquals(1, retorno.produtos.size());
    }

    @isTest
    public static void consultarContratosErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400, 'MockConsultarContratosSMSControle');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canaL = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        IntegracaoSMSControleTotal.OutputConsultarContrato retorno = BCSF_cmp_SMSControleController.consultarContratos(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals('ERROR', retorno.statusResponse);
    }

    @isTest
    public static void adesaoContratoSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idProduto = '22323';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        String retorno = BCSF_cmp_SMSControleController.adesaoContrato(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals('OK', retorno);
    }

    @isTest
    public static void adesaoContratoErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idProduto = '22323';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        String retorno = BCSF_cmp_SMSControleController.adesaoContrato(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals('ERROR', retorno);
    }

    @isTest
    public static void adesaoContratoSemCelularSeguroTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(412);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idProduto = '22323';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        String retorno = BCSF_cmp_SMSControleController.adesaoContrato(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals('sem celular seguro', retorno);
    }

    @isTest
    public static void cancelarContratoSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idAdesao = '2323';
        inputObj.codMotivoCancelar = '32';
        inputObj.contestado = 'true';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        Boolean retorno = BCSF_cmp_SMSControleController.cancelarContrato(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals(true, retorno);
    }

    @isTest
    public static void cancelarContratoErrorTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(400);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idEmpresa = '2';
        inputObj.idAdesao = '2323';
        inputObj.codMotivoCancelar = '32';
        inputObj.contestado = 'true';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        Boolean retorno = BCSF_cmp_SMSControleController.cancelarContrato(JSON.serialize(inputObj));
        Test.StopTest();
        System.assertEquals(false, retorno);
    }

    @isTest
    public static void motivosCancelamentoSuccessTest() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockMotivosCancelamentoSMSControle');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        IntegracaoSMSControleTotal.InputClass inputObj = new IntegracaoSMSControleTotal.InputClass();
        inputObj.cpfCliente = '37962639504';
        inputObj.canal = 'cockpit';
        inputObj.canalAtendimento = '8888888801';
        inputObj.loja = '8888888801';
        inputObj.drt = 'af';
        inputObj.idEmpresa = '2';
        inputObj.idAdesao = '2323';
        inputObj.codMotivoCancelar = '32';
        inputObj.contestado = 'true';
        inputObj.sufixoCartao = '9585';
        inputObj.numeroConta = '37000004160';

        Test.StartTest();
        IntegracaoSMSControleTotal.OutputMotivos retorno = BCSF_cmp_SMSControleController.motivosCancelamento('40020030010', 'cockpit', '1');
        Test.StopTest();

        System.assertEquals('OK', retorno.statusResponse);
        System.assertEquals(2, retorno.motivos.size());
    }

    @isTest
    public static void CriarCasosTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
            BCSF_cmp_SMSControleController.criarCaso('900000000', cf.Id, acc.Id, 'Cancelamento de SMS Controle Total', '1', '40020010025', 'APP',  'Chat', 'teste', 'Alega Não Ter Aderido');
        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }


    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Test.StartTest();
            ContaFinanceira__c response = BCSF_cmp_SMSControleController.getContaFinanceira(cf.Id);
        Test.StopTest();

        System.AssertEquals(response.id, cf.id);
    }


    @isTest
    public static void getCartaoTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;

        Asset ass = new Asset();
        ass.NomeReduzido__c = 'BENJAMIN B ANDRADE'; 
        ass.NumeroCartao__c = '5438821131329799'; 
        ass.CPF__c = '12345678912'; 
        ass.ContaFinanceira__c = cf.Id;
        ass.Name = 'Cartão'; 
        ass.TipoTitularidade__c = 'TITULAR';
        ass.CartaoPrimario__c = true;
        insert ass;

        Test.StartTest();
            Asset response = BCSF_cmp_SMSControleController.getCartao(cf.Id);
        Test.StopTest();

        System.AssertEquals(response.id, ass.id);
    }

    

}