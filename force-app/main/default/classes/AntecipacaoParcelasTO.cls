public class AntecipacaoParcelasTO {

    public class RetornoListarParcelamentos{
        @AuraEnabled 
        public List<Parcelamento> parcelamentos;
        @AuraEnabled 
        public String statusAPI;
    }

    public class RetornoObterParcelamento{
        @AuraEnabled 
        public Parcelamento parcelamento;
        @AuraEnabled 
        public String statusAPI;
    }

    public class RotornoSimulacaoAntecipacaoMultipla{
        @AuraEnabled 
        public Integer quantidadeParcelasAntecipadas;
        @AuraEnabled 
        public ValorMonetario valorTotalAntecipado;
        @AuraEnabled 
        public ValorMonetario descontoTotal;
        @AuraEnabled 
        public ValorMonetario valorTotalComDesconto;
        @AuraEnabled 
        public String status;
        @AuraEnabled 
        public List<Simulacao> simulacoes;
        @AuraEnabled 
        public List<ParcelamentoFalha> simulacoesComFalha;
        @AuraEnabled 
        public TipoPagamento tiposPagamentoDisponiveis;
        @AuraEnabled 
        public String message;
        @AuraEnabled
        public Data data;
        @AuraEnabled 
        public String statusAPI;
    }

    public class RetornoAntecipacao{
        @AuraEnabled 
        public String antecipacaoMultiplaId;
        @AuraEnabled 
        public Integer quantidadeParcelasAntecipadas;
        @AuraEnabled 
        public ValorMonetario valorTotalAntecipado;
        @AuraEnabled 
        public ValorMonetario descontoTotal;
        @AuraEnabled 
        public ValorMonetario valorTotalComDesconto;
        @AuraEnabled 
        public String status;
        @AuraEnabled 
        public List<Adesao> adesoes;
        @AuraEnabled 
        public List<ParcelamentoFalha> adesoesComFalha;
        @AuraEnabled 
        public String textoAdesao;
        @AuraEnabled 
        public Boleto boleto;
        @AuraEnabled 
        public Pix pix;
        @AuraEnabled 
        public String message;
        @AuraEnabled
        public Data data;
        @AuraEnabled 
        public String statusAPI;
    }

    public class RetornoPagamentoAvulso{
        @AuraEnabled 
        public Boleto boleto;
        @AuraEnabled 
        public Pix pix;
        @AuraEnabled 
        public String statusAPI;
    }

    public class RetornoEnvioEmail{
        @AuraEnabled 
        public String statusAPI;
    }

    public class SimulacaoParcelamentoBody {
        @AuraEnabled 
        public Integer idParcelamento;
        @AuraEnabled 
        public List<Integer> parcelas;
    }

    public class AntecipacaoParcelamentoBody {
        @AuraEnabled 
        public Integer idParcelamento;
        @AuraEnabled 
        public List<Integer> parcelas;
         @AuraEnabled 
        public Decimal descontoSimulado;
    }

    public class Parcelamento{
        @AuraEnabled 
        public Long idParcelamento;
        @AuraEnabled 
        public Long chaveParticao;
        @AuraEnabled 
        public Long idCartao;
        @AuraEnabled 
        public String codigoAutorizacao;
        @AuraEnabled 
        public String dataTransacaoOriginal;
        @AuraEnabled 
        public Long idTransacaoOriginal;
        @AuraEnabled 
        public ValorMonetario limiteComprometido;
        @AuraEnabled 
        public ValorMonetario valorTotalParcelado;
        @AuraEnabled 
        public Integer numeroTotalParcelas;
        @AuraEnabled 
        public Integer numeroParcelasRestantes;
        @AuraEnabled 
        public String descricao;
        @AuraEnabled 
        public String descricaoMercadoria;
        @AuraEnabled 
        public String descricaoParcelamento;
        @AuraEnabled 
        public ValorMonetario totalJuros;
        @AuraEnabled 
        public ValorMonetario valorTotalParceladoSemJuros;
        @AuraEnabled 
        public List<Parcela> parcelas;
        @AuraEnabled 
        public String tipoParcelamento;
        @AuraEnabled 
        public Decimal taxaJuros;
        @AuraEnabled
        public String categoria;
        @AuraEnabled 
        public Boolean inFaturaAberta;
        @AuraEnabled 
        public Parcela parcelaAtual;  
        @AuraEnabled 
        public Parcela ultimaParcelaPaga;
    }

    public class Parcela{
        @AuraEnabled 
        public String dataVencimento;
        @AuraEnabled 
        public String dataEstimada;
        @AuraEnabled 
        public String dataPagamento;
        @AuraEnabled 
        public Integer numeroParcela;
        @AuraEnabled 
        public ValorMonetario valorParcela;
        @AuraEnabled 
        public Boolean inFaturaAberta;
        @AuraEnabled 
        public Boolean isPostada;
    }
    
    public class Simulacao{
        @AuraEnabled 
        public Long serno; 
        @AuraEnabled 
        public String categoria;
        @AuraEnabled 
        public String descricaoCompra;
        @AuraEnabled 
        public List<Parcela> parcelasAntecipaveis;
        @AuraEnabled
        public Parcela parcelaAtual;
        @AuraEnabled
        public String dataCompra;
        @AuraEnabled
        public ValorMonetario valorCompra;
        @AuraEnabled
        public ValorMonetario desconto;
        @AuraEnabled
        public ValorMonetario valorTotalParcelas;
        @AuraEnabled
        public ValorMonetario valorTotalParcelasAntecipacao;
        @AuraEnabled
        public String periodoAntecipado;
    }

    public class Adesao{
        @AuraEnabled
        public Long serno;
        @AuraEnabled
        public String dataCompra;
        @AuraEnabled
        public String categoria;
        @AuraEnabled
        public String descricao;
        @AuraEnabled
        public List<Integer> parcelas;
        @AuraEnabled
        public Decimal valorAntecipado;
        @AuraEnabled
        public Decimal desconto;
        @AuraEnabled
        public Decimal valorComDesconto;
        @AuraEnabled
        public String periodoAntecipado;
    }

    public class Boleto{
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String linhaDigitavelCarrefour;
        @AuraEnabled
        public Boolean registrado;
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public String pdf;
    }
    
    public class Pix{
        @AuraEnabled
        public String qrCode;
        @AuraEnabled
        public String copiaCola;
        @AuraEnabled
        public String dataVencimento;
    }

    public class ParcelamentoFalha{
        @AuraEnabled
        public Long serno;
        @AuraEnabled
        public String categoria;
        @AuraEnabled
        public String descricaoErro;
        @AuraEnabled
        public String descricaoCompra;
        @AuraEnabled
        public String descricao;
        @AuraEnabled
        public Integer numeroParcelas;
        @AuraEnabled
        public String dataCompra;
        @AuraEnabled
        public ValorMonetario valorCompra;
        @AuraEnabled
        public String periodoAntecipado;
        @AuraEnabled
        public List<Integer> parcelas;
    }

    public class Data{

    }

    public class TipoPagamento{
        @AuraEnabled
        public Boolean boleto;
        @AuraEnabled
        public Boolean pix;
    }

    public class ValorMonetario{
        @AuraEnabled
        public Decimal valor;
        @AuraEnabled
        public String moeda;
    }
}