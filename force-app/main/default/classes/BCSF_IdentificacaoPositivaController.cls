public without sharing class BCSF_IdentificacaoPositivaController {
    @AuraEnabled
    public static IdentificacaoPositiva.OutputPerguntas getPerguntas(String sistema, String canal, String cpf, String idEmpresa, String numeroConta){
        IdentificacaoPositiva.OutputPerguntas retorno = IdentificacaoPositiva.Perguntas(sistema, canal, cpf, idEmpresa, numeroConta);
        return retorno;
    }

    @AuraEnabled
    public static IdentificacaoPositiva.OutputValidarPerguntas ValidarPerguntas(String sessao, String mapRepostas, String idEmpresa, String cpf, String canal){
        
        Map<String, String> mapPerguntasRespostas = new Map<String, String>();
        List<Repostas> lisRepostas = (List<Repostas>) System.JSON.deserialize(mapRepostas, List<Repostas>.class);
          
        for (Repostas record : lisRepostas) {
            mapPerguntasRespostas.put(record.key, record.value);
        }

        IdentificacaoPositiva.OutputValidarPerguntas retorno = IdentificacaoPositiva.ValidarPerguntas(sessao, mapPerguntasRespostas, idEmpresa, cpf, canal);
        return retorno;
    }

    @AuraEnabled
    public static void atualizarContaFinanceira(String contaFinanceiraId) {

        ContaFinanceira__c contaFinanceira = IdentificacaoPositivaDAO.getContaFinanceira(contaFinanceiraId);
        contaFinanceira.DataUltimaIdentificacaoPositiva__c = system.now();
        contaFinanceira.IdentificaoPositiva__c = true;
        update contaFinanceira;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Asset> getContasAtivas(String contaFinanceiraId){
        List<Asset> listCartoesRetorno = new List<Asset>();
        List<String> listStringStatusCancelado = new List<String>();
        List<Asset> listCartoes =  IdentificacaoPositivaDAO.getAtivos(contaFinanceiraId);
        List<StatusContaCancelada__mdt> listStatusCancelado =  IdentificacaoPositivaDAO.getStatusCancelado();

        for (StatusContaCancelada__mdt item: listStatusCancelado) {
            listStringStatusCancelado.add(item.Label);
        }

        for (Asset item: listCartoes) {
            if (!listStringStatusCancelado.contains(item.Status)) {
                listCartoesRetorno.add(item);
            }
            if (item.CartaoPrimario__c && !listCartoesRetorno.contains(item)) {
                listCartoesRetorno.add(item);
            }
        }

        return listCartoesRetorno;
    }

    @AuraEnabled(Cacheable=true)
    public static ContaFinanceiraTitular getContaFinanceira(String contaFinanceiraId){

        Datetime DataIdentificacao = Datetime.now();
        String DataIdentificacaoFormatada = '';
        String HoraIdentificacaoFormatada = '';

        ContaFinanceira__c contaFinanceira = IdentificacaoPositivaDAO.getContaFinanceira(contaFinanceiraId);
        ContaFinanceiraTitular contaTratada = new ContaFinanceiraTitular();
        contaTratada.NumeroConta = contaFinanceira.NumeroConta__c == null?'--': contaFinanceira.NumeroConta__c;
        contaTratada.Nome = contaFinanceira.NomeCliente__r.Name == null?'--': contaFinanceira.NomeCliente__r.Name;
        contaTratada.CPF = contaFinanceira.NomeCliente__r.CPF__c == null?'--': formatarCPF(contaFinanceira.NomeCliente__r.CPF__c) ;
        contaTratada.TipoConta = contaFinanceira.TipoConta__c == null?'--': contaFinanceira.TipoConta__c;
        contaTratada.UnidadeNegocio = contaFinanceira.UnidadeNegocio__c == null?'--': contaFinanceira.UnidadeNegocio__c;
        contaTratada.AccountId = contaFinanceira.NomeCliente__c == null?'--': contaFinanceira.NomeCliente__c;
        contaTratada.ClienteBlindado = contaFinanceira.EhBlindado__c;
        contaTratada.ClienteBlindadoFull = contaFinanceira.EhBlindadoFull__c;

        if (contaFinanceira.DataUltimaIdentificacaoPositiva__c != null){
            DataIdentificacao = contaFinanceira.DataUltimaIdentificacaoPositiva__c;
            DataIdentificacaoFormatada = DataIdentificacao.format('dd/MM/yyyy');
            HoraIdentificacaoFormatada = DataIdentificacao.format('HH:mm');
        }
        
        contaTratada.DataIdentificacao = contaFinanceira.DataUltimaIdentificacaoPositiva__c == null?'--': DataIdentificacaoFormatada;
        contaTratada.HoraIdentificacao = contaFinanceira.DataUltimaIdentificacaoPositiva__c == null?'--': HoraIdentificacaoFormatada;
        
        contaTratada.ClienteIdentificado = contaFinanceira.IdentificaoPositiva__c;
        return contaTratada;
    }

    public static String formatarCPF(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna o CPF original se não tiver 11 dígitos
        }
        String retorno = cpf.substring(0, 3) + '.' + cpf.substring(3, 6) + '.' + cpf.substring(6, 9) + '-' + cpf.substring(9, 11);
        return retorno;
    }

    public class ContaFinanceiraTitular{
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String Nome{get; set;}
        @AuraEnabled
        public String NumeroConta{get; set;}
        @AuraEnabled
        public String CPF {get; set;}
        @AuraEnabled
        public String TipoConta {get; set;}
        @AuraEnabled
        public String UnidadeNegocio {get; set;}
        @AuraEnabled
        public String DataIdentificacao {get; set;}
        @AuraEnabled
        public String HoraIdentificacao {get; set;}
        @AuraEnabled
        public Boolean ClienteIdentificado {get; set;}
        @AuraEnabled
        public Boolean ClienteBlindado {get; set;}
        @AuraEnabled
        public Boolean ClienteBlindadoFull {get; set;}
    }

    public class Repostas {
        public String key;
        public String value;
    }

}