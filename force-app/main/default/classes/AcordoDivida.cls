public class AcordoDivida {
    public static OutputConsultarSituacaoAcordo ConsultarSituacaoAcordo(String cpf, String idEmpresa, String canal) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarSituacaoAcordo');
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{cpf_cliente}', cpf).replace('{idEmpresa}', idEmpresa), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO ACORDO
        LogIntegracaoBO.InsertLog(
            'Consultar Situacao Acordo', 
            config.Endpoint__c + config.Path__c.replace('{cpf_cliente}', cpf).replace('{idEmpresa}', idEmpresa), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200' || status == '204'){
            return (OutputConsultarSituacaoAcordo) System.JSON.deserialize(objHttpResponse.getBody(), OutputConsultarSituacaoAcordo.class);
        } else if(status == '422') {
            ResponseErroAPI response = (ResponseErroAPI) System.JSON.deserialize(objHttpResponse.getBody(), ResponseErroAPI.class);
        
            OutputConsultarSituacaoAcordo output = new OutputConsultarSituacaoAcordo();
            Situacao situacao = new Situacao();
            situacao.codigo = response.codigo;
            output.situacao = situacao;
            return output;
        } else {
            return null;
        }
    }
        
    public static OutputValidaClienteAcordo ValidarClienteAcordo(String identificador, String dataNascimento, String idEmpresa, String cpf, String canal) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ValidarClienteAcordo');
        OutputValidaClienteAcordo retorno = new OutputValidaClienteAcordo();
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        identificador = EncodingUtil.URLENCODE(identificador,'UTF-8').replace('+', '%20');
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{identificador}', identificador).replace('{dataNascimento}', dataNascimento), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO ACORDO
        LogIntegracaoBO.InsertLog(
            'Validar Cliente Acordo', 
            config.Endpoint__c + config.Path__c.replace('{identificador}', 'STRING_TOO_LONG').replace('{dataNascimento}', dataNascimento), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200' || status == '204'){
            retorno.status = 'OK';
            retorno.situacao = true;
        } else if(status == '422'){
            retorno.status = 'Data Incorreta';
            retorno.situacao = true;
        } else {
            retorno.status = 'ERROR';
            retorno.situacao = false;
        }

        return retorno;
    }
    
    public static OutputObterBoletoAcordo ObterBoletoAcordo(String identificadorAcordo, String idEmpresa, String cpf, String canal) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterBoletoAcordo');
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{identificadorAcordo}', identificadorAcordo), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Boleto Acordo', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return (OutputObterBoletoAcordo) System.JSON.deserialize(objHttpResponse.getBody(), OutputObterBoletoAcordo.class);
        } else {
            return null;
        }
    }
    
    public static boolean EnviarBoletoAcordo(String identificadorAcordo, String idEmpresa, String cpf, String canal) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EnviarBoletoAcordo');
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c.replace('{identificadorAcordo}', identificadorAcordo), 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Boleto Acordo', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            config.Body__c.replace('{identificadorAcordo}', identificadorAcordo), 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return true;
        } else {
            return false;
        }
    }
    
    public static OutputSimularAcordo SimularAcordo(String identificadorAcordo, String vencimentoPrimeiraParcela, String diaVencimentoDemaisParcelas, String quantidadeParcelas, String idEmpresa, String cpf, String canal) {        
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SimularAcordoDivida');
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String body = config.Body__c.replace('{identificador}', identificadorAcordo)
            .replace('{vencimentoPrimeiraParcela}', vencimentoPrimeiraParcela)
            .replace('{diaVencimentoDemaisParcelas}', diaVencimentoDemaisParcelas)
            .replace('{quantidadeParcelas}', quantidadeParcelas);
            
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Simular Acordo', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());
        System.debug('==================== ' + objHttpResponse.getBody());

        if(status == '200'){
             return (OutputSimularAcordo) System.JSON.deserialize(objHttpResponse.getBody(), OutputSimularAcordo.class);
        } else {
            return null;
        }
    }
    
    public static OutputConfirmarAcordo ConfirmarAcordo(String identificadorAcordo, String canalAcordo, String formaPagamento, String idEmpresa, String cpf, String canal) {  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConfirmarAcordoDivida');
        List<ServerToServerAcordoServices.Input> listInputToken = new List<ServerToServerAcordoServices.Input>();
        ServerToServerAcordoServices.Input inputToken = new ServerToServerAcordoServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String body = config.Body__c.replace('{identificador}', identificadorAcordo)
            .replace('{canalAcordo}', canalAcordo)
            .replace('{formaPagamento}', formaPagamento);
            
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerAcordoServices.GetTokenServerToServerAcordo(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Confirmar Acordo', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    
                
        String status = String.valueOf(objHttpResponse.getStatusCode());

        if(status == '200'){
             return (OutputConfirmarAcordo) System.JSON.deserialize(objHttpResponse.getBody(), OutputConfirmarAcordo.class);
        } else {
            return null;
        }
    }

 
    // RESPONSE REFERENTE AO MÉTODO 'ConsultarSituacaoAcordo'
    public class OutputConsultarSituacaoAcordo {
        @AuraEnabled
        public Situacao situacao;
        @AuraEnabled
        public InfosCliente infosCliente;
        @AuraEnabled
        public Divida divida;
        @AuraEnabled
        public List<Contrato> contratos;
    }
  
    public class Situacao {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public String descricao;
    }
    
    public class InfosCliente {
        @AuraEnabled
        public boolean possuiEmail;
    }
    
    public class Divida {
        @AuraEnabled
        public String identificador;
        @AuraEnabled
        public Decimal valor;
        @AuraEnabled
        public String dataEnquadramento;
    }
    
    public class Contrato {
        @AuraEnabled
        public String numeroContrato;
        @AuraEnabled
        public List<Acordo> acordos;
    }
    
    public class Acordo {
        @AuraEnabled
        public Integer numeroParcela;
        @AuraEnabled
        public Decimal valorDemaisParcelas;
        @AuraEnabled
        public List<Parcela> parcelas;
        @AuraEnabled
        public String identificadorAcordo;
    }
    
    public class Parcela {
        @AuraEnabled
        public DateTime dataVencimento;
        @AuraEnabled
        public Integer numeroParcela;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String copiaCola;
        @AuraEnabled
        public String status;
    }
    
    public class PlanoParcelamento {
        @AuraEnabled
        public String identificador;
        @AuraEnabled
        public Decimal valorDesconto;
        @AuraEnabled
        public Decimal percentualDesconto;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public Decimal valorDeDesconto;
    }
    
    // RESPONSE EM CASO DE ERRO DA API
    public class ResponseErroAPI {
        public String codigo;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'ObterBoletoAcordo'
    public class OutputObterBoletoAcordo {
        @AuraEnabled
        public String boleto;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'SimularAcordo'
    public class OutputSimularAcordo {
        @AuraEnabled
        public List<PlanoParcelamento> planoParcelamentoParceirosDto;
    }
    
    // RESPONSE REFERENTE AO MÉTODO 'ConfirmarAcordo'
    public class OutputConfirmarAcordo {
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String copiaCola;
        @AuraEnabled
        public String identificador;
    }   

    public class OutputValidaClienteAcordo{
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Boolean Situacao;
    }
    
}