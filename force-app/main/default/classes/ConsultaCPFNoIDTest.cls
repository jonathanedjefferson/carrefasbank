@IsTest
public class ConsultaCPFNoIDTest {
    @isTest
    public static void validarCpfTest(){
        Test.startTest();
        Boolean resultTrue = ConsultaCPFNoIDCcontroller.validarCpf('90992848458');
        Boolean resultFalse = ConsultaCPFNoIDCcontroller.validarCpf('12345678945');
        Test.stopTest();

        System.assertEquals(true, resultTrue);
        System.assertEquals(false, resultFalse);
    }

    @isTest
    public static void getAccountTest(){
        Account acc = new Account();
        acc.FirstName = 'First';
        acc.LastName = 'Last';
        acc.CPF__c = '123456789';
        insert acc;

        Test.startTest();
        Account retornoAcc = ConsultaCPFNoIDCcontroller.getAccount('123456789');
        Test.stopTest();

        System.assertEquals(retornoAcc.FirstName, 'First');
        System.assertNotEquals(retornoAcc, null);
    }

    @isTest
    public static void identificaCockpitAccountTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"cliente":{"cpf":"90992848458","dadosSociais":[{"numeroConta":"10000002591","dataDeNascimento":"1973-06-29T03:00:00Z","nomeCompleto":"FRANCISCA ROCHA FERRAZ","nomePrimeiro":"FRANCISCA","nomeMeio":"ROCHA","nomeUltimo":"FERRAZ","nomeSocial":"","nomeMae":"ALICE ROCHA FERRAZ","genero":"F"}],"contaCartao":{"contratos":[{"statusConta":"NORM","unidadeNegocio":"ATC","numeroConta":"10000002591","tipoEnvioFatura":"2"}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/cpf' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        Account retornoAcc = ConsultaCPFNoIDCcontroller.identificaCockpitAccount('90992848458', 'cockpit');
        Test.stopTest();

        System.assertEquals(retornoAcc.FirstName, 'FRANCISCA');
        System.assertEquals(retornoAcc.NomeMae__c, 'ALICE ROCHA FERRAZ');
        System.assertEquals(retornoAcc.CPF__c, '90992848458');

    }

    @isTest
    public static void sobrenomeVazioTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"cliente":{"cpf":"90992848458","dadosSociais":[{"numeroConta":"10000002591","dataDeNascimento":"1973-06-29T03:00:00Z","nomeCompleto":"FRANCISCA ROCHA FERRAZ","nomePrimeiro":"FRANCISCA ROCHA","nomeMeio":"","nomeUltimo":"","nomeSocial":"","nomeMae":"ALICE ROCHA FERRAZ","genero":"F"}],"contaCartao":{"contratos":[{"statusConta":"NORM","unidadeNegocio":"ATC","numeroConta":"10000002591","tipoEnvioFatura":"2"}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/cpf' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        Account retornoAcc = ConsultaCPFNoIDCcontroller.identificaCockpitAccount('90992848458', 'cockpit');
        Test.stopTest();

        Assert.areEqual(retornoAcc.FirstName, 'FRANCISCA');
        Assert.areEqual(retornoAcc.LastName, 'ROCHA FERRAZ');
        Assert.areEqual(retornoAcc.NomeMae__c, 'ALICE ROCHA FERRAZ');
        Assert.areEqual(retornoAcc.CPF__c, '90992848458');
    }

     @isTest
    public static void nomeMeioNuloTest(){
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"VacuFeYd34yWckrizSWDvwHm7Glxx7fZP_eggrlmsiPytENz9WBHUOa8ujUpzXJXtziMJK5D1rSUe_9Zooqn2OUg3WZbJObj3RafJV3Ykb3JLvt6uEH_0IYQdb4Sg","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DhBXGoOt3GtDMnBsCNU-c6F8xyfcVtizqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"b214a424-2a1a-495d-a310-bc1aeb83a4d6","scope":"profile"}');
        
        HttpResponse responseIdentifica = new HttpResponse();
        responseIdentifica.setStatusCode(200);
        responseIdentifica.setBody('{"data":{"cliente":{"cpf":"90992848458","dadosSociais":[{"numeroConta":"10000002591","dataDeNascimento":"1973-06-29T03:00:00Z","nomeCompleto":"FRANCISCA ROCHA FERRAZ","nomePrimeiro":"FRANCISCA ROCHA","nomeUltimo":"FERRAZ","nomeSocial":"","nomeMae":"ALICE ROCHA FERRAZ","genero":"F"}],"contaCartao":{"contratos":[{"statusConta":"NORM","unidadeNegocio":"ATC","numeroConta":"10000002591","tipoEnvioFatura":"2"}]}}},"ehBlindado":false,"ehBlindadoFull":false}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                '/salesforce/clientes/identificacao/cockpit/cpf' => responseIdentifica
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));

        Test.startTest();
        Account retornoAcc = ConsultaCPFNoIDCcontroller.identificaCockpitAccount('90992848458', 'cockpit');
        Test.stopTest();

        Assert.areEqual(retornoAcc.FirstName, 'FRANCISCA');
        Assert.areEqual(retornoAcc.LastName, 'ROCHA FERRAZ');
        Assert.areEqual(retornoAcc.NomeMae__c, 'ALICE ROCHA FERRAZ');
        Assert.areEqual(retornoAcc.CPF__c, '90992848458');
    }
}