public without sharing class IdentificacaoPositiva {
    public static OutputPerguntas Perguntas(String sistema, String canal, String cpf, String idEmpresa, String numeroConta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdPositivaPerguntas');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetTokenV2('cockpit').access_token
            }, 
            config.Body__c.replace('{sistema}', sistema).replace('{canal}', canal).replace('{cpf}', cpf).replace('{IdEmpresa}', IdEmpresa).replace('{loginOperador}', loginOperador).replace('{numeroConta}', numeroConta),
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Identificação Positiva - Perguntas', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            config.Body__c.replace('{sistema}', sistema).replace('{canal}', canal).replace('{cpf}', cpf).replace('{IdEmpresa}', IdEmpresa).replace('{loginOperador}', loginOperador).replace('{numeroConta}', numeroConta),
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    

        OutputPerguntas retorno = new OutputPerguntas();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (OutputPerguntas) System.JSON.deserialize(objHttpResponse.getBody(), OutputPerguntas.class);
            retorno.Status = 'OK';
        }else if(status == '422'){
            retorno.Status = String.valueOf(System.JSON.deserializeUntyped(objHttpResponse.getBody())).replace('{mensagem=', '').split(',')[0];
        }else{
            retorno.Status = 'ERROR';
        }
        System.debug('retorno_OutputPerguntas:' + retorno);
        return retorno;  
    }


    public static OutputValidarPerguntas ValidarPerguntas(String sessao, Map<String, String> mapPerguntasRespostas, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdPositivaValidarPerguntas');     
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        // MONTANDO O BODY JSON
        String body = config.Body__c.replace('{sessao}', sessao);
        String json = '';
        Integer cont = 0;
        for (String item: mapPerguntasRespostas.keySet()) {
            cont++;
        
            if (cont == mapPerguntasRespostas.size()) {
                json += '{"Id" : "' + item + '", "indexAlternativa" : "' + mapPerguntasRespostas.get(item) + '"}';
            }else{
                json += '{"Id" : "' + item + '", "indexAlternativa" : "' + mapPerguntasRespostas.get(item) + '"},';
            }        
        }

        // FAZENDO A CHAMADA
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetTokenV2('cockpit').access_token
            }, 
            body.replace('{ListaPerguntasRespostas}', json),
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Identificação Positiva - Validar Perguntas', 
            config.Endpoint__c + config.Path__c,
            config.Method__c, 
            body.replace('{ListaPerguntasRespostas}', json),
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );    

        OutputValidarPerguntas retorno = new OutputValidarPerguntas();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (OutputValidarPerguntas) System.JSON.deserialize(objHttpResponse.getBody(), OutputValidarPerguntas.class);
            retorno.Status = 'OK';
        }else{
            retorno.Status = 'ERROR';
        }

        return retorno; 
    }

    
    // OUTPUT REFERENTE AO METODO 'Perguntas()'
    public class OutputPerguntas {
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String sessao;
        @AuraEnabled
        public List<Perguntas> perguntas;
    }
    public class Alternativas {
        @AuraEnabled
        public String descricao;
    }
    public class Perguntas {
        @AuraEnabled
        public Integer id;
        @AuraEnabled
        public String descricao;
        @AuraEnabled
        public List<Alternativas> alternativas;
    }


    // OUTPUT REFERENTE AO METODO 'ValidarPerguntas()'
    public class OutputValidarPerguntas {
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Boolean aprovado;
        @AuraEnabled
        public List<Perguntas> perguntas;
    }
}