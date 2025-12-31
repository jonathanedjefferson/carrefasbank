public class UltimosLancamentos {
    public static List<OutputFaturasAbertas> GetFaturasAbertas(String CPF, String NumeroConta, String Token, String unidadeNegocio, String canal) {
        List<OutputFaturasAbertas> lstRetorno = new List<OutputFaturasAbertas>();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetFaturasAbertas');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + NumeroConta + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'cpf' => CPF,
                'Authorization' => 'Bearer '+Token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        String statusCode = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Ultimos Lançamentos - Faturas Abertas', 
            config.Endpoint__c + NumeroConta + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            CPF, 
            statusCode, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        OutputFaturasAbertas rt = new OutputFaturasAbertas();
                if(statusCode.equals('200') || statusCode.equals('204')){
            lstRetorno = (List<OutputFaturasAbertas>) System.JSON.deserialize(objHttpResponse.getBody(), List<OutputFaturasAbertas>.class);
            lstRetorno[0].StatusAPI = 'OK';
            return lstRetorno;
        }else if (objHttpResponse.getBody().equalsIgnoreCase('Não há lançamentos para esta fatura')) {
            rt.StatusAPI = 'SEM LANCAMENTOS';
        }else{
            rt.StatusAPI = 'ERROR';
        }

        lstRetorno.add(rt);
        return lstRetorno;
    }
    
    public class OutputFaturasAbertas {
        @InvocableVariable
        public String data;
        @InvocableVariable
        public Valor valor;
        @InvocableVariable
        public String numeroCartao;
        @InvocableVariable
        public String descricao;
        @InvocableVariable
        public String descricaoGrupo;
        @InvocableVariable
        public String StatusAPI;
        @InvocableVariable
        public DescricaoLancamento descricaoLancamento;
    }
    
    public class Valor {
        @InvocableVariable
        public Double valor;
        @InvocableVariable
        public String moeda;
    }

    public class DescricaoLancamento {
        @InvocableVariable
        public String descricao;
        @InvocableVariable
        public String tipoPagamento;
    }
}