public class LogIntegracaoBO {
    public static void InsertLog(String nomeServico, String endpoint, String metodo, String body, String cpf, String status, String responseBody, String unidadeNegocio) {
        if (unidadeNegocio == 'CSF' || unidadeNegocio == 'CRF' || unidadeNegocio == '1') {
            unidadeNegocio = '1';
        }else if(unidadeNegocio == 'ATC' || unidadeNegocio == '2') {
            unidadeNegocio = '2';
        }else if(unidadeNegocio == 'SAMS' || unidadeNegocio == '6'){
            unidadeNegocio = '6';
        }else{
            unidadeNegocio = null;
        }
        
        // CRIANDO INSTANCIA DE UM EVENTO
        LogIntegracaoEvent__e logEvent = new LogIntegracaoEvent__e(
            NomeServico__c = nomeServico,
            URL__c = endpoint,
            Metodo__c = metodo,
            RequestBody__c = body,
            CPF__c = cpf,
            Status__c = status,
            ResponseBody__c = responseBody,
            UnidadeNegocio__c = unidadeNegocio
        );
        // PUBLICANDO EVENTO
        Database.SaveResult sr = EventBus.publish(logEvent);
    }


    public static void InsertLog(String nomeServico, String endpoint, String metodo, String body, String cpf, String status, String responseBody, String unidadeNegocio, String canal) {
        if (unidadeNegocio == 'CSF' || unidadeNegocio == 'CRF' || unidadeNegocio == '1') {
            unidadeNegocio = '1';
        }else if(unidadeNegocio == 'ATC' || unidadeNegocio == '2') {
            unidadeNegocio = '2';
        }else if(unidadeNegocio == 'SAMS' || unidadeNegocio == '6'){
            unidadeNegocio = '6';
        }else{
            unidadeNegocio = null;
        }
        
        // CRIANDO INSTANCIA DE UM EVENTO
        LogIntegracaoEvent__e logEvent = new LogIntegracaoEvent__e(
            NomeServico__c = nomeServico,
            URL__c = endpoint,
            Metodo__c = metodo,
            RequestBody__c = body,
            CPF__c = cpf,
            Status__c = status,
            ResponseBody__c = responseBody,
            UnidadeNegocio__c = unidadeNegocio,
            Canal__c = canal
        );
        // PUBLICANDO EVENTO
        Database.SaveResult sr = EventBus.publish(logEvent);
    }

    public static void InsertLog(String nomeServico, String endpoint, String metodo, String body, String cpf, String status, String responseBody, String unidadeNegocio, String canal, String usuarioId) {
        if (unidadeNegocio == 'CSF' || unidadeNegocio == 'CRF' || unidadeNegocio == '1') {
            unidadeNegocio = '1';
        }else if(unidadeNegocio == 'ATC' || unidadeNegocio == '2') {
            unidadeNegocio = '2';
        }else if(unidadeNegocio == 'SAMS' || unidadeNegocio == '6'){
            unidadeNegocio = '6';
        }else{
            unidadeNegocio = null;
        }
        
        // CRIANDO INSTANCIA DE UM EVENTO
        LogIntegracaoEvent__e logEvent = new LogIntegracaoEvent__e(
            NomeServico__c = nomeServico,
            URL__c = endpoint,
            Metodo__c = metodo,
            RequestBody__c = body,
            CPF__c = cpf,
            Status__c = status,
            ResponseBody__c = responseBody,
            UnidadeNegocio__c = unidadeNegocio,
            Canal__c = canal,
            userId__c =  usuarioId
        );
        // PUBLICANDO EVENTO
        Database.SaveResult sr = EventBus.publish(logEvent);
    }

    public static void InsertLogIntegracao(String nomeServico, String endpoint, String metodo, String body, String cpf, String status, String responseBody, String unidadeNegocio, String canal, String header) {
        if (unidadeNegocio == 'CSF' || unidadeNegocio == 'CRF' || unidadeNegocio == '1') {
            unidadeNegocio = '1';
        }else if(unidadeNegocio == 'ATC' || unidadeNegocio == '2') {
            unidadeNegocio = '2';
        }else if(unidadeNegocio == 'SAMS' || unidadeNegocio == '6'){
            unidadeNegocio = '6';
        }else{
            unidadeNegocio = null;
        }
        
        // CRIANDO INSTANCIA DE UM EVENTO
        LogIntegracaoEvent__e logEvent = new LogIntegracaoEvent__e(
            NomeServico__c = nomeServico,
            URL__c = endpoint,
            Metodo__c = metodo,
            RequestBody__c = body,
            CPF__c = cpf,
            Status__c = status,
            ResponseBody__c = responseBody,
            UnidadeNegocio__c = unidadeNegocio,
            Canal__c = canal,
            RequestHeaders__c = header
        );
        // PUBLICANDO EVENTO
        Database.SaveResult sr = EventBus.publish(logEvent);
    }
}