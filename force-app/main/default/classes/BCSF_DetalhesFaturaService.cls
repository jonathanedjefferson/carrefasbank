public with sharing class BCSF_DetalhesFaturaService {
    public FaturaDetalhada faturaDetalhada;
    
    public class DetalhesLancamentoParcela {
        public Integer quantidadeParcelas;
        public Integer numeroParcelaTransacao;
        public Integer parcelamentoSerno;
        public Integer parcelaIndice;
        public Integer parcelamentoPartitionKey;
    }

    public class Descontos {
        public String nomeProduto;
        public Integer quantidadeProdutos;
        public ValorFatura valorTotalDesconto;
    }
    
    public class FaturaDetalhada {
        public String tipoFatura;
        public ValorFatura valorFatura;
        public String dataVencimento;
        public ValorFatura totalDescontos;
        public ValorFatura totalDescontosUltimoAno;
        public ValorFatura pagamentoMinimo;
        public ValorFatura pagamentoEfetuado;
        public String linhaDigitavel;
        public String codigoBarras;
        public List<Lancamentos> lancamentos;
    }
    
    public class Lancamentos {
        public String numeroCartao;
        public String idTransacao;
        public String chaveParticaoTransacao;
        public String dataTransacao;
        public String dataProcessamento;
        public String tipoLancamento;
        public String descricao;
        public String descricaoGrupo;
        public String reasonCode;
        public ValorFatura valor;
        public String idCategoria;
        public String nomeCategoria;
        public String identificadorOnUs;
        public Integer quantidadeParcelas;
        public Integer numeroParcela;
        public DetalhesLancamentoParcela detalhesLancamentoParcela;
        public String idTransacaoVinculada;
        public List<Descontos> descontos;
        public String modoTransacao;
        public String codigoAutorizacao;
        public String numeroConta;
        public String dataVencimentoFatura;
        public String modoTransacaoNumerico;
        public String origMsgType;
        public String msgType;
        public String procCode;
    }
    
    public class ValorFatura {
        @AuraEnabled public Decimal valor;
        @AuraEnabled public String moeda;
    }
    
    public static BCSF_DetalhesFaturaService parse(String json) {
        return (BCSF_DetalhesFaturaService) System.JSON.deserialize(json, BCSF_DetalhesFaturaService.class);
    }
}