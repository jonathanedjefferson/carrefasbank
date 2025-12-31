public without sharing class IntegracaoControleOperacoesLegacy {

    public static OutputListaLojas listagemHierarquias(String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListagemHierarquias');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'DrtOrCpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listagem de hierarquias Legado', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
        );   

        OutputListaLojas output = new OutputListaLojas();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputListaLojas) JSON.deserialize(objHttpResponse.getBody(), OutputListaLojas.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputListaTipoEventos listagemTipoEventos(String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListagemTipoEventos');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'accept' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listagem de tipo eventos Legado', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            String.valueOf(objHttpResponse.getStatusCode()) == '200' ? '' : objHttpResponse.getBody(),
            idEmpresa,
            canal
        );   

        OutputListaTipoEventos output = new OutputListaTipoEventos();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output.response = (List<evento>) JSON.deserialize(objHttpResponse.getBody(), List<evento>.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputConsultarOperacoes consultarOperacoes(String bodyJson,  String cpf,  String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarOperacoesLegacy');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            bodyJson, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar Operações Legado', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            bodyJson, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
        );   

        OutputConsultarOperacoes output = new OutputConsultarOperacoes();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputConsultarOperacoes) JSON.deserialize(objHttpResponse.getBody(), OutputConsultarOperacoes.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    /* Output lista de hierarquias */
    public class OutputListaLojas{
        @AuraEnabled
        public List<Lojas> response;
        @AuraEnabled
        public String statusResponse;
    }
    public class Lojas{
        @AuraEnabled
        public String descricao;
        @AuraEnabled
        public String codigoSitef;
    } 

    /* Output lista de evento */
    public class OutputListaTipoEventos{
        @AuraEnabled
        public List<evento> response;
        @AuraEnabled
        public String statusResponse;
    }
    public class evento{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String nome;
    }

    /*  Output consultar operações*/
    public with sharing class OutputConsultarOperacoes {
        @AuraEnabled
        public Integer tamanhoPagina;
        @AuraEnabled
        public Integer pagina;
        @AuraEnabled
        public Integer totalItens;
        @AuraEnabled
        public String statusResponse;
        @AuraEnabled
        public List<operacao> data;
    }
    public class operacao {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String dataOperacao;
        @AuraEnabled
        public String empresa;
        @AuraEnabled
        public String loja;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String canal;
        @AuraEnabled
        public String usuario;
        @AuraEnabled
        public String acao;
        @AuraEnabled
        public String evento;
        @AuraEnabled
        public List<Conteudo> conteudos;
    }
    public class Conteudo {
        @AuraEnabled
        public String conteudoAuditoria;
    }
}