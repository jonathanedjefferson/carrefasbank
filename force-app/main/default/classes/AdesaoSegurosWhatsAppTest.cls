@isTest
public class AdesaoSegurosWhatsAppTest {
    @TestSetup
    static void makeData(){
        String recordTypeIdContaFinanceira = Schema.SObjectType.ContaFinanceira__c.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CFI_ContaFinanceira').getRecordTypeId();
        String recordTypeIdContaPessoal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BCSF_RT_PAC_ClientePessoalCarrefour').getRecordTypeId();

        Account accountNomeCliente = new Account(
            RecordTypeId = recordTypeIdContaPessoal,
            LastName = 'Teste Account',
            CPF__c = '49599020006'
        );
        insert accountNomeCliente;

        ContaFinanceira__c contaFinceira = new ContaFinanceira__c(
            RecordTypeId = recordTypeIdContaFinanceira,
            NomeCliente__c = accountNomeCliente.Id,
            NumeroConta__c = '00977880022825672'
        );
        insert contaFinceira;
    }

    @isTest
    public static void validarAdesaoSegurosWhatsApp(){
        // mock requisicao api
        HttpResponse responseServerToServer = new HttpResponse();
        responseServerToServer.setStatusCode(200);
        responseServerToServer.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiS","expires_in":3600,"refresh_expires_in":1800,"refresh_token":"gT-DzqndCLMTo","token_type":"bearer","not-before-policy":0,"session_state":"af5561a9159b","scope":"profile"}');
        
        HttpResponse responseAdesaoSeguros = new HttpResponse();
        responseAdesaoSeguros.setStatusCode(200);
        responseAdesaoSeguros.setBody('{"idAdesao":100000,"mensagem":"Adesao Realizada com Sucesso..."}');

        Map<String, HttpResponse> responseByEndpoint = new Map<String, HttpResponse>{
                '/csf-servicos' => responseServerToServer, 
                'seguros/api/v1/seguroswhatsapp/realizar-adesao' => responseAdesaoSeguros
        };

        Test.setMock(HttpCalloutMock.class, new CancelamentoContaMock(responseByEndpoint));
        // input
        List<AdesaoSegurosWhatsApp.InputAdesaoSeguros> listaInput = new List<AdesaoSegurosWhatsApp.InputAdesaoSeguros>();
        AdesaoSegurosWhatsApp.InputAdesaoSeguros input = new AdesaoSegurosWhatsApp.InputAdesaoSeguros();
        input.cpf = '49599020006';
        input.numeroConta = '00977880022825672';
        input.codCanalVenda = '888888888';
        input.codLoja = '20030000391';
        input.email = '';
        input.nomeLoja = '109';
        input.idProduto = '1';
        input.nomeProduto = 'Seguro Aquisição';
        input.nomePlano = 'Plano Teste';
        input.idPlano = '2409';
        input.canal = 'Whatsapp';
        listaInput.add(input);
        // test
        Test.StartTest();
        List<AdesaoSegurosWhatsApp.Retorno> retorno = AdesaoSegurosWhatsApp.AdesaoSeguro(listaInput);
        Test.StopTest();

        Assert.areEqual('Adesao Realizada com Sucesso...', retorno[0].mensagem, 'requisição realizada com sucesso!');
        Assert.areEqual(100000, retorno[0].idAdesao, 'id adesão atribuído, requesição realizada com sucesso!');
    }

    @isTest
    public static void validarContaFinanceiraNaoRetornada(){
        // input
        List<AdesaoSegurosWhatsApp.InputAdesaoSeguros> listaInput = new List<AdesaoSegurosWhatsApp.InputAdesaoSeguros>();
        AdesaoSegurosWhatsApp.InputAdesaoSeguros input = new AdesaoSegurosWhatsApp.InputAdesaoSeguros();
        input.cpf = '49599020006';
        input.numeroConta = '00977880022825660';
        input.codCanalVenda = '888888888';
        input.codLoja = '20030000391';
        input.email = '';
        input.nomeLoja = '109';
        input.idProduto = '1';
        input.nomeProduto = 'Seguro Aquisição';
        input.nomePlano = 'Plano Teste';
        input.idPlano = '2409';
        listaInput.add(input);
        // test
        Test.StartTest();
        List<AdesaoSegurosWhatsApp.Retorno> retorno = AdesaoSegurosWhatsApp.AdesaoSeguro(listaInput);
        Test.StopTest();

        Assert.areEqual('Conta finaceira não retornada!', retorno[0].mensagem, 'mensagem de retorno correta, teste realizado com sucesso!');
        Assert.areEqual(null, retorno[0].idAdesao, 'o valor retornado é esperado.');
    }
}