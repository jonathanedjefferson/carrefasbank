public class BCSF_CLS_IdentificaClienteAPI {
    public static List<IdentificaClienteTO.DadosTO> calloutMethod(String token, String cpf, String canal, String unidadeNegocio){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaClienteWhatsApp');
        // unidadeNegocio = null;
        //Monta body
        String body = '{"cpf" : "'+ cpf +'"}';
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c,
            config.Method__c,
            new Map<String, String> {
                'Authorization' => token,
                'Content-Type' => 'application/json',
                'x-uat' => config.UAT__c
            },
            body,
            40000
        );
               
        System.debug('Teste Body: ' + objHttpResponse.getStatusCode());
        System.debug('Teste Body: ' + objHttpResponse.getStatus());
        System.debug('Teste Body: ' + objHttpResponse.getBody());
        List<IdentificaClienteTO.DadosTO> lstRetorno = new List<IdentificaClienteTO.DadosTO>();
        
        if (objHttpResponse.getStatusCode() == 200) {
            lstRetorno.add((IdentificaClienteTO.DadosTO)Json.deserialize(objHttpResponse.getBody(), IdentificaClienteTO.DadosTO.class));
            //unidadeNegocio = lstRetorno[0].data.cliente.contaCartao.contratos[0].unidadeNegocio;
        }

        //Registra log de integração
        LogIntegracaoBO.InsertLog(
            'IdentificaCliente', 
            config.Endpoint__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        return lstRetorno;
    }
}