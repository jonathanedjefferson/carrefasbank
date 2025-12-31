public without sharing class BCSF_cmp_ParceleSimularBO {
    public static ContaFinanceiraTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = BCSF_cmp_ParceleSimularDAO.getInstance().getContaFinanceira(recordId);
        ContaFinanceiraTO contaTratada = new ContaFinanceiraTO();
        contaTratada.NumeroConta = contaFinanceira.NumeroConta__c == null?'--': contaFinanceira.NumeroConta__c;
        contaTratada.CPF = contaFinanceira.NomeCliente__r.CPF__c == null?'--': formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        contaTratada.AccountId = contaFinanceira.NomeCliente__c == null?'--': contaFinanceira.NomeCliente__c;
        contaTratada.Email = contaFinanceira.Email__c == null?'--': contaFinanceira.Email__c;
        return contaTratada;
    }

    public static Case criarCaso(String casoType, String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        String assunto = 'Parcelamento';
        String evento = 'Adesão Parcele Fácil';
        String tipo = 'Execução';

        if(casoType == 'pendente'){
            assunto = 'Parcelamento';
            evento = 'Informação parcele fácil';
            tipo = 'Informação';
        }

        if(casoType == 'contratados'){
            assunto = 'Parcelamento';
            evento = 'Segunda via de contrato';
        }

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = assunto;
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = tipo;
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_cmp_ParceleSimularDAO.getInstance().getCase(cs.id);
    }

    public static String formatarCPF(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public class ContaFinanceiraTO{
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
    }
}