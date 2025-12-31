@isTest
public class IdentificaCockpitTest {

    @TestSetup
    static void makeData(){
        Account novaConta = new Account();
        novaConta.CPF__c = '98390073277';
        novaConta.FirstName = 'Teste01';
        novaConta.LastName = 'Test';
        novaConta.RecordTypeId = IdentificaClienteChatDAO.getPersonRecordType().Id;
        insert novaConta;
    }

    @isTest
    public static void IdentificaContaTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"cliente":{"cpf":"12345678900","dadosSociais":[{"numeroConta":"11111111111","dataDeNascimento":"1974-03-24T03:00:00Z","nomeCompleto":"ANNA MARQUES QUEIROZ","nomePrimeiro":"ANNA","nomeMeio":"MARQUES","nomeUltimo":"QUEIROZ","nomeSocial":"","nomeMae":"DORALICE MARQUES QUEIROZ","genero":"F"}],"contaCartao":{"contratos":[{"statusConta":"NORM","unidadeNegocio":"CSF","numeroConta":"11111111111","tipoEnvioFatura":"1"}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/cpf' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        RecordType rt = ConsultaCPFNoIDDAO.getRecordType('BCSF Cliente Pessoal Carrefour');
        Account acc = new Account();
        acc.FirstName = 'Teste';
        acc.LastName = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        acc.RecordTypeId = rt != null ? rt.Id : null;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        insert cf;

        Test.StartTest();
        String teste = IdentificaCockpitController.identificaConta(acc.id, 'Cockpit');
        Test.StopTest();
        
        ContaFinanceira__c contaAtualizada = [SELECT StatusConta__c FROM ContaFinanceira__c WHERE id =: cf.id];
        System.AssertEquals(contaAtualizada.StatusConta__c, 'NORM');
        System.AssertEquals(teste, 'ok');
    }

    @isTest
    public static void IdentificaContaSemCFTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"cliente":{"cpf":"12345678900","dadosSociais":[{"numeroConta":"11111111111","dataDeNascimento":"1974-03-24T03:00:00Z","nomeCompleto":"ANNA MARQUES QUEIROZ","nomePrimeiro":"ANNA","nomeMeio":"MARQUES","nomeUltimo":"QUEIROZ","nomeSocial":"","nomeMae":"DORALICE MARQUES QUEIROZ","genero":"F"}],"contaCartao":{"contratos":[{"statusConta":"NORM","unidadeNegocio":"CSF","numeroConta":"11111111111","tipoEnvioFatura":"1","codigoProdutoCurto":"AMCAI","numeroContaSerno":"924844"}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/cpf' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        RecordType rt = ConsultaCPFNoIDDAO.getRecordType('BCSF Cliente Pessoal Carrefour');
        Account acc = new Account();
        acc.FirstName = 'Teste';
        acc.LastName = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        acc.RecordTypeId = rt != null ? rt.Id : null;
        insert acc;

        Test.StartTest();
        String teste = IdentificaCockpitController.identificaConta(acc.id, 'Cockpit');
        Test.StopTest();
        
        ContaFinanceira__c contaAtualizada = [SELECT StatusConta__c FROM ContaFinanceira__c LIMIT 1];
        System.AssertEquals(contaAtualizada.StatusConta__c, 'NORM');
        System.AssertEquals(teste, 'ok');
    
    }
    
    @isTest
    public static void NumeroContaTeste(){

        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"clientePorConta":{"cpf":"43470656126","dadosSociais":[{"numeroConta":"10000005115","statusConta":"CLSC","unidadeNegocio":"ATC"}],"contaCartao":{"contratos":[{"numeroConta":"10000005115","unidadeNegocio":"ATC","statusConta":"CLSC","valorLimiteDisponivel":50000,"valorLimiteTotal":50000,"aceiteRecebimentoDeEmail": true,"aumentoAutomaticoDeLimite": true,"cartoes":[{"ehContactless":true,"numeroCartao":"5300.XXXX.XXXX.7828","ehAtivo":true,"ehPrimario":true,"ehVirtual":false,"cpfPortador":"98909616954","nomePortador":"Teste DUARTE FREITAS","tipoTitularidade":"TITULAR","dataAtivacao":"2015-01-02T00:00:00+00:00","vencimentoCartao":"2027-08-31T00:00:00-03:00","nomeCartao":"Teste D FREITAS","nomeProduto":"MC HIBRIDO","idProduto":"10","tipoCartao":"C","statusCartao":"72"},{"ehContactless":true,"numeroCartao":"5300.XXXX.XXXX.7855","ehAtivo":true,"ehPrimario":true,"ehVirtual":false,"cpfPortador":"98909616954","nomePortador":"Teste DUARTE FREITAS","tipoTitularidade":"TITULAR","dataAtivacao":"2015-01-02T00:00:00+00:00","vencimentoCartao":"2027-08-31T00:00:00-03:00","nomeCartao":"Teste D FREITAS","nomeProduto":"MC HIBRIDO","idProduto":"10","tipoCartao":"C","statusCartao":"72"}]}]},"identidades":[{"tipo":"CPF","valor":"04308599296"}],"contato":{"dadosContato":[{"numeroConta":"10000005115","unidadeNegocio":"ATC","enderecos":[{"cep":"08110115","tipoEndereco":["RESIDENCIAL"],"logradouro":"RUA ADOLFO BACI","numero":"213","complemento":"","bairro":"ITAIM PAULISTA","uf":"SP","cidade":"SAO PAULO","pais":"076","finalidadeEndereco":["OUTROS"]},{"cep":"06460000","tipoEndereco":["COMERCIAL"],"logradouro":"Av. Tambore","numero":"267","complemento":"21 andar","bairro":"Tambore","uf":"SP","cidade":"Barueri","pais":"076","finalidadeEndereco":["OUTROS"]}],"emails":[{"endereco":"teste@gmail.com","tipoEmail":["OUTROS"]}],"telefones":[{"celularSeguro":true,"ddd":"11","tipo":"CELULAR","tipoContato":["RESIDENCIAL"],"numero":"988888888"},{"celularSeguro":false,"ddd":"11","tipo":"PRINCIPAL","tipoContato":["RESIDENCIAL"],"numero":"33334444"},{"celularSeguro":false,"ddd":"11","tipo":"SECUNDARIO","tipoContato":["COMERCIAL"],"numero":"44443333"}]}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/numeroconta' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));


        String RecTypeId= [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND (Name = 'Conta pessoal' OR Name='Person Account')].Id;
        Account acc = new Account();
        acc.RecordTypeID = RecTypeId;
        acc.LastName = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        cf.bairro__c = 'Jaraguá';
        cf.CEP__c = '02034-243';
        cf.Cidade__c = 'São Paulo';
        cf.Estado__c = 'SP';
        cf.Numero__c = '123';
        insert cf;
        
        ContatoAtendimento__c ct = new ContatoAtendimento__c();
        ct.ContaFinanceira__c = cf.Id;
        ct.bairro__c = 'Jaraguá';
        ct.CEP__c = '02034-243';
        ct.Cidade__c = 'São Paulo';
        ct.Estado__c = 'SP';
        ct.Numero__c = '123';
        insert ct;
        
        Asset at = new Asset();
        at.ContaFinanceira__c = cf.Id;
        at.NumeroCartao__c = '5300.XXXX.XXXX.7828';
        at.Situacao__c = 'A'; 
        at.Name = 'Cartão'; 
        insert at;

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Test.StartTest();
        String teste = IdentificaCockpitController.identificaNumeroConta(cf.id, 'Cockpit');
        Test.StopTest();
        
        ContaFinanceira__c contaAtualizada = [SELECT Rua__c FROM ContaFinanceira__c WHERE id =: cf.id];
        
        System.AssertEquals(contaAtualizada.Rua__c, 'RUA ADOLFO BACI');
        System.AssertEquals(teste, 'ok');
    }

    // testes workaround nome e sobrenome não retornados na api

    @isTest
    public static void sobrenomeVazioTest(){
        Account conta = [SELECT Id FROM Account WHERE FirstName = 'Teste01' LIMIT 1];
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpit01');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        String retorno = IdentificaCockpitController.identificaConta(conta.Id, 'Cockpit');
        Test.StopTest();
        
        Account result = [SELECT Id, FirstName, LastName FROM Account WHERE Id = :conta.Id LIMIT 1];

        Assert.areEqual('MARCIA', result.FirstName);
        Assert.areEqual('MARCIA', result.LastName);
    }

    @isTest
    public static void nomeMeioNuloTest(){
        Account conta = [SELECT Id FROM Account WHERE FirstName = 'Teste01' LIMIT 1];
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaCockpitNomeMeioNulo');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.StartTest();
        String retorno = IdentificaCockpitController.identificaConta(conta.Id, 'Cockpit');
        Test.StopTest();
        
        Account result = [SELECT Id, FirstName, LastName FROM Account WHERE Id = :conta.Id LIMIT 1];

        Assert.areEqual('MARCIA', result.FirstName);
        Assert.areEqual('DANTAS', result.LastName);
    }

    @isTest
    public static void numeroContaDadosVazios(){
       MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockTokenServerToServer');
        objMultiHttpCalloutMock.addResponse(200, 'MockIdentificaByContaVazia');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);


        String RecTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND (Name = 'Conta pessoal' OR Name = 'Person Account')].Id;
        Account acc = new Account();
        acc.RecordTypeID = RecTypeId;
        acc.LastName = 'Teste';
        acc.CPF__c = '123.456.789-12';
        acc.DataNascimento__c = Date.today() - 5000;
        insert acc;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = acc.Id;
        cf.NumeroConta__c = '11111111111';
        cf.TipoConta__c = '1';
        cf.UnidadeNegocio__c = '1';
        cf.StatusConta__c = 'BLCK';
        cf.bairro__c = 'Jaraguá';
        cf.CEP__c = '02034-243';
        cf.Cidade__c = 'São Paulo';
        cf.Estado__c = 'SP';
        cf.Numero__c = '123';
        insert cf;
        
        ContatoAtendimento__c ct = new ContatoAtendimento__c();
        ct.ContaFinanceira__c = cf.Id;
        ct.bairro__c = 'Jaraguá';
        ct.CEP__c = '02034-243';
        ct.Cidade__c = 'São Paulo';
        ct.Estado__c = 'SP';
        ct.Numero__c = '123';
        insert ct;
        
        Asset at = new Asset();
        at.ContaFinanceira__c = cf.Id;
        at.NumeroCartao__c = '5300.XXXX.XXXX.7828';
        at.Situacao__c = 'A'; 
        at.Name = 'Cartão'; 
        insert at;

        Product2 produto = new Product2();
        produto.ProductCode = '10';
        produto.Bandeira__c = 'MASTERCARD';
        produto.Name = 'MC HIBRIDO GOLD BASICO I';
        insert produto;

        Test.StartTest();
        String teste = IdentificaCockpitController.identificaNumeroConta(cf.id, 'Cockpit');
        Test.StopTest();
        
        ContaFinanceira__c contaAtualizada = [SELECT Rua__c, Email__c, Telefone__c, TelefoneResidencial__c
             FROM ContaFinanceira__c WHERE id =: cf.id];
        
        System.AssertEquals(contaAtualizada.Rua__c, null);
        System.AssertEquals(contaAtualizada.Email__c, null);
        System.AssertEquals(contaAtualizada.Telefone__c, null);
        System.AssertEquals(contaAtualizada.TelefoneResidencial__c, null);
        System.AssertEquals(teste, 'ok');
    }
}