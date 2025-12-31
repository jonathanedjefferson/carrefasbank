global without sharing class BCSF_CLS_FlowValidaCliente {
    
    global class DadosContato{
        @AuraEnabled global String numeroConta;
        @AuraEnabled global List<Email> emails;
        @AuraEnabled global List<Telefone> telefones;
    }

    global class Email{
        @AuraEnabled global String endereco;
    }
    
    global class Telefone{
        @AuraEnabled global String ddd;
        @AuraEnabled global String numero;
        @AuraEnabled global Boolean celularSeguro;
    }

    global class ResultadoValidacao{
        @InvocableVariable global String numConta;
        @InvocableVariable global String tagbotResult;
    }

    global class DadosCartao{
        @InvocableVariable global String statusCartao;
        @InvocableVariable global Boolean ehPrimario;
    }

    @InvocableMethod
    global static List<ResultadoValidacao> validaCliente(List<List<String>> parametros){
        String numeroCelular = parametros[0][0];
        List<DadosCartao> dadosCartaoList = parseDadosCartao(parametros[0][1]);
        String jsonDadosContato = parametros[0][2];

        String statusCartaoPrimario = findCartaoPrimario(dadosCartaoList);

        List<StatusCartaoPermitidos__mdt> statusValidos_MDT = [
            SELECT StatusPermitidos__c 
            FROM StatusCartaoPermitidos__mdt 
            WHERE Label = 'Default' 
        ];

        List<String> statusValidos = statusValidos_MDT[0].StatusPermitidos__c.split(';');

        List<DadosContato> dadosContatoList = (List<DadosContato>) System.JSON.deserialize(jsonDadosContato, List<DadosContato>.class);

        Boolean numeroExiste_e_celularEhSeguro = false;
        String numConta = '';
        
        for(DadosContato ddContato : dadosContatoList){
            for(Telefone phone : ddContato.telefones){
                Boolean celularExistente = validaCelular(numeroCelular, phone) || validaCelular(formataNumeroCelular(numeroCelular), phone);
    
                if(celularExistente && phone.celularSeguro == true) {
                    numeroExiste_e_celularEhSeguro = true;
                    numConta = ddContato.numeroConta;
                }
            }
        }

        ResultadoValidacao result = new ResultadoValidacao();
        result.numConta = numConta;

        if(!numeroExiste_e_celularEhSeguro) 
            result.tagbotResult = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM CELULAR SEGURO OU INCONSISTÊNCIA DE DADOS';
        else if (!statusValidos.contains(statusCartaoPrimario)) 
            result.tagbotResult = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM ACESSO';
        else
            result.tagbotResult = 'NAVEGAÇÃO - WHATSAPP ATACADÃO - CLIENTE TEM ACESSO';

        return new List<ResultadoValidacao>{result};
    }

    private static List<DadosCartao> parseDadosCartao(String json){
        return (List<DadosCartao>) System.JSON.deserialize(json, List<DadosCartao>.class);
    }

    private static String findCartaoPrimario(List<DadosCartao> dadosCartaoList){
        for(DadosCartao ddCartao : dadosCartaoList){
            if(ddCartao.ehPrimario) return ddCartao.statusCartao;
        }

        return '';
    }

    private static Boolean validaCelular(String numeroCelular, Telefone phone){
        String numeroPhoneComDDD = phone.ddd + phone.numero;

        return (numeroCelular == phone.numero || numeroCelular == numeroPhoneComDDD);
    }

    public static String formataNumeroCelular(String numeroCelular){
        Integer ddd = 2;
        Integer numeroSemDigitoNove = 8;
        Integer numeroComDDD = ddd + numeroSemDigitoNove;

        if(numeroCelular.length() == numeroComDDD) return addNoveNoMeio(numeroCelular);

        if(numeroCelular.length() == numeroSemDigitoNove) return addNoveNoInicio(numeroCelular);

        return numeroCelular;
    }

    private static String addNoveNoMeio(String numeroComDDD){
        String ddd = numeroComDDD.substring(0,2);
        String numeroSemDDD = numeroComDDD.substring(2);

        return ddd + addNoveNoInicio(numeroSemDDD);
    }

    private static String addNoveNoInicio(String numeroSemDDD){
        return '9' + numeroSemDDD;
    }
}