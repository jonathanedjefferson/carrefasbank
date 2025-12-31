public with sharing class BCSF_ContaDigital {
    public static BCSF_ContaDigitalTO.ResponseConta buscarContaDigital(String canal, String customerId) {

        BCSF_ContaDigitalTO.ResponseConta respBody = new BCSF_ContaDigitalTO.ResponseConta();

        CarrefourAPICallout__mdt config =
            CarrefourAPICalloutDAO.getInstance().getByLabel('ContaDigitalContaStatus');

        String endpoint = config.Endpoint__c + config.Path__c;
        endpoint = endpoint.replace('{{customerId}}', customerId);
        System.debug(endpoint);
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept'        => 'application/json',
                'Content-Type'  => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenContaDigital(canal).access_token
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
        System.debug(objHttpResponse);
        LogIntegracaoBO.InsertLog(
            'Conta Digital - Consulta Conta Status',
            endpoint,
            config.Method__c,
            null,
            null,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );


        if (objHttpResponse.getStatusCode() == 200 || objHttpResponse.getStatusCode() == 204){

            respBody = (BCSF_ContaDigitalTO.ResponseConta)JSON.deserialize(objHttpResponse.getBody(), BCSF_ContaDigitalTO.ResponseConta.class);
        }

        return respBody;
    }

    public static BCSF_ContaDigitalTO.ResponseSaldo buscarSaldoContaDigital(String canal, String accountNumber) {
        BCSF_ContaDigitalTO.ResponseSaldo respBody = new BCSF_ContaDigitalTO.ResponseSaldo();
    
        CarrefourAPICallout__mdt config =
            CarrefourAPICalloutDAO.getInstance().getByLabel('ContaDigitalSaldo');
    
        String endpoint = config.Endpoint__c + config.Path__c;
        endpoint = endpoint.replace('{{accountNumber}}', accountNumber);
    
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept'        => 'application/json',
                'Content-Type'  => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenContaDigital(canal).access_token
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
    
        System.debug(objHttpResponse);
    
        LogIntegracaoBO.InsertLog(
            'Conta Digital - Consulta Saldo',
            endpoint,
            config.Method__c,
            null,
            null,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
    
        if (objHttpResponse.getStatusCode() == 200 && String.isNotBlank(objHttpResponse.getBody())) {
            respBody = (BCSF_ContaDigitalTO.ResponseSaldo)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_ContaDigitalTO.ResponseSaldo.class);
        }
    
        return respBody;
    }

    public static BCSF_ContaDigitalTO.ResponseExtrato buscarExtratoContaDigital(String canal, String accountNumber, Integer page, Integer pageSize,
    Date initDate, Date endDate) {
        BCSF_ContaDigitalTO.ResponseExtrato respBody = new BCSF_ContaDigitalTO.ResponseExtrato();

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContaDigitalExtrato');

        String initDateStr = initDate.year() + '-' +
        String.valueOf(initDate.month()).leftPad(2, '0') + '-' +
        String.valueOf(initDate.day()).leftPad(2, '0');
        
        String endDateStr = endDate.year() + '-' +
            String.valueOf(endDate.month()).leftPad(2, '0') + '-' +
            String.valueOf(endDate.day()).leftPad(2, '0');
        
        String endpoint = config.Endpoint__c + config.Path__c;
        endpoint = endpoint
            .replace('{{accountNumber}}', accountNumber)
            .replace('{{page}}', String.valueOf(page))
            .replace('{{pageSize}}', String.valueOf(pageSize))
            .replace('{{initDate}}', initDateStr)
            .replace('{{endDate}}', endDateStr);

        System.debug(endpoint);
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept'        => 'application/json',
                'Content-Type'  => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenContaDigital(canal).access_token
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );

        System.debug(objHttpResponse);

        LogIntegracaoBO.InsertLog(
            'Conta Digital - Consulta Extrato',
            endpoint,
            config.Method__c,
            null,
            null,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );

        if (objHttpResponse.getStatusCode() == 200 && String.isNotBlank(objHttpResponse.getBody())) {
            respBody = (BCSF_ContaDigitalTO.ResponseExtrato)
                JSON.deserialize(objHttpResponse.getBody(), BCSF_ContaDigitalTO.ResponseExtrato.class);
        }

        return respBody;
    }

    public static List<BCSF_ContaDigitalTO.ResponseTipoBloqueio> listarTiposBloqueioContaDigital(String canal) {
        List<BCSF_ContaDigitalTO.ResponseTipoBloqueio> respList =
            new List<BCSF_ContaDigitalTO.ResponseTipoBloqueio>();
    
        CarrefourAPICallout__mdt config =
            CarrefourAPICalloutDAO.getInstance().getByLabel('ContaDigitalListaBloqueio');
    
        String endpoint = config.Endpoint__c + config.Path__c;
    
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint,
            config.Method__c,
            new Map<String, String>{
                'accept'        => 'application/json',
                'Content-Type'  => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetTokenContaDigital(canal).access_token
            },
            null,
            Integer.valueOf(config.Timeout__c)
        );
    
        System.debug(objHttpResponse);
    
        LogIntegracaoBO.InsertLog(
            'Conta Digital - Lista Tipos Bloqueio',
            endpoint,
            config.Method__c,
            null,
            null,
            String.valueOf(objHttpResponse.getStatusCode()),
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
    
        if (objHttpResponse.getStatusCode() == 200 && String.isNotBlank(objHttpResponse.getBody())) {
            respList = (List<BCSF_ContaDigitalTO.ResponseTipoBloqueio>)
                JSON.deserialize(
                    objHttpResponse.getBody(),
                    List<BCSF_ContaDigitalTO.ResponseTipoBloqueio>.class
                );
        }
    
        return respList;
    }
    

    

}