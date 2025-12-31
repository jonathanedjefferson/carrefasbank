public class IntegrationEndereco {
    public static OutputEndereco GetEnderecoByCEP(String cpf, String idEmpresa, String canal, String cep){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetEnderecoByCep');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{CEP}', cep), 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        String statusCode = String.valueOf(objHttpResponse.getStatusCode());
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Endereço Através de CEP', 
            config.Endpoint__c + config.Path__c.replace('{CEP}', cep), 
            config.Method__c, 
            config.Body__c,
            cpf, 
            statusCode, 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        ); 
        OutputEndereco retorno = new OutputEndereco();
        retorno.StatusAPI = 'ERROR';
        if (statusCode.equals('200') || statusCode.equals('204')) {
            retorno = (OutputEndereco) JSON.deserialize(objHttpResponse.getBody(), OutputEndereco.class);
            retorno.StatusAPI = 'OK';
        }
        return retorno;
    }

// ######################################## RESPONSE DO METODO 'GetEnderecoByCEP' ########################################
    public class OutputEndereco{
        @AuraEnabled
        public String StatusAPI;
        @AuraEnabled
        public String logradouro;
        @AuraEnabled
        public String bairro;
        @AuraEnabled
        public String cidade;
        @AuraEnabled
        public String uf;
    }
// ######################################## FIM RESPONSE DO METODO 'GetEnderecoByCEP' ########################################
}