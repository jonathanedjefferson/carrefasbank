public with sharing class MelhorDiaCompraBot {
    @invocableMethod(label='Get Melhor Dia de Compra')
    public static List<OutputMelhorDia> getMelhorDiaCompra(List<InputMelhorDia> input){
        List<OutputMelhorDia> listReturn = new List<OutputMelhorDia>();
        OutputMelhorDia retorno = new OutputMelhorDia();
        retorno.statusMelhorDiaCompra = false;
        
        //PEGANDO METADADO CUSTOM organizationType
        organizationType__mdt orgType = organizationType__mdt.getInstance('genericOrg');

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MelhorDiaCompra');
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c.replace('{numeroConta}', input[0].Conta), 
            config.Method__c,
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'cpf' => input[0].CPF,
                'Authorization' => 'Bearer ' + input[0].token,
                'x-uat' => UserInfo.getOrganizationId() == orgType.organizationId__c ? orgType.uatNumber__c : ''

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        String statusCode = String.valueOf(objHttpResponse.getStatusCode());
        
        LogIntegracaoBO.InsertLog(
            'Melhor dia de Compra', 
            config.Endpoint__c.replace('{numeroConta}', input[0].Conta), 
            config.Method__c, 
            config.Body__c,
            String.valueOf(input[0].CPF),
            statusCode,
            objHttpResponse.getBody(),
            input[0].unidadeNegocio,
            input[0].canal.capitalize()
        );

        if(statusCode.equals('200') || statusCode.equals('204')){
            retorno = (OutputMelhorDia) System.JSON.deserialize(objHttpResponse.getBody(), OutputMelhorDia.class);
            retorno.MelhorDiaNumber = Integer.valueOf(retorno.melhorDiaCompra);
            retorno.statusMelhorDiaCompra = true;
        }
        
        listReturn.add(retorno);
        return listReturn;
    }

    public class InputMelhorDia{
        @InvocableVariable(required = true)
        public String CPF;
        @InvocableVariable(required = true)
        public String Token;
        @InvocableVariable(required = true)
        public String Conta;
        @InvocableVariable(required = true)
        public String unidadeNegocio;
        @InvocableVariable(required = true)
        public String canal;
    }

    public class OutputMelhorDia{
        @InvocableVariable()
        public Integer MelhorDiaNumber;
        @InvocableVariable()
        public String melhorDiaCompra;
        @InvocableVariable()
        public Boolean statusMelhorDiaCompra;
    }
}