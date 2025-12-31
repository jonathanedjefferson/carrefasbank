public class BCSF_CLS_CalloutFaturasTO {

    public class DetalhesFatura {
        @AuraEnabled public String numeroCartao;
        @AuraEnabled public Datetime dataTransacao;
        @AuraEnabled public String descricao;
        @AuraEnabled public String descricaoGrupo;
        @AuraEnabled public Decimal valor;
        @AuraEnabled public Boolean faturaIndisponivel;
        @AuraEnabled public String reasonCode;
        @AuraEnabled public String idTransacao;
        @AuraEnabled public String dataProcessamento;
        @AuraEnabled public String tipoLancamento;
        @AuraEnabled public String moeda;
        @AuraEnabled public String numeroConta;
        @AuraEnabled public String chaveParticaoTransacao;
        @AuraEnabled public String dataVencimentoFatura;
        @AuraEnabled public BCSF_DetalhesFaturaService.ValorFatura pagamentoEfetuado;
        @AuraEnabled public List<AgrupamentoLancamento> agrupamentoLancamentos;
    }

    public class FaturaFechada{
        @AuraEnabled public Integer serno;
        @AuraEnabled public Datetime dataVencimento;
        @AuraEnabled public Valor valorAberturaFatura;
        @AuraEnabled public Valor valorFatura;
        @AuraEnabled public Valor creditos;
        @AuraEnabled public Valor pagamentoMinimo;
    }

    public class FaturaDetalhada{
        @AuraEnabled public Datetime data;
        @AuraEnabled public Valor valor;
        @AuraEnabled public String numeroCartao;
        @AuraEnabled public DescricaoLancamento descricaoLancamento;
        @AuraEnabled public AgrupamentoLancamento[] agrupamentoLancamentos;
        @AuraEnabled public String descricao;
        @AuraEnabled public String descricaoGrupo;
        @AuraEnabled public String chaveParticaoTransacao;
        @AuraEnabled public DetalheLancamentoParcela detalheLancamentoParcela; 
    }

     public class AgrupamentoLancamento{
        @AuraEnabled public Datetime data;
        @AuraEnabled public Valor valor;
        @AuraEnabled public String numeroCartao;
        @AuraEnabled public DescricaoLancamento descricaoLancamento;
        @AuraEnabled public AgrupamentoLancamento[] agrupamentoLancamentos;
        @AuraEnabled public String descricao;
        @AuraEnabled public String descricaoGrupo;
        @AuraEnabled public String chaveParticaoTransacao;
        @AuraEnabled public DetalheLancamentoParcela detalheLancamentoParcela;
    }

    public class DescricaoLancamento{
        @AuraEnabled public Integer parcelamentoSerno;
        @AuraEnabled public String idLancamento;
        @AuraEnabled public String origMsgType;
        @AuraEnabled public String reasonCode;
        @AuraEnabled public String msgType;
        @AuraEnabled public String procCode;
        @AuraEnabled public Valor valor;
        @AuraEnabled public String descricao;
        @AuraEnabled public Integer glTrxnTypeSerno;
        @AuraEnabled public String postingDate;
        @AuraEnabled public String tipoPagamento;
    }

    public class DetalheLancamentoParcela{
        @AuraEnabled public Integer quantidadeParcelas;
        @AuraEnabled public Integer numeroParcelaTransacao;
        @AuraEnabled public Integer parcelamentoSerno;
        @AuraEnabled public Integer parcelaIndice;
        @AuraEnabled public Integer parcelamentoPartitionKey;
    }

    public class Valor{
        @AuraEnabled public Double valor;
        @AuraEnabled public String moeda;
    }

    public class DetalhesEstorno {
        @AuraEnabled public String casoId;
        @AuraEnabled public String descricao;
        @AuraEnabled public String origin;
        @AuraEnabled public String canal;
        @AuraEnabled public Date dataRegulatoria;
        @AuraEnabled public String accountid;
        @AuraEnabled public String unidadeNegocio;
        @AuraEnabled public String contafinanceiraid;
        @AuraEnabled public Decimal encargosRotativos;
        @AuraEnabled public Decimal encargosAtraso;
        @AuraEnabled public Decimal tarifaAvaliacao;
        @AuraEnabled public Decimal tarifaAnuidade;
        @AuraEnabled public Decimal encargosPagamento;
        @AuraEnabled public Decimal encargosSaqueVisa;
        @AuraEnabled public Decimal encargosSaqueMaster;
        @AuraEnabled public Decimal tarifaRetirada;
        @AuraEnabled public Decimal tarifaTelesaqueVista;
        @AuraEnabled public Decimal tarifaSaqueVistaMastercard; 
        @AuraEnabled public Decimal tarifaSaqueVistaInternacionalMaster;
        @AuraEnabled public Decimal tarifaSaqueVistaVisa;
        @AuraEnabled public Decimal tarifaSaqueVistaInternacionalVisa;
        @AuraEnabled public Decimal tarifaSaqueVistaTecban;
        @AuraEnabled public Decimal tarifaSaqueParceladoTecban;
        @AuraEnabled public Decimal iofDiarioSaqueParcelado;
        @AuraEnabled public Decimal iofDiarioSaqueVista;
        @AuraEnabled public Decimal iofAdicionalSaqueVista;
        @AuraEnabled public Decimal iofDiarioPagContasVista;
        @AuraEnabled public Decimal iofAdicionalPagContasVistas;
        @AuraEnabled public Decimal jurosOpPagContas;
        @AuraEnabled public Decimal total;
    }

}