public with sharing class LancamentoContestadoBO {
    
    public class LancamentoContestado {

        @AuraEnabled 
        public String numeroConta;
        @AuraEnabled 
        public String numeroCartaoOfuscado;
        @AuraEnabled 
        public String idCartaoSerno;
        @AuraEnabled 
        public Boolean cartaoBloqueado;
        @AuraEnabled 
        public String dataTransacao;
        @AuraEnabled 
        public String dataTransacaoISO;
        @AuraEnabled 
        public String codigoTransacao;
        @AuraEnabled 
        public Decimal valor;
        @AuraEnabled 
        public String codigoEntrada;
        @AuraEnabled 
        public String cartaoRoubado;
        @AuraEnabled 
        public String clienteCartao;
    }
}