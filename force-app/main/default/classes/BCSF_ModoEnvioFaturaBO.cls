public without sharing class BCSF_ModoEnvioFaturaBO {

    public static ContaFinanceiraTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = BCSF_ModoEnvioFaturaDAO.getInstance().getContaFinanceira(recordId);
        ContaFinanceiraTO contaTratada = new ContaFinanceiraTO();
        contaTratada.NumeroConta = contaFinanceira.NumeroConta__c == null?'--': contaFinanceira.NumeroConta__c;
        contaTratada.CPF = contaFinanceira.NomeCliente__r.CPF__c == null?'--': formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.email = contaFinanceira.email__c == null?'--': contaFinanceira.email__c ;
        contaTratada.TipoConta = contaFinanceira.TipoConta__c == null?'--': contaFinanceira.TipoConta__c;
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        List<String> listNegocios = new List<String>{'1','2','6'};
        if(!listNegocios.contains(contaTratada.UnidadeNegocio)){
            contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        }
        contaTratada.StatusConta = contaFinanceira.StatusConta__c == null?'--': contaFinanceira.StatusConta__c;
        contaTratada.AccountId = contaFinanceira.NomeCliente__c == null?'--': contaFinanceira.NomeCliente__c;
        contaTratada.Telefone = contaFinanceira.Telefone__c == null?'--': formatarCelular(contaFinanceira.Telefone__c);

        contaTratada.CelularSeguro = contaFinanceira.celularSeguro__c?'Sim': 'Não';
        contaTratada.Numero = contaFinanceira.Numero__c == null?'--': String.valueOf(contaFinanceira.Numero__c);
        contaTratada.Complemento = contaFinanceira.Complemento__c == null?'--': contaFinanceira.Complemento__c;
        contaTratada.Bairro = contaFinanceira.Bairro__c == null?'--': contaFinanceira.Bairro__c;
        contaTratada.CEP = contaFinanceira.Cep__c == null?'--': formatarCEP(contaFinanceira.Cep__c);
        contaTratada.Rua = contaFinanceira.Rua__c == null?'--': contaFinanceira.Rua__c;
        contaTratada.Estado = contaFinanceira.Estado__c == null?'--': contaFinanceira.Estado__c;
        contaTratada.Cidade = contaFinanceira.Cidade__c == null?'--': contaFinanceira.Cidade__c;

        return contaTratada;
    }

    public static String formatarCEP(String cep) {
        String formattedCEP = cep;
        
        if (cep != null && cep.length() == 8) {
            formattedCEP = cep.substring(0, 5) + '-' + cep.substring(5);
        }
        
        return formattedCEP;
    }

    public static String formatarCelular(String phoneNumber) {
        String formattedPhoneNumber = '--';
        
        phoneNumber = phoneNumber.replaceAll('[^0-9]', '');
        
        if (phoneNumber != null && phoneNumber != '') {
            formattedPhoneNumber = '';
            if (phoneNumber.length() > 11) {
                formattedPhoneNumber += '+' + phoneNumber.substring(0, phoneNumber.length() - 11);
                formattedPhoneNumber += '(' + phoneNumber.substring(phoneNumber.length() - 11, phoneNumber.length() - 9) + ')';
                formattedPhoneNumber += phoneNumber.substring(phoneNumber.length() - 9, phoneNumber.length() - 4) + '-' +
                                        phoneNumber.substring(phoneNumber.length() - 4);
            } else if (phoneNumber.length() > 9) {
                formattedPhoneNumber += '(' + phoneNumber.substring(0, phoneNumber.length() - 9) + ') ';
                formattedPhoneNumber += phoneNumber.substring(phoneNumber.length() - 9, phoneNumber.length() - 4) + '-' +
                                        phoneNumber.substring(phoneNumber.length() - 4);
            } else if (phoneNumber.length() == 9) {
                formattedPhoneNumber += phoneNumber.substring(0, 5) + '-' + phoneNumber.substring(5);
            } else {
                formattedPhoneNumber = phoneNumber;
            }
        }
        
        return formattedPhoneNumber;
    }

    public static String formatarCPF(String cpf) {
        String formato = '[^0-9]';
        return cpf.replaceAll(formato, '');
    }

    public static Case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal,String evento, String tipoEnvio ) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Fatura';
        cs.Requisito__c = 'Não recebimento via opção atual';
        cs.Evento__c = evento;
        cs.Origin = origem;
        cs.TipoEnvio__c = tipoEnvio;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_ModoEnvioFaturaDAO.getInstance().getCase(cs.id);
    }

    public static void atualizaEmail(String contaFinanceiraId, String email) {
        ContaFinanceira__c cf = new ContaFinanceira__c();
        cf.id = contaFinanceiraId;
        cf.email__c = email;
        update cf;
    }

    public class ContaFinanceiraTO{
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String Email{get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String UnidadeNegocio{get; set;}
        @AuraEnabled
        public String TipoConta {get; set;}
        @AuraEnabled
        public String StatusConta {get; set;}
        @AuraEnabled
        public String Telefone {get; set;}
        @AuraEnabled
        public String Bairro {get; set;}
        @AuraEnabled
        public String CEP {get; set;}
        @AuraEnabled
        public String Cidade {get; set;}
        @AuraEnabled
        public String Complemento {get; set;}
        @AuraEnabled
        public String Rua {get; set;}
        @AuraEnabled
        public String Estado {get; set;}
        @AuraEnabled
        public String Numero {get; set;}
        @AuraEnabled
        public String CelularSeguro {get; set;}
        
    }
}