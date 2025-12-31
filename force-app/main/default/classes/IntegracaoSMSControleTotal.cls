public with sharing class IntegracaoSMSControleTotal {

    public static OutputConsultarContrato consultarContratos(InputClass input){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarContratoSMSControle');

        String body = config.Body__c;
        body = body.replace('{sufixo}', input.sufixoCartao);
        body = body.replace('{numeroConta}', input.numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenSmsControleTotal(input.canal, input.cpfCliente).access_token,
                'canal' => input.canalAtendimento,
                'id_empresa' => input.idEmpresa,
                'loja' => input.loja,
                'login_operador' => input.drt,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar contratos SMS controle total', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            input.cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            input.idEmpresa,
            input.canal
        );   

        OutputConsultarContrato output = new OutputConsultarContrato();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputConsultarContrato) JSON.deserialize(objHttpResponse.getBody(), OutputConsultarContrato.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static String adesaoContrato(InputClass input){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AdesaoContratoSMSControle');

        String body = config.Body__c;
        body = body.replace('{sufixo}', input.sufixoCartao);
        body = body.replace('{numeroConta}', input.numeroConta);
        body = body.replace('{idProduto}', input.idProduto);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c,
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenSmsControleTotal(input.canal, input.cpfCliente).access_token,
                'canal' => input.canalAtendimento,
                'id_empresa' => input.idEmpresa,
                'loja' => input.loja,
                'login_operador' => input.drt,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Adesão contrato SMS controle total', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body,  
            input.cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            input.idEmpresa,
            input.canal
        );   

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            return 'OK';
        }

        if(status == '412'){
            return 'sem celular seguro';
        }

        return 'ERROR';
    }

    public static Boolean cancelarContrato(InputClass input){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CancelarContratoSMSControle');

        String body = config.Body__c;
        body = body.replace('{idAdesao}', input.idAdesao);
        body = body.replace('{codMotivoCancelar}', input.codMotivoCancelar);
        body = body.replace('{numeroConta}', input.numeroConta);
        body = body.replace('{contestado}', input.contestado);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c,
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenSmsControleTotal(input.canal, input.cpfCliente).access_token,
                'canal' => input.canalAtendimento,
                'id_empresa' => input.idEmpresa,
                'loja' => input.loja,
                'login_operador' => input.drt,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Cancelar contrato SMS controle total', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            input.cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            input.idEmpresa,
            input.canal
        );   

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            return true;
        }
        return false;
    }

    public static OutputMotivos motivosCancelamento(String cpfCliente, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MotivosCancelamentoSMSControle');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c,
            new Map<String, String> {
                'accept' => '*/*',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenSmsControleTotal(canal, cpfCliente).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Motivos cancelamento SMS controle total', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
        );   

        OutputMotivos output = new OutputMotivos();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output.motivos = (List<Motivos>) JSON.deserialize(objHttpResponse.getBody(), List<Motivos>.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }


    public class InputClass{
        public String cpfCliente;
        public String canal;
        public String canalAtendimento;
        public String codMotivoCancelar;
        public String contestado;
        public String loja;
        public String drt;
        public String idEmpresa;
        public String idAdesao;
        public String sufixoCartao;
        public String numeroConta;
        public String idProduto;
    }

    /* Response token serviços */
    public class OutputTokenServico {
        public String access_token;
        public Integer expires_in;
        public Integer refresh_expires_in;
        public String refresh_token;
        public String token_type;
        public Integer not_before_policy;
        public String session_state;
        public String scope;
        public String statusAPI;
    }

    /* Response de consultar contratos */
    public class OutputConsultarContrato {
        @AuraEnabled
        public List<Contrato> contratos;
        @AuraEnabled
        public List<Produto> produtos;
        @AuraEnabled
        public String statusResponse;
    }
    public class Contrato {
        @AuraEnabled
        public String planoValor;
        @AuraEnabled
        public String celularSMSControleTotal;
        @AuraEnabled
        public String celularCadastro;
        @AuraEnabled
        public String numeroContrato;
        @AuraEnabled
        public String tipoAdesao;
        @AuraEnabled
        public String dataAdesao;
        @AuraEnabled
        public String inicioVigencia;
        @AuraEnabled
        public String fimVigencia;
        @AuraEnabled
        public String canalAdesao;
        @AuraEnabled
        public String lojaAdesao;
        @AuraEnabled
        public String vendidoPor;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String motivoCancelamento;
        @AuraEnabled
        public String dataCancelamento;
        @AuraEnabled
        public String canalCancelamento;
        @AuraEnabled
        public String lojaCancelamento;
        @AuraEnabled
        public String canceladoPor;
    }
    public class Produto {
        @AuraEnabled
        public Integer codProdutoPR;
        @AuraEnabled
        public Integer idProduto;
        @AuraEnabled
        public String nomeProduto;
        @AuraEnabled
        public String situacao;
    }

    /* Response listar motivos de cancelamento */
    public class OutputMotivos {
        @AuraEnabled
        public List<Motivos> motivos;
        @AuraEnabled
        public String statusResponse;
    }
    public class Motivos {
        @AuraEnabled
        public String idmotivo;
        @AuraEnabled
        public String descricao;
    }

}