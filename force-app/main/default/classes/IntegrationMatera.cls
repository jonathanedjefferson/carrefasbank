public class IntegrationMatera {

    private static final Map<String, String> lMapRequestParams = new Map<String, String> {
        '{numeroAgenciaDoc}' => 'NumeroAgencia__c',
        '{nomeFavorecido}' => 'NomeCompleto__c',
        '{cpfCnpjFavorecido}' => 'NumeroDocumento__c',
        '{valor}' => 'Valor__c',
        '{numContrato}' => 'CaseNumber'
    };

    private static final Map<String, String> lMapAccountTypes = new Map<String, String> {
        'Corrente' => '1', 
        'Poupança' => '2'
    };

    public static StatusTransaction getTransactionStatus(String idLiquidacao, String canal) {

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultaStatusTransacaoMatera');
 
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{idLiquidacao}', idLiquidacao), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Consultar Status Transação Matera', 
            config.Endpoint__c + config.Path__c.replace('{idLiquidacao}', idLiquidacao), 
            config.Method__c, 
            config.Body__c,  
            '', 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            '',
            canal.capitalize()
        );

        StatusTransaction retornoAPI = new StatusTransaction();

        if (objHttpResponse.getStatusCode() == 200) {
            retornoAPI = (StatusTransaction) JSON.deserialize(objHttpResponse.getBody(), StatusTransaction.class);
            retornoAPI.statusAPI = 'OK';
            return retornoAPI;
        }

        if (objHttpResponse.getStatusCode() == 400) { //Cancelado pelo SPB
            retornoAPI = (StatusTransaction) JSON.deserialize(objHttpResponse.getBody(), StatusTransaction.class);
            retornoAPI.statusAPI = 'CANCELADO';
            return retornoAPI;
        }

        retornoAPI.statusAPI = 'ERROR';

        return retornoAPI;
    }

    public static SendTransactionResponse sendDocTedMatera(Case currentCase, String canal) {

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EnvioDocTedMatera');
        String body = buildBodyRequest(currentCase, config.Body__c);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
                'Authorization' => 'Bearer ' + TokenCSFServicos.GetToken(canal).access_token,
                'Idempotency-id' => currentCase.Id + currentCase.NumeroDocumento__c,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Envio TED/DOC Matera', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body,  
            '', 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(), 
            '',
            canal.capitalize()
        );

        SendTransactionResponse retornoAPI = new SendTransactionResponse();

        if (objHttpResponse.getStatusCode() == 200 || objHttpResponse.getStatusCode() == 201) {
            retornoAPI = (SendTransactionResponse) JSON.deserialize(objHttpResponse.getBody(), SendTransactionResponse.class);
            retornoAPI.statusAPI = 'OK';
        }else{
            retornoAPI.statusAPI = 'ERROR';
        }

        return retornoAPI;
    }

    private static String buildBodyRequest(Case aCase, String aBody) {
        for (String key : lMapRequestParams.keySet()) {
            aBody = aBody.replace(key, String.valueOf(aCase.get(lMapRequestParams.get(key))));
        }

        aBody = aBody.replace('{dtLiqdc}', String.valueOf(Date.today()));
        aBody = aBody.replace('{numeroContaDoc}', String.valueOf(aCase.NumeroConta__c) + String.valueOf(aCase.DigitoConta__c));
        aBody = aBody.replace('{idTipoContaCredito}', lMapAccountTypes.get(aCase.TipoConta__c));
        aBody = aBody.replace('{idTipoPessoa}', getIdTipoPessoa(aCase.NumeroDocumento__c));
        aBody = aBody.replace('{idBancoDoc}', String.valueOf(Integer.valueOf(aCase.Banco__r.NumeroCodigo__c)));
        aBody = aCase.ContaDebitar__c == '204' ? aBody.replace('{codigoFinalidadeSpb}', '40') : aBody.replace('{codigoFinalidadeSpb}', '99999');
        aBody = aBody.replace('{codigoHistoricoLiquidacaoDoc}', String.valueOf(aCase.ContaDebitar__c));
        aBody = aBody.replace('{historico}', String.valueOf(aCase.ContaDebitar__c));

        return aBody;
    }

    private static String getIdTipoPessoa(String numeroDocumento) {
        return numeroDocumento.length() == 11 ? 'F' : 'J';
    }

    public class StatusTransaction {
        public Data data;
        public String statusAPI;
        public List<Error> error;
    }

    public class SendTransactionResponse {
        public Data data;
        public String statusAPI;
    }

    public class Data {
        public String idLiquidacao;
        public String situacaoSPB;
    }

    public class Error {
        public String code;
        public String message;
    }
}