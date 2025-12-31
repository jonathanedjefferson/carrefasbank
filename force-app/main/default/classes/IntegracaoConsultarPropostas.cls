public with sharing class IntegracaoConsultarPropostas {

    public static OutPutConsultarPropostas ConsultarPropostas(String cpf, String statusProposta, String modalidade, String dataInicio, String dataFim, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarPropostas');

        String bodyAtualizado = config.Body__c;
        bodyAtualizado = bodyAtualizado.replace('{cpf}', cpf);
        bodyAtualizado = bodyAtualizado.replace('{status}', statusProposta);
        bodyAtualizado = bodyAtualizado.replace('{modalidade}', modalidade);
        bodyAtualizado = bodyAtualizado.replace('{dataInicio}', dataInicio);
        bodyAtualizado = bodyAtualizado.replace('{dataFim}', dataFim);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            bodyAtualizado, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar Propostas', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            bodyAtualizado, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            '',
            canal.capitalize()
        );   

        OutPutConsultarPropostas output = new OutPutConsultarPropostas();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutPutConsultarPropostas) JSON.deserialize(objHttpResponse.getBody(), OutPutConsultarPropostas.class);
            output.statusResponse =  'OK';
            return output;
        }else if (status == '204') {
            output.statusResponse =  'OK';
            return output;
        }else if (status == '400') {
            output.statusResponse =  '400';
            output.messageError = (List<String>) JSON.deserialize(objHttpResponse.getBody(), List<String>.class);
            return output;
        }
        
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputHistoricoProposta ConsultarHistoricoProposta(String numeroProposta, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarHistoricoProposta');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroProposta}', numeroProposta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar Histórico de Proposta', 
            config.Endpoint__c + config.Path__c.replace('{numeroProposta}', numeroProposta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            '',
            canal.capitalize()
        );   

        OutputHistoricoProposta output = new OutputHistoricoProposta();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputHistoricoProposta) JSON.deserialize(objHttpResponse.getBody(), OutputHistoricoProposta.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    /* Output Consultar Propostas */
    public class OutPutConsultarPropostas {
        @AuraEnabled
        public List<Proposta> propostas;
        @AuraEnabled
        public String statusResponse;
        @AuraEnabled
        public List<String> messageError;
    }
    
    public class Proposta {
        @AuraEnabled
        public String numeroProposta;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String nomeTitular;
        @AuraEnabled
        public Integer embossing;
        @AuraEnabled
        public String dataCriacao;
        @AuraEnabled
        public String dataAtualizacao;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String modalidade;
        @AuraEnabled
        public String loja;
    }

    /* Output Histórico de proposta */
    public class OutputHistoricoProposta {
        @AuraEnabled
        public String numeroProposta;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String itens;
        @AuraEnabled
        public String statusResponse;
        @AuraEnabled
        public List<HistoricoProposta> historicoProposta;
    }

    public class HistoricoProposta {
        @AuraEnabled
        public String statusProposta;
        @AuraEnabled
        public String dataMovimentacao;
        @AuraEnabled
        public String ddd;
        @AuraEnabled
        public String telefone;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public OcorrenciaHistorioDto ocorrenciaHistorioDto;
        @AuraEnabled
        public EnderecoHistoricoDto enderecoHistoricoDto;
    }
    
    public class OcorrenciaHistorioDto {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public String descricao;
    }
    
    public class EnderecoHistoricoDto {
        @AuraEnabled
        public Integer cep;
        @AuraEnabled
        public String endereco;
        @AuraEnabled
        public String numero;
        @AuraEnabled
        public String complemento;
        @AuraEnabled
        public String bairro;
        @AuraEnabled
        public String cidade;
        @AuraEnabled
        public String uf;
    }
}