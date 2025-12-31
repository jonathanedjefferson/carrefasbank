@isTest
public class BCSF_AtivarInativarCartaoControllerTest {
    @isTest
    static void listarCartoesTest(){
        // sem cheque especial e com pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        response.setBody('{"data":{"clientePorConta":{"cpf":"73238343769","dadosSociais":[{"numeroConta":"37000001653","statusConta":"NORM","unidadeNegocio":"CSF"}],"contaCartao":{"contratos":[{"numeroConta":"37000001653","unidadeNegocio":"CSF","tipoEnvioFatura":"1","statusConta":"NORM","valorLimiteDisponivel":50000,"valorLimiteTotal":50000,"cartoes":[{"id":"937986","numeroCartao":"5300.XXXX.XXXX.1860","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2023-08-04T03:00:00+00:00","vencimentoCartao":"2026-08-31T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"LOST"},{"id":"938077","numeroCartao":"5300.XXXX.XXXX.2697","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2026-02-15T03:00:00+00:00","vencimentoCartao":"2029-02-28T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"LOST"},{"id":"940081","numeroCartao":"5300.XXXX.XXXX.8940","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2026-02-20T03:00:00+00:00","vencimentoCartao":"2029-02-28T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"CNRV"},{"id":"894929","numeroCartao":"5300.XXXX.XXXX.0518","ehAtivo":true,"ehPrimario":true,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2028-03-30T03:00:00+00:00","vencimentoCartao":"2030-12-31T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"NORM"},{"id":"948667","numeroCartao":"5300.XXXX.XXXX.9587","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2026-09-01T03:00:00+00:00","vencimentoCartao":"2029-04-30T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"CNRV"},{"id":"1030680","numeroCartao":"5300.XXXX.XXXX.2881","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"73238343769","nomePortador":"GABRIELA MORAES VIEIRA","tipoTitularidade":"TITULAR","dataAtivacao":"2026-12-27T03:00:00+00:00","vencimentoCartao":"2029-12-31T00:00:00-03:00","nomeCartao":"GABRIELA M VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"LOST"},{"id":"913186","numeroCartao":"5300.XXXX.XXXX.2677","ehAtivo":true,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"26037244367","nomePortador":"YANYS S VIEIRA","tipoTitularidade":"DEPENDENTE","dataAtivacao":"2026-12-27T03:00:00+00:00","vencimentoCartao":"2029-03-31T00:00:00-03:00","nomeCartao":"YANYS S VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"CLSC"},{"id":"938226","numeroCartao":"5300.XXXX.XXXX.0482","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"26037244367","nomePortador":"YANYS S VIEIRA","tipoTitularidade":"DEPENDENTE","dataAtivacao":"2026-02-20T03:00:00+00:00","vencimentoCartao":"2029-02-28T00:00:00-03:00","nomeCartao":"YANYS S VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"LOST"},{"id":"938112","numeroCartao":"5300.XXXX.XXXX.5166","ehAtivo":false,"ehPrimario":false,"ehVirtual":false,"cpfPortador":"26037244367","nomePortador":"YANYS S VIEIRA","tipoTitularidade":"DEPENDENTE","dataAtivacao":"2026-02-20T03:00:00+00:00","vencimentoCartao":"2027-08-31T00:00:00-03:00","nomeCartao":"YANYS S VIEIRA","nomeProduto":"MC HIBRIDO GOLD BASICO L","idProduto":"6","tipoCartao":"C","bandeira":"MASTERCARD","ehContactless":true,"statusCartao":"LOST"}],"aumentoAutomaticoDeLimite":true,"statusGeralCartaoPrimario":"NORM","classificacaoStatusConta":0}]},"identidades":[{"tipo":"CPF","valor":"73238343769"},{"tipo":"RG","valor":"178478726"}],"contato":{"dadosContato":[{"numeroConta":"37000001653","unidadeNegocio":"CSF","enderecos":[{"cep":"01144010","tipoEndereco":["RESIDENCIAL"],"logradouro":"RUA DOS IRINEUS","numero":"213","complemento":"QA","bairro":"BOM RETIRO","uf":"SP","cidade":"SAO PAULO","pais":"076","finalidadeEndereco":["OUTROS"]},{"cep":"06460000","tipoEndereco":["COMERCIAL"],"logradouro":"Av. Tambore","numero":"267","complemento":"21 andar","bairro":"Tambore","uf":"SP","cidade":"Barueri","pais":"076","finalidadeEndereco":["OUTROS"]}],"emails":[{"endereco":"naomi.figueiredo@gmail.com","tipoEmail":["OUTROS"]}],"telefones":[{"celularSeguro":false,"ddd":"11","tipoContato":["RESIDENCIAL"],"numero":"964625288"},{"celularSeguro":false,"ddd":"11","tipoContato":["RESIDENCIAL"],"numero":"33334444"},{"celularSeguro":false,"ddd":"11","tipoContato":["RESIDENCIAL"],"numero":"44443333"},{"celularSeguro":false,"ddd":"11","tipoContato":["COMERCIAL"],"numero":"44443333"}]}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/numeroconta' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        List<IdentificaCockpit.Contrato> retorno = BCSF_AtivarInativarCartaoController.ListarCartoes('37000001653', '1', '73238343769' , 'cockpit');

        Test.stopTest();

        System.assertNotEquals(null, retorno);
    }

    @isTest
    static void ativarCartaoTest(){
        // sem cheque especial e com pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        response.setBody('true');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        Boolean retorno = BCSF_AtivarInativarCartaoController.Ativar('1', '1', '10000009745', '1', 'cockpit', 'cockpit', 'Ativar');

        Test.stopTest();

        System.assertEquals(true, retorno);
    }


    @isTest
    static void inativarCartaoTest(){
        // sem cheque especial e com pagamento após vencimento
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(204);
        responseServerToServer.setBody('{"access_token":"VacuFe6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"bc1aeb83a4d6","scope":"profile"}');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(204);
        response.setBody('');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/idp/server-to-server' => responseServerToServer, 
                '' => response
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        Boolean retorno = BCSF_AtivarInativarCartaoController.Inativar('1', '1', '11111111111', '1', 'cockpit', 'cockpit', 'Inativar');

        Test.stopTest();

        System.assertEquals(true, retorno);
    }


    @isTest
    static void criarCasoTest(){
        // Create Account
        Id rtAct = [
            SELECT ID
            FROM RecordType
            WHERE Name = 'Cliente Carrefour'
        ].Id;

        Account act = new Account(
            RecordTypeId = rtAct,
            Name = 'Teste Account',
            CPF__c = '12345678910'
        );
        
        Database.insert(act);  

        Id actId = [
            SELECT Id
            FROM Account
            WHERE Name = 'Teste Account'
        ].Id;
        
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.NomeCliente__c = actId;
        insert cf;

        // Create Entitlement
        Entitlement ent = new Entitlement(
            Name = 'Entitlement Teste',
            AccountId = actId,
            Type = 'Phone Support',
            StartDate = Date.today().addDays(-1)
        );

        Database.insert(ent);
        
        Id prfId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'BCSF_PF_Banco Carrefour'
        ].Id;

        // Create User
        User usr = new User(
            LastName = 'User Teste 1',
            Alias = 'utester',
            Email = 'email@email.com',
            Username = 'usrname@test.com',
            CommunityNickname = 'nick',
            ProfileId = prfId,
            DRT__c = '12313534',
            TipodeTrabalho__c = 'Presencial',
            TipodeColaborador__c = 'DVA',
            UnidadedeNegocio__c = 'CRF',
            Departamento__c = 'Atendimento',
            AreaPrincipal__c = 'pos_vendas',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Bypass__c = TRUE
        );

        Database.insert(usr);
        
        Id usrId = [
            SELECT Id
            FROM User
            WHERE Username = 'usrname@test.com'
        ].Id;

        Id entId = [
            SELECT Id
            FROM Entitlement
            WHERE Name = 'Entitlement Teste'
        ].Id;

        Id rtCas = [
            SELECT Id
            FROM RecordType 
            WHERE Name = 'BCSF Atendimento'
                AND SObjectType = 'Case'
        ].Id;


        Test.startTest();
        Case retorno = BCSF_AtivarInativarCartaoController.createCase('SAC', cf.Id, actId, '1', 'VOZ', 'Cockpit');

        Test.stopTest();

        System.assertNotEquals(null, retorno);
    }
}