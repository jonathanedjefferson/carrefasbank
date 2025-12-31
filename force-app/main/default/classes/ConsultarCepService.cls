public with sharing class ConsultarCepService {
    static Varejo_Api_Callout__mdt config = Varejo_Api_Callout__mdt.getInstance('ConsultaCep');
    
    public static ResponseCep execute(String cep){

        String token = TokenWhatsApp.generateTokenWhatsAppCallout();
        Map<String,String> headers = new Map<String,String>
        {
            'Content-Type'=> 'application/json',
            'Authorization'=> 'Bearer ' + token
        };
        String body = JSON.serialize( new RequestCep(cep));
        HttpResponse response = Util.executarHttpRequest(config.endPoint__c, 'POST', headers,body, 2000); 
        LogIntegracaoBO.InsertLog('Consultar Cep', config.endPoint__c, 'Post', body, 'null', String.valueOf(response.getStatusCode()), response.getBody(), 'Carrefur');
        ResponseCep responseTO = (ResponseCep)JSON.deserialize(response.getBody(),ResponseCep.class);
        return responseTO;        
    }

    public class RequestCep{
        public String cep;
        public RequestCep(String cep){
            this.cep = cep;
        }
    }

    public class ResponseCep{
        public Boolean success { get; set; }
        public PayloadTO payload { get; set; }
        public String error { get; set; }
    }

    public class PayloadTO {
        public String uf { get; set; }
        public String cidade { get; set; }
        public String bairro { get; set; }
        public String logradouro { get; set; }
    }
   
}