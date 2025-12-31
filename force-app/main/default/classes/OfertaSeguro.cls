public with sharing class OfertaSeguro {
    public static ElegibilidadeTO getElegibilidade(String numeroConta, Integer idEmpresa, List<string> produtos, String tokenLogado, String canal){
        ElegibilidadeTO objGetElegibilidadeTO;
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetElegibilidade');

        RequestTO body = new RequestTO();
        body.numeroConta = numeroConta;
        body.idEmpresa = idEmpresa;
        if(produtos != null){
            body.produtos = produtos;
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
        config.Endpoint__c + config.Path__c, 
        config.Method__c,
        new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ tokenLogado,
            'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
        },
        JSON.serialize(body),
        Integer.valueof(config.Timeout__c)
        );

        //REGISTRANDO LOG DE INTEGRAÇÃO
         LogIntegracaoBO.InsertLog(
            'Elegibilidade', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            JSON.serialize(body), 
            null,
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            string.valueOf(idEmpresa),
            canal.capitalize()
        );   

        if(objHttpResponse.getStatusCode() == 200){
            objGetElegibilidadeTO = (ElegibilidadeTO)JSON.deserialize(objHttpResponse.getBody(), ElegibilidadeTO.class);
        }
        return objGetElegibilidadeTO;
    }

    public static ElegibilidadeTO getElegibilidade(String numeroConta, Integer idEmpresa, List<string> produtos, String tokenLogado, String canal, String cpf){
        ElegibilidadeTO objGetElegibilidadeTO;
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ElegibilidadeWPP');

        RequestTO body = new RequestTO();
        body.numeroConta = numeroConta;
        body.idEmpresa = idEmpresa;
        body.canal = canal;
        if(produtos != null){
            body.produtos = produtos;
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
        config.Endpoint__c + config.Path__c, 
        config.Method__c,
        new Map<String, String> {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
            'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
        },
        JSON.serialize(body),
        Integer.valueof(config.Timeout__c)
        );

        //REGISTRANDO LOG DE INTEGRAÇÃO
         LogIntegracaoBO.InsertLog(
            'Elegibilidade WhatsApp', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            String.valueOf(body),
            cpf,
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            string.valueOf(idEmpresa),
            canal.capitalize()
        );   

        if(objHttpResponse.getStatusCode() == 200){
            objGetElegibilidadeTO = (ElegibilidadeTO)JSON.deserialize(objHttpResponse.getBody(), ElegibilidadeTO.class);
        }
        return objGetElegibilidadeTO;
    }

    public class ElegibilidadeTO {
        public Integer status {get;set;}
		public string nome {get;set;}
        public list <ProdutoTO> produtos {get;set;}
        public ElegibilidadeTO(){
            this.produtos = new list<ProdutoTO>();
        } 
    }


    public class ProdutoTO {
        public string codigoProduto {get;set;}
        public string nomeProduto {get;set;}
        public Integer anosVigencia {get;set;}
        public string descricao {get;set;}
        public string seguradora {get;set;}
        public list <coberturasPlanoTO> coberturasPlano {get;set;} 

        public ProdutoTO(){
            this.coberturasPlano = new list<coberturasPlanoTO>();
        }

    }

    public class coberturasPlanoTO {
        public string idPlano {get;set;}
        public string nomePlano {get;set;}
        public string valorParcela {get;set;}
        public list <coberturaTO> cobertura {get;set;} 

        public coberturasPlanoTO(){
            this.cobertura = new list<coberturaTO>();
        }

    }

    public class coberturaTO {
        public string titulo {get;set;}
        public string descricao {get;set;}
        public string observacao {get;set;}
    }

    public class RequestTO{
        public String numeroConta {get; set;}
        public Integer idEmpresa {get; set;}
        public String canal {get; set;}
        public List<String> produtos {get; set;}

        public RequestTO(){
            this.produtos = new List<String>();
        }
    }
}