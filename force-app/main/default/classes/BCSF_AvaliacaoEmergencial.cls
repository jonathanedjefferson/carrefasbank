public class BCSF_AvaliacaoEmergencial {
    public static String consultarDadosAvaliacao(String cpf, String numeroConta, String area, String canal) {
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AvaliacaoEmergencialConsultar');
        String response;
        String endpoint = config.Endpoint__c + config.Path__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'text/plain',
                'Content-Type' => 'application/json-patch+json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'numeroConta' => numeroConta,
                'area' => area,
                'canal' => canal,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Consultar dados avaliação emergencial', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );  

        if(objHttpResponse.getStatusCode() == 200){
            response =  objHttpResponse.getBody();
        }

        system.debug(objHttpResponse.getBody());
        
        return response;
    }

    public static String gravarDadosAvaliacaoAdesao(String cpf, String numeroConta, String area, String canal, String idEmpresa, String Operacao){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AvaliacaoEmergencialGravar');
        String response;
        String endpoint = config.Endpoint__c + config.Path__c;

        String body = config.Body__c.replace('{operacao}', operacao);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'text/plain',
                'Content-Type' => 'application/json-patch+json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'numeroConta' => numeroConta,
                'area' => area,
                'canal' => canal,
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Gravar dados avaliação emergencial', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );  

        if(objHttpResponse.getStatusCode() == 200){
            response =  objHttpResponse.getBody();
        }

        system.debug(objHttpResponse.getBody());
        
        return response;
    }

    /*
    public static String consultarTaxasAvaliacao(String cpf, String numeroConta, String area, String canal, String produto, String dataConta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AvaliacaoEmergencialTaxas');
        String response;
        String endpoint = config.Endpoint__c + config.Path__c;

        String body = config.Body__c.replace('{produto}', produto)
        .replace('{dataAberturaConta}', dataConta);
        
        

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'text/plain',
                'Content-Type' => 'application/json-patch+json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'numeroConta' => numeroConta,
                'area' => area,
                'canal' => canal,
                'x-uat' => config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Consultar taxas avaliação emergencial', 
            endpoint, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );  

        if(objHttpResponse.getStatusCode() == 200){
            response =  objHttpResponse.getBody();
        }

        system.debug(objHttpResponse.getBody());
        
        return response;
    }
    */

    public static String consultarTermoAvaliacao(String cpf, String numeroConta, String area, String canal, String tipo){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AvaliacaoEmergencialTermo');
        String response;
        String endpoint = config.Endpoint__c + config.Path__c;

        String body = config.Body__c.replace('{tipo}', tipo);
        system.debug(body);
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'text/plain',
                'Content-Type' => 'application/json-patch+json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'numeroConta' => numeroConta,
                'area' => area,
                'canal' => canal,
                'x-uat' => config.UAT__c
            }, 
            body,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Consultar termos avaliação emergencial', 
            endpoint, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );  

        
        if(objHttpResponse.getStatusCode() == 200){
            response =  objHttpResponse.getBody();
        }

        system.debug('response:'+objHttpResponse.getBody());
        
        return response;
    }
}