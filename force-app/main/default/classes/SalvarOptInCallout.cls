public with sharing class SalvarOptInCallout {
    public static Integer execute(InvocableSalvarOptIns.Input input, Varejo_Api_Callout__mdt meta){

        String token = 'Bearer ' + TokenWhatsApp.generateTokenWhatsAppCallout();
        Map<String,String> headers = new Map<String,String>{'Content-Type' => 'application/json',
                                                            'Authorization' => token,
                                                            'x-api-key' => meta.apiKey__c};
        String endpoint = meta.endpoint__c; 
        String method = meta.method__c;        
        RequestWrapper requestWrapper = new RequestWrapper(input.cpf,input.bandeira, input.versao, input.pushnotification, input.email, input.sms, input.telefone, input.thirdparty);        
        String body = JSON.serialize(requestWrapper);
        HttpResponse response = Util.executarHttpRequest(endpoint,
                                                         method, 
                                                         headers, 
                                                         body,
                                                         2000); 
       
        LogIntegracaoBO.InsertLog('Cadastrar Opt-In', endPoint, method, body, input.cpf, String.valueOf(response.getStatusCode()), response.getBody(), 'Sams');
        
        return response.getStatusCode();

    }

    public class RequestWrapper{
        private String cpf {get;set;}
        private String bandeira{get;set;}
        private String versao {get;set;}
        private Boolean pushnotification {get;set;}
        private Boolean email {get;set;}
        private Boolean sms {get;set;}
        private Boolean telefone {get;set;}
        private Boolean thirdparty {get;set;}

        public RequestWrapper(String cpf, String bandeira, String versao, Boolean pushnotification, Boolean email, Boolean sms, Boolean telefone, Boolean thirdparty){
            this.cpf = cpf;
            this.bandeira = bandeira;
            this.versao = versao;
            this.pushnotification = pushnotification;
            this.email = email;
            this.sms = sms;
            this.telefone = telefone;
            this.thirdparty = thirdparty;
        }
        
    }

    
    
}