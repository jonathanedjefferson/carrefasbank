public class IntegracaoParceleFacilTO {
    /* Response token serviços */
    public class OutputTokenServico {
        public String access_token;
        public Integer expires_in;
        public Integer refresh_expires_in;
        public String refresh_token;
        public String token_type;
        public Integer not_before_policy;
        public String session_state;
        public String scope;
        public String statusAPI;
    }

    /*Output erro */
    public class OutputError{
        @AuraEnabled
        public Integer categoriaErro;
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public Integer codigoErro;
    }

    /*classes usadas em mais de um response */
    public class OutputDefault{
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    }

    public class Valor {
        @AuraEnabled
        public Decimal valor;
        @AuraEnabled
        public String moeda;
    }

    public class Boleto {
        @AuraEnabled
        public String linhaDigitavel;
        @AuraEnabled
        public String linhaDigitavelCarrefour;
        @AuraEnabled
        public Boolean registrado;
        @AuraEnabled
        public String pdf;
    }

    public class Pix {
        @AuraEnabled
        public String qrCode;
        @AuraEnabled
        public String copiaCola;
    }


    /* Response modalidades */
    public class OutputModalidades {
        @AuraEnabled
        public Integer perfilOferta;
        @AuraEnabled
        public Boolean permissaoFaturaFechada;
        @AuraEnabled
        public Boolean permissaoSaldoParcial;
        @AuraEnabled
        public Boolean permissaoSaldoTotal;
        @AuraEnabled
        public Valor valorSaldoTotal;
        @AuraEnabled
        public Valor valorMinimoDivida;
        @AuraEnabled
        public Fatura faturaFechada;
        @AuraEnabled
        public Fatura faturaAberta;
        @AuraEnabled
        public List<Transacao> transacoes;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    }

    public class Transacao {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public Long chaveParticao;
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public Valor valorTotal;
        @AuraEnabled
        public Integer numeroParcela;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public Integer parcelamentoSerno;
        @AuraEnabled
        public Integer numeroParcelasRestantes;
        @AuraEnabled
        public Integer parcelaIndice;
        @AuraEnabled
        public Integer tipo;
        @AuraEnabled
        public String descricaoAndamentoParcela;
    }

    public class Fatura {
        @AuraEnabled
        public Valor valorTotal;
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public String dataVencimentoReal;
        @AuraEnabled
        public List<Transacao> transacoes;
    }


    /*Response simular parcelamento */ 
    public class OutputSimulacao {
        @AuraEnabled
        public Simulacao simulacao;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    }

    public class Simulacao {
        @AuraEnabled
        public Valor valorEntrada;
        @AuraEnabled
        public Valor valorMinimoEntrada;
        @AuraEnabled
        public Valor valorMaximoEntrada;
        @AuraEnabled
        public String dataPagamento;
        @AuraEnabled
        public String dataMaximaPagamento;
        @AuraEnabled
        public String termo;
        @AuraEnabled
        public List<FormaPagamento> formasPagamento;
        @AuraEnabled
        public Boolean possuiEntrada;
        @AuraEnabled
        public Boolean possuiPlanosComSeguro;
        @AuraEnabled
        public Boolean possuiPlanosPulaCiclo;
        @AuraEnabled
        public Boolean possuiSomentePlanosPulaCiclo;
        @AuraEnabled
        public Valor jurosEncargos;
    }

    public class FormaPagamento {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public Valor valorDivida;
        @AuraEnabled
        public Decimal porcentagemDivida;
        @AuraEnabled
        public Valor iof;
        @AuraEnabled
        public Decimal iofPorcentagem;
        @AuraEnabled
        public Valor iofDiario;
        @AuraEnabled
        public Decimal iofDiarioPorcentagem;
        @AuraEnabled
        public Boolean seguroAtivo;
        @AuraEnabled
        public Boolean pulaCicloAtivo;
        @AuraEnabled
        public Valor valorSeguroPorParcela;
        @AuraEnabled
        public Valor valorSeguro;
        @AuraEnabled
        public Decimal porcentagemSeguro;
        @AuraEnabled
        public Decimal taxaJuros;
        @AuraEnabled
        public Decimal cet;
        @AuraEnabled
        public Valor valorTotalParcelamento;
        @AuraEnabled
        public Decimal porcentagemTotalParcelamento;
        @AuraEnabled
        public Valor valorEncargos;
        @AuraEnabled
        public Decimal porcentagemEncargos;
        @AuraEnabled
        public Valor valorTotalDespesas;
        @AuraEnabled
        public Decimal porcentagemTotalDespesas;
        @AuraEnabled
        public Valor valorParcela;
        @AuraEnabled
        public Valor valorEntrada;
        @AuraEnabled
        public Valor valorTotalJuros;
        @AuraEnabled
        public Decimal porcentagemTotalJuros;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public String dataPrimeiroPagamento;
        @AuraEnabled
        public String dataVencimentoProxFatura;
        @AuraEnabled
        public Valor valorTotalParcelamentoCalculado;
        @AuraEnabled
        public Boolean limiteBloqueado;
        @AuraEnabled
        public Integer numeroParcelasParaLiberacaoLimite;
        @AuraEnabled
        public AlertaLimiteCartao alertaLimiteCartao;
        @AuraEnabled
        public Valor jurosEncargos;
    }

    public class AlertaLimiteCartao {
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Integer tipo;
    }


    /* Response contratar parcelamento */
    public class OutputContratar {
        @AuraEnabled
        public Datetime dataPrimeiraParcela;
        @AuraEnabled
        public Valor valorPrimeiraParcela;
        @AuraEnabled
        public FormaPagamentoContrato formaPagamento;
        @AuraEnabled
        public Datetime dataPagamentoEntrada;
        @AuraEnabled
        public String parceleFacilId;
        @AuraEnabled
        public Boleto boleto;
        @AuraEnabled
        public Pix pix;
        @AuraEnabled
        public Valor jurosEncargos;
        @AuraEnabled
        public Boolean ehUltimoDiaPagamento;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    }

    public class FormaPagamentoContrato {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public Valor valorDivida;
        @AuraEnabled
        public Decimal porcentagemDivida;
        @AuraEnabled
        public Valor iof;
        @AuraEnabled
        public Decimal iofPorcentagem;
        @AuraEnabled
        public Valor iofDiario;
        @AuraEnabled
        public Decimal iofDiarioPorcentagem;
        @AuraEnabled
        public Boolean seguroAtivo;
        @AuraEnabled
        public Boolean pulaCicloAtivo;
        @AuraEnabled
        public Valor valorSeguroPorParcela;
        @AuraEnabled
        public Valor valorSeguro;
        @AuraEnabled
        public Decimal porcentagemSeguro;
        @AuraEnabled
        public Decimal taxaJuros;
        @AuraEnabled
        public Decimal cet;
        @AuraEnabled
        public Valor valorTotalParcelamento;
        @AuraEnabled
        public Decimal porcentagemTotalParcelamento;
        @AuraEnabled
        public Valor valorEncargos;
        @AuraEnabled
        public Decimal porcentagemEncargos;
        @AuraEnabled
        public Valor valorTotalDespesas;
        @AuraEnabled
        public Decimal porcentagemTotalDespesas;
        @AuraEnabled
        public Valor valorParcela;
        @AuraEnabled
        public Valor valorEntrada;
        @AuraEnabled
        public Valor valorTotalJuros;
        @AuraEnabled
        public Decimal porcentagemTotalJuros;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public String dataPrimeiroPagamento;
        @AuraEnabled
        public String dataVencimentoProxFatura;
        @AuraEnabled
        public Valor valorTotalParcelamentoCalculado;
        @AuraEnabled
        public String descricaoPlanoParcelamento;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Valor jurosEncargos;
        @AuraEnabled
        public String dataPromessaPagamento;
        @AuraEnabled
        public Boolean ehUltimoDiaPagamento;
        @AuraEnabled
        public String parceleFacilId;
        @AuraEnabled
        public String dataCriacao;
        @AuraEnabled
        public String textoLimiteCartao;
    }


    /* Listar perfis */
    public class OutputListarPerfis{
        @AuraEnabled
        public List<String> perfisParcelamento;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    }

    
    /* Response pagamentoentrada */
    public class InputPagamentoEntrada {
        @AuraEnabled
        public Decimal valorEntrada;
        @AuraEnabled
        public String dataEntrada;
        @AuraEnabled
        public String codigoPlanoPagamento;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public Decimal taxaJuros;
        @AuraEnabled
        public Integer tipoPagamento;
    }

    public class OutputPagamentoEntrada{
        @AuraEnabled
        public Boleto boleto;
        @AuraEnabled
        public Pix pix;
        @AuraEnabled
        public String statusAPI;
    }

    /* Get perfil response */
    public class OutputGetPerfil {
        @AuraEnabled
        public GetPerfil perfil;
        @AuraEnabled
        public Boolean ehFuncionario;
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public Integer codigoErro;
    
    }
    public class GetPerfil {
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String codigoPerfil;
        @AuraEnabled
        public String statusContaCliente;
        @AuraEnabled
        public List<String> listaDeStatusNegativo;
        @AuraEnabled
        public Integer numeroMaximoDeOfertas;
        @AuraEnabled
        public Integer perfilOferta;
        @AuraEnabled
        public Integer perfilOfertaAcesso;
        @AuraEnabled
        public Boolean parcelamentoPersonalizado;
        @AuraEnabled
        public Integer opcaoPagamento;
        @AuraEnabled
        public String percentualMinimoPromessaPagamento;
        @AuraEnabled
        public String percentualMaximoPromessaPagamento;
        @AuraEnabled
        public Integer percentualParaLiberacaoLimite;
        @AuraEnabled
        public Integer quantidadeFixaParaLiberacaoLimite;
        @AuraEnabled
        public Boolean bloqueioLimite;
    }

    /* listar parcele pendentes */
    public class OutputListarParcelePendente {
        @AuraEnabled
        public List<FormaPagamentoContrato> formasPagamento;
        @AuraEnabled
        public String statusAPI;
    }

    /* listar parcele contratados*/
    public class OutputListarContratados {
        @AuraEnabled
        public List<ParceleContratados> parceles;
        @AuraEnabled
        public Integer parcelesComBloqueio;
        @AuraEnabled
        public String statusAPI;
    }
    public class ParceleContratados {
        @AuraEnabled
        public Integer situacaoCliente;
        @AuraEnabled
        public Integer numeroTotalParcelas;
        @AuraEnabled
        public Integer numeroParcelasRestantes;
        @AuraEnabled
        public Integer numeroParcelasPagas;
        @AuraEnabled
        public Integer numeroParcelasParaLiberacaoLimite;
        @AuraEnabled
        public Integer statusLiberacaoLimite;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public Decimal taxaJuros;
        @AuraEnabled
        public Boolean possuiOutrosParcelesAtivos;
        @AuraEnabled
        public Datetime dataCriacao;
        @AuraEnabled
        public AlertaContratados alerta;
        @AuraEnabled
        public String parceleFacilId;
    }

    public class AlertaContratados {
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Integer tipo;
    }
    
}