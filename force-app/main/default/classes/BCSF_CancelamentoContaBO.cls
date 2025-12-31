public without sharing class BCSF_CancelamentoContaBO {
    public static AvaliacaoAnualTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = BCSF_CancelamentoContaDAO.getInstance().getContaFinanceira(recordId);
        AvaliacaoAnualTO contaTratada = new AvaliacaoAnualTO();
        contaTratada.NumeroConta = contaFinanceira.NumeroConta__c == null?'--': contaFinanceira.NumeroConta__c;
        contaTratada.Nome = contaFinanceira.NomeCliente__r.Name == null?'--': contaFinanceira.NomeCliente__r.Name;
        contaTratada.CPF = contaFinanceira.NomeCliente__r.CPF__c == null?'--': formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.DataNascimento = contaFinanceira.NomeCliente__r.DataNascimento__c == null?'--': formatarData(contaFinanceira.NomeCliente__r.DataNascimento__c); 
        contaTratada.TipoConta = contaFinanceira.TipoConta__c == null?'--': contaFinanceira.TipoConta__c;
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        List<String> listNegocios = new List<String>{'1','2','6'};
        if(!listNegocios.contains(contaTratada.UnidadeNegocio)){
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        }
        contaTratada.StatusConta = contaFinanceira.StatusConta__c == null?'--': contaFinanceira.StatusConta__c;
        contaTratada.AccountId = contaFinanceira.NomeCliente__c == null?'--': contaFinanceira.NomeCliente__c;
        return contaTratada;
    }
    public static String formatarData(Date data){
        String dia = data.day()<10?'0'+data.day():String.valueOf(data.day());
        String mes = data.month()<10?'0'+data.month():String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        String dataFormatada = dia+'/'+mes+'/'+ano;
        return dataFormatada;
    }


    public static String formatarCPF(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public static Case criarCaso(String statusCancelamento, String requisito, String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal, String evento, String assunto) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.Requisito__c = requisito;
        cs.StatusCancelamento__c = statusCancelamento;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return [SELECT CaseNumber FROM Case WHERE Id = :cs.Id];
    }

    public static void atualizarContaFinanceira(String recordId, String novoStatus) {
        ContaFinanceira__c contaFinanceira = BCSF_CancelamentoContaDAO.getInstance().getContaFinanceira(recordId);
        contaFinanceira.StatusConta__c = novoStatus;
        update contaFinanceira;
    }
    
    public class AvaliacaoAnualTO{
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String Nome{get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String DataNascimento {get; set;}
        @AuraEnabled
        public String StatusConta {get; set;}
        @AuraEnabled
        public String TipoConta {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
        
    }
}