public without sharing class BCSF_ReimpressaoSenhaBO {

    public static ContaFinanceiraTO tratarContaFinanceira(String recordId){
        ContaFinanceira__c contaFinanceira = BCSF_ReimpressaoSenhaDAO.getInstance().getContaFinanceira(recordId);
        ContaFinanceiraTO contaTratada = new ContaFinanceiraTO();
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
        contaTratada.NomeConta = contaFinanceira.Name == null?'--': contaFinanceira.Name;
        contaTratada.Telefone = contaFinanceira.Telefone__c == null?'--': formatarCelular(contaFinanceira.Telefone__c);

        contaTratada.CelularSeguro = contaFinanceira.celularSeguro__c?'Possui Celular Seguro': 'Não possui Celular Seguro';
        //contaTratada.Numero = contaFinanceira.Numero__c == null?'--': String.valueOf(contaFinanceira.Numero__c);
        contaTratada.Complemento = contaFinanceira.Complemento__c == null?'--': contaFinanceira.Complemento__c;
        contaTratada.Bairro = contaFinanceira.Bairro__c == null?'--': contaFinanceira.Bairro__c;
        contaTratada.CEP = contaFinanceira.Cep__c == null?'--': formatarCEP(contaFinanceira.Cep__c);
        contaTratada.Rua = contaFinanceira.Rua__c == null?'--': contaFinanceira.Rua__c;
        contaTratada.Estado = contaFinanceira.Estado__c == null?'--': contaFinanceira.Estado__c;
        contaTratada.Cidade = contaFinanceira.Cidade__c == null?'--': contaFinanceira.Cidade__c;
        contaTratada.Email = contaFinanceira.Email__c == null?'--': contaFinanceira.Email__c;
        contaTratada.TipoEnvio = contaFinanceira.ModoRecebimentoFatura__c == null?'--': contaFinanceira.ModoRecebimentoFatura__c;
        
        return contaTratada;
    }

    public static String formatarData(Date data){
        String dia = data.day()<10?'0'+data.day():String.valueOf(data.day());
        String mes = data.month()<10?'0'+data.month():String.valueOf(data.month());
        String ano = String.valueOf(data.year());
        String dataFormatada = dia+'/'+mes+'/'+ano;
        return dataFormatada;
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
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public static Case criarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String Origem, String Canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Senha';
        cs.Evento__c = 'Segunda Via de Senha';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_ReimpressaoSenhaDAO.getInstance().getCase(cs.id);
    }

    public class ContaFinanceiraTO{
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
        public String CelularSeguro {get; set;}
        @AuraEnabled
        public String CEP {get; set;}
        @AuraEnabled
        public String Rua {get; set;}
        @AuraEnabled
        public String Numero {get; set;}
        @AuraEnabled
        public String Complemento {get; set;}
        @AuraEnabled
        public String Bairro {get; set;}
        @AuraEnabled
        public String Cidade {get; set;}
        @AuraEnabled
        public String Estado {get; set;}
        @AuraEnabled
        public String Telefone {get; set;}
        @AuraEnabled
        public String TipoEnvio {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
        @AuraEnabled
        public String NomeConta {get; set;}
    }
}