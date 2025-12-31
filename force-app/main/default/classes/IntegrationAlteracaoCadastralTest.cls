/*************************************************************************
*    ESTA CLASSE TEM COMO OBJETIVO COBRIR AS CLASSES ABAIXO:             *
*    - IntegrationAlteracaoCadastral                98%                  *
*    - AlteracaoCadastralController                 97%                  *
*    - IntegrationEndereco                          100%                 *
*    - AvaliacaoAlteracaoCadastralBO                99%                  *
*    - AvaliacaoAlteracaoCadastralDAO               100%                 *
**************************************************************************/
@isTest
public class IntegrationAlteracaoCadastralTest {
    @isTest
    public static void AlterarEmailTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setBody('{"email":"teste.teste@gmail.com"}');
        responseAPI.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/conta/37000081481/atualizar-email' => responseAPI
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        String cpf = '04544371457';
        String idEmpresa = '1';
        String canal = 'cockpit';
        String email = 'teste.teste@gmail.com';
        String numeroConta = '37000081481';
        String area = 'ouvidoria';
        String sistema = 'ouvidoria';

        Boolean retorno = IntegrationAlteracaoCadastral.AlterarEmail(cpf, idEmpresa, canal, email, numeroConta, area, sistema);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alteração de E-mail' LIMIT 1];

        System.AssertEquals(true            , retorno);
        System.AssertEquals('04544371457'   , log.CPF__c);
        System.AssertEquals('POST'          , log.Metodo__c);
    }

    @isTest
    public static void AlterarDadosCadastraisTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setBody('{"dadosGerais":{"primeiroNome":"JOANA","sobrenome":"FLORES","dataNascimento":"02-08-2000","sexo":"FEMININO","naturalidade":"SAO PAULO","estadoCivil":"SOLTEIRO","nomeMae":"JOAQUINA PESTANA MIRANDA"},"contrato":{"numeroConta":"37000000036"},"documentos":{"rg":"12345678912"},"endereco":{"cep":"12345678","logradouro":"RUA ANTONIO MANOEL","numero":"1","complemento":"APTO 09","bairro":"VILA PRUDENTE","cidade":"SAO PAULO","uf":"SP"},"contato":{"dddTelefoneResidencial":"11","telefoneResidencial":"55145631","dddTelefoneCelular":"11","telefoneCelular":"964625288","email":"THIAGOALEXANDRESOUZAARAGONE@GMAIL.COM"},"consentimentos":{"aceiteRecebimentoEmail":true,"indicadorAceiteAtualizacaoLimite":true}}');
        responseAPI.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api-alteracao-cadastral/api/v1/alteracao-cadastral' => responseAPI
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        Test.StartTest();
        String cpf = '04544371457';
        String idEmpresa = '1';
        String canal = 'cockpit';
        String numeroConta = '37000081481';
        String area = 'ouvidoria';
        String sistema = 'ouvidoria';

        IntegrationAlteracaoCadastral.BodyRequestAlterarDadosCadastrais bodyRequest = new IntegrationAlteracaoCadastral.BodyRequestAlterarDadosCadastrais();
        bodyRequest.cliente.dadosGerais.primeiroNome = 'JOANA';
        bodyRequest.cliente.dadosGerais.sobrenome = 'FLORES';
        bodyRequest.cliente.dadosGerais.dataNascimento = '02-08-2000';
        bodyRequest.cliente.dadosGerais.sexo = 1;
        bodyRequest.cliente.dadosGerais.naturalidade = 'SAO PAULO';
        bodyRequest.cliente.dadosGerais.estadoCivil = 1;
        bodyRequest.cliente.dadosGerais.nomeMae = 'JOAQUINA PESTANA MIRANDA';

        bodyRequest.cliente.contrato.numeroConta = '37000000036';
        bodyRequest.cliente.documentos.rg = '12345678912';

        bodyRequest.cliente.endereco.cep = '12345678';
        bodyRequest.cliente.endereco.logradouro = 'RUA ANTONIO MANOEL';
        bodyRequest.cliente.endereco.numero = '1';
        bodyRequest.cliente.endereco.complemento = 'APTO 09';
        bodyRequest.cliente.endereco.bairro = 'VILA PRUDENTE';
        bodyRequest.cliente.endereco.cidade = 'SAO PAULO';
        bodyRequest.cliente.endereco.uf = 'SP';

        bodyRequest.cliente.contato.dddTelefoneResidencial = '11';
        bodyRequest.cliente.contato.telefoneResidencial = '55145631';
        bodyRequest.cliente.contato.dddTelefoneCelular = '11';
        bodyRequest.cliente.contato.telefoneCelular = '964625288';
        bodyRequest.cliente.contato.email = 'THIAGOALEXANDRESOUZAARAGONE@GMAIL.COM';

        bodyRequest.cliente.consentimentos.aceiteRecebimentoEmail = true;
        bodyRequest.cliente.consentimentos.indicadorAceiteAtualizacaoLimite = true;

        String bodyJson = System.JSON.serialize(bodyRequest);

        Boolean retorno = AlteracaoCadastralController.AlterarDadosCadastrais(cpf, idEmpresa, canal, numeroConta, area, sistema, bodyJson);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Alteração Cadastral' LIMIT 1];

        System.AssertEquals(true                            , retorno);
        System.AssertEquals('04544371457'                   , log.CPF__c);
        System.AssertEquals('POST'                          , log.Metodo__c);
    }

    @isTest
    public static void getContaFinanceiraTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;

        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '2';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'NORM';
        cf.email__c = 'teste@exemplo.com';
        cf.Telefone__c = '5511900000000';
        cf.CEP__c = '00000000';
        insert cf;

        Test.startTest();
        ContaFinanceiraBO.ContaFinanceira result = AlteracaoCadastralController.GetContaFinanceira(cf.Id);
        Test.stopTest();

        System.assertEquals(result.Nome, 'Teste');
        System.assertEquals(result.CPF, '123.456.789-12');
        System.assertEquals(result.StatusConta, 'NORM');
        System.assertEquals(result.NumeroConta, '11111111111');
        System.assertEquals(result.TipoConta, '2');
        System.assertEquals(result.UnidadeNegocio, '1');
        System.assertEquals(result.AccountId, acc.Id);
    }

    @isTest
    public static void GetEnderecoByCEPTest() {
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseAPI = new HttpResponse();
        responseAPI.setBody('{"logradouro":"Rua Baronesa de Porto Carreiro","bairro":"Bom Retiro","cidade":"São Paulo","uf":"SP"}');
        responseAPI.setStatusCode(200);

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/api/v1/cep/49390000' => responseAPI
        };
        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.StartTest();
        String cpf = '04544371457';
        String idEmpresa = '1';
        String canal = 'cockpit';
        String cep = '49390000';

        IntegrationEndereco.OutputEndereco retorno = AlteracaoCadastralController.GetEnderecoByCEP(cpf, idEmpresa, canal, cep);
        Test.StopTest();

        LogIntegracao__c log = [SELECT Id, CPF__c, Metodo__c, URL__c FROM LogIntegracao__c WHERE NomeServico__c = 'Obter Endereço Através de CEP' LIMIT 1];

        System.AssertEquals(retorno.logradouro  , 'Rua Baronesa de Porto Carreiro');
        System.AssertEquals(retorno.bairro      , 'Bom Retiro');
        System.AssertEquals('04544371457'   , log.CPF__c);
        System.AssertEquals('GET'           , log.Metodo__c);
    }
    /*
    @isTest

    public static void CriarAvaliacaoAlteracaoTest() {
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;
        Case cs = AlteracaoCadastralController.CriarCaso('Whatsapp', 'Ouvidoria', cf.Id, acc.Id, '1', 'Cartão', 'Alteração de dados cadastrais CPF', 'new');

        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO objAvaliacaoInsert = new AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO();
        objAvaliacaoInsert.MudouCPF            = true;
        objAvaliacaoInsert.CPF                 = '04544371457';
        objAvaliacaoInsert.CPFOrigin           = '04544371457';
        objAvaliacaoInsert.Complemento         = 'MudouComplemento';
        objAvaliacaoInsert.ComplementoOrigin   = 'MudouComplemento';
        objAvaliacaoInsert.Cidade              = 'MudouCidade';
        objAvaliacaoInsert.CidadeOrigin        = 'MudouCidade';
        objAvaliacaoInsert.Email               = 'MudouEmail@gmail.com';
        objAvaliacaoInsert.EmailOrigin         = 'MudouEmail@gmail.com';
        objAvaliacaoInsert.CEP                 = '49390000';
        objAvaliacaoInsert.CEPOrigin           = '49390000';
        objAvaliacaoInsert.NumeroCasa          = '29';
        objAvaliacaoInsert.IdCaso              = cs.Id;
        String avaliacaoJson = System.JSON.serialize(objAvaliacaoInsert);

        Test.StartTest();
        String cpf = '04544371457';
        String idEmpresa = '1';
        String canal = 'cockpit';
        String cep = '49390000';

        AlteracaoCadastralController.CriarAvaliacaoAlteracao(avaliacaoJson);
        AvaliacaoAlteracaoCadastral__c av = [SELECT Id, CPF__c FROM AvaliacaoAlteracaoCadastral__c LIMIT 1];

        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO retorno = AlteracaoCadastralController.GetAvaliacaoAlteracaoCadastral(cs.Id);
        AlteracaoCadastralController.UpdateCaseAvaliacao(acc.Id, cf.Id, cs.Id, 'String description', av.Id, 'Aprovado', true, true, true, true, avaliacaoJson);
        Test.StopTest();

        System.AssertEquals(av.CPF__c, '04544371457');
        System.AssertEquals(retorno.EmailOrigin, 'MudouEmail@gmail.com');
        System.AssertEquals(retorno.NumeroCasa, '29');
        System.AssertEquals(retorno.CEP, '49390000');
        System.AssertEquals([SELECT StatusSolicitacao__c FROM AvaliacaoAlteracaoCadastral__c LIMIT 1].StatusSolicitacao__c, 'Aprovado');
    }
    */

    @isTest
    public static void CriarAvaliacaoAlteracaoFalseTest() {
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;
        Case cs = AlteracaoCadastralController.CriarCaso('Whatsapp', 'Ouvidoria', cf.Id, acc.Id, '1', 'Alteração de Dados Cadastrais', 'Alteração de dados gerais/contato', 'new');

        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO objAvaliacaoInsert = new AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO();
        objAvaliacaoInsert.MudouCPF            = true;
        objAvaliacaoInsert.CPF                 = '04544371457';
        objAvaliacaoInsert.CPFOrigin           = '04544371457';
        objAvaliacaoInsert.Complemento         = 'MudouComplemento';
        objAvaliacaoInsert.ComplementoOrigin   = 'MudouComplemento';
        objAvaliacaoInsert.Cidade              = 'MudouCidade';
        objAvaliacaoInsert.CidadeOrigin        = 'MudouCidade';
        objAvaliacaoInsert.Email               = 'MudouEmail@gmail.com';
        objAvaliacaoInsert.EmailOrigin         = 'MudouEmail@gmail.com';
        objAvaliacaoInsert.CEP                 = '49390000';
        objAvaliacaoInsert.CEPOrigin           = '49390000';
        objAvaliacaoInsert.NumeroCasa          = '29';
        objAvaliacaoInsert.IdCaso              = cs.Id;
        String avaliacaoJson = System.JSON.serialize(objAvaliacaoInsert);

        Test.StartTest();
        String cpf = '04544371457';
        String idEmpresa = '1';
        String canal = 'cockpit';
        String cep = '49390000';

        AlteracaoCadastralController.CriarAvaliacaoAlteracao(avaliacaoJson);
        AvaliacaoAlteracaoCadastral__c av = [SELECT Id, CPF__c FROM AvaliacaoAlteracaoCadastral__c LIMIT 1];

        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO retorno = AlteracaoCadastralController.GetAvaliacaoAlteracaoCadastral(cs.Id);
        Test.StopTest();

        System.AssertEquals(av.CPF__c, '04544371457');
        System.AssertEquals(retorno.EmailOrigin, 'MudouEmail@gmail.com');
        System.AssertEquals(retorno.NumeroCasa, '29');
        System.AssertEquals(retorno.CEP, '49390000');
    }

    @isTest
    public static void CreateCaseTest(){
        Account acc = new Account();
        acc.Name = 'Teste';
        acc.CPF__c = '123.456.789-12';
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        insert cf;


        Test.StartTest();
        AlteracaoCadastralController.CriarCaso('Whatsapp', 'Ouvidoria', cf.Id, acc.Id, '1', 'Alteração de Dados Cadastrais', 'Alteração de dados gerais/contato', 'closed');
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM Case]);
    }
}