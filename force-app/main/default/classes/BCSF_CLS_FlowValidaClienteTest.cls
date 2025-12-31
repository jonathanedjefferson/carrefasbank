@isTest
public with sharing class BCSF_CLS_FlowValidaClienteTest {
    @isTest
    static void shouldValidaCliente(){

        String jsonDadosContatoMock = '[{"telefones":[{"celularSeguro":true,"numero":"11988888888","ddd":""}],"emails":[{"endereco":"FAKE@PERSON.COM"}],"numeroConta":"11000011111"}]]"';
        String jsonDadosCartao = '[{"numeroCartao":"0000.XXXX.XXXX.0000","statusCartao":"NORM","ehPrimario":true}, {"numeroCartao":"0000.XXXX.XXXX.1111","statusCartao":"FFFF","ehPrimario":false}]';
        
        //Primeiro Cenario
        String numeroCelular = '1190909090';

        List<List<String>> parametrosPrimeiroCenario = new List<List<String>>{new List<String>{numeroCelular, jsonDadosCartao, jsonDadosContatoMock}};

        List<BCSF_CLS_FlowValidaCliente.ResultadoValidacao> result = BCSF_CLS_FlowValidaCliente.validaCliente(parametrosPrimeiroCenario);
        String expectedPrimeiroCenario = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM CELULAR SEGURO OU INCONSISTÊNCIA DE DADOS';

        System.assertEquals(result[0].tagbotResult, expectedPrimeiroCenario, 'A validacao de telefone nao funcionou');

        //Segundo Cenario
        numeroCelular = '11988888888';
        String jsonDadosCartaoInvalido = '[{"numeroCartao":"0000.XXXX.XXXX.0000","statusCartao":"NORM","ehPrimario":false}, {"numeroCartao":"0000.XXXX.XXXX.1111","statusCartao":"FFFF","ehPrimario":true}]';

        List<List<String>> parametrosSegundoCenario = new List<List<String>>{new List<String>{numeroCelular, jsonDadosCartaoInvalido, jsonDadosContatoMock}};

        result = BCSF_CLS_FlowValidaCliente.validaCliente(parametrosSegundoCenario);
        String expectedSegundoCenario = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM ACESSO';
        
        System.assertEquals(result[0].tagbotResult, expectedSegundoCenario, 'A validacao de status nao funcionou');

        //Terceiro Cenario
        numeroCelular = '11988888888'; 

        List<List<String>> parametrosTerceiroCenario = new List<List<String>>{new List<String>{numeroCelular, jsonDadosCartao, jsonDadosContatoMock}};

        result = BCSF_CLS_FlowValidaCliente.validaCliente(parametrosTerceiroCenario);
        String expectedTerceiroCenario = 'NAVEGAÇÃO - WHATSAPP ATACADÃO - CLIENTE TEM ACESSO';
        
        System.assertEquals(result[0].tagbotResult, expectedTerceiroCenario, 'A validacao de status e/ou telefone nao funcionaram');
    }

    @isTest
    static void shouldNumeroCelular(){
        String ddd = '11';
        String digitoNove = '9';
        String numero = '70707070';

        String celularFormatadoCompleto = BCSF_CLS_FlowValidaCliente.formataNumeroCelular(ddd + numero);
        System.assertEquals(ddd + digitoNove + numero, celularFormatadoCompleto, 'O método que adiciona um digito nove entre o DDD e o numero do celular não funcionou corretamente.');

        String celularFormatadoSemDDD = BCSF_CLS_FlowValidaCliente.formataNumeroCelular(numero);
        System.assertEquals(digitoNove + numero, celularFormatadoSemDDD, 'O método que adiciona um digito nove na frente do numero do celular não funcionou corretamente');

        String celularInalterado = BCSF_CLS_FlowValidaCliente.formataNumeroCelular(ddd + digitoNove + numero);
        System.assertEquals(ddd + digitoNove + numero, celularInalterado, 'O métoodo que formata o numero do celular fez a formatação quando não deveria');
    }

    @isTest
    static void shouldExistCustomMetadata(){
        List<StatusCartaoPermitidos__mdt> statusValidos_MDT = [
            SELECT StatusPermitidos__c 
            FROM StatusCartaoPermitidos__mdt 
            WHERE Label = 'Default' 
        ];

        System.assert(!statusValidos_MDT.isEmpty(), 'O custom metadata StatusCartaoPermitidos__mdt nao foi encontrado na organizacao');
    }
}