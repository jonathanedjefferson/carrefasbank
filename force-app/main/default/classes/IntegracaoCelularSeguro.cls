public without sharing class IntegracaoCelularSeguro {

    public static Boolean gravarCelularSeguro(String cpf,  String numeroCelular, String numeroConta, String idEmpresa, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GravarCelularSeguro');

        String bodyAtualizado = config.Body__c;
        bodyAtualizado = bodyAtualizado.replace('{cpf}', cpf);
        bodyAtualizado = bodyAtualizado.replace('{numeroCelular}', numeroCelular);
        bodyAtualizado = bodyAtualizado.replace('{numeroConta}', numeroConta);

        user userDRT = BCSF_CadastroCelularSeguroDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'login_operador' => userDRT.DRT__c,
                'id_empresa' => idEmpresa,
                'sistema' => canal,
                'canal' => canal,
                'area' => userDRT.AreaPrincipal__c,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            bodyAtualizado, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Gravar Celular Seguro', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            bodyAtualizado, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        Boolean output = false;
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
            output = (Boolean) responseMap.get('result');
            return output;
        }    
        return output;
    }
}