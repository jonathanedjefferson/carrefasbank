public class CreditoPessoalTO {

    public class ConsultaContratos{
        @AuraEnabled
        public List<Contrato> itens;
        @AuraEnabled 
        public String statusAPI;
    }

    public class ConsultaProposta{
        @AuraEnabled
        public Proposta proposta;
        @AuraEnabled 
        public String statusAPI; 
    }

    public class EnvioTermo{
        @AuraEnabled 
        public String statusAPI; 
    }

    public class ConsultaBancos{
        @AuraEnabled 
        public List<Banco> bancos; 
        @AuraEnabled 
        public String statusAPI; 
    }

    public class AlteracaoDadosBancarios{
        @AuraEnabled 
        public Boolean resultadoRevisao; 
        @AuraEnabled 
        public String statusAPI; 
    }

    public class Contrato {
        @AuraEnabled 
        public String numeroContrato;
        @AuraEnabled 
        public Integer origem;
        @AuraEnabled 
        public Decimal valorSolicitado;
        @AuraEnabled
        public String dataInclusao;
        @AuraEnabled 
        public Integer status;
        @AuraEnabled 
        public Integer id;
    }

    public class Proposta {
        @AuraEnabled
        public Long id;
        @AuraEnabled
        public Long idAdesao;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String numeroContaTsys;
        @AuraEnabled
        public String numeroCartao;
        @AuraEnabled
        public Integer codBanco;
        @AuraEnabled
        public String numeroConta;
        @AuraEnabled
        public String digitoConta;
        @AuraEnabled
        public Integer agencia;
        @AuraEnabled
        public Integer tipoConta;
        @AuraEnabled
        public Integer status;
        @AuraEnabled
        public Decimal valorPreAprovado;
        @AuraEnabled
        public String numeroAutorizacao;
        @AuraEnabled
        public String nsu;
        @AuraEnabled
        public String numeroContrato;
        @AuraEnabled
        public String idContratoHolmes;
        @AuraEnabled
        public String empresa;
        @AuraEnabled
        public String origem;
        @AuraEnabled
        public String dataInclusao;
        @AuraEnabled
        public String dataAtualizacao;
        @AuraEnabled
        public String usuarioInclusao;
        @AuraEnabled
        public String usuarioAlteracao;
        @AuraEnabled
        public Integer tipoPagamento;
        @AuraEnabled
        public String nomeCliente;
        @AuraEnabled
        public String codPlano;
        @AuraEnabled
        public Decimal iof;
        @AuraEnabled
        public Integer possuiSeguro;
        @AuraEnabled
        public Decimal cet;
        @AuraEnabled
        public Integer qtdParcelas;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public Decimal juros;
        @AuraEnabled
        public Decimal valorSeguro;
        @AuraEnabled
        public Decimal valorFinanciado;
        @AuraEnabled
        public Decimal valorSolicitado;
        @auraEnabled
        public PlanoProposta planoProposta;
    }

    public class PlanoProposta {
        @AuraEnabled
        public String idPlanoProposta;
        @AuraEnabled
        public String idProposta;
        @AuraEnabled
        public Decimal valorSolicitadoPercentual;
        @AuraEnabled
        public Decimal valorSeguroPercentual;
        @AuraEnabled
        public Decimal valorIOFTotal;
        @AuraEnabled
        public Decimal percentualValorIOFTotal;
        @AuraEnabled
        public Decimal valorTotalDespesas;
        @AuraEnabled
        public Decimal percentualDespesas;
        @AuraEnabled
        public Decimal encargosParcelamento;
        @AuraEnabled
        public Decimal percentualJuros;
        @AuraEnabled
        public Decimal cetAnual;
        @AuraEnabled
        public Decimal encargosParcelamentoPercentual;
        @AuraEnabled
        public Decimal valorTotalDespesasPercentual;
        @AuraEnabled
        public Decimal iofDiario;
        @AuraEnabled
        public Decimal iofDiarioPercentual;
        @AuraEnabled
        public Decimal iofAdicional;
        @AuraEnabled
        public Decimal iofAdicionalPercentual;
        @AuraEnabled
        public Decimal valorTotalJuros;
        @AuraEnabled
        public Decimal percentualJurosDespesa;
        @AuraEnabled
        public String dataPrimeiraParcela;
        @AuraEnabled
        public String codPlano;
        @AuraEnabled
        public Decimal iof;
        @AuraEnabled
        public Integer possuiSeguro;
        @AuraEnabled
        public Decimal cet;
        @AuraEnabled
        public String qtdParcelas;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public Decimal juros;
        @AuraEnabled
        public Decimal taxaJuros;
        @AuraEnabled
        public Decimal valorSeguro;
        @AuraEnabled
        public Decimal valorFinanciado;
        @AuraEnabled
        public Decimal valorSolicitado;
    }

    public class Banco {
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public String ispb;
        @AuraEnabled
        public String nome;
    }

    public class DadosBancarios{
        @AuraEnabled 
        public String codBanco { get; set; }
        @AuraEnabled
        public String nomeBanco { get; set; }
        @AuraEnabled
        public String numeroConta { get; set; }
        @AuraEnabled
        public String digitoConta { get; set; }
        @AuraEnabled
        public Integer tipoConta { get; set; }
        @AuraEnabled
        public String agencia { get; set; }
    }

    public class ContratoRejeitado{
        @AuraEnabled
        public Long idContratoGF { get; set; }
        @AuraEnabled
        public String idPlano { get; set; }
        @AuraEnabled
        public String numeroConta { get; set; }
        @AuraEnabled
        public Long numeroContrato { get; set; }
        @AuraEnabled
        public Long numeroAutorizacaoTsys { get; set; }
        @AuraEnabled
        public Decimal valorSolicitado { get; set; }
    }

    public class ConsultaCliente{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String nome;
        @AuraEnabled 
        public String cpf;
        @AuraEnabled 
        public String dataNascimento;
        @AuraEnabled 
        public String numeroConta;
        @AuraEnabled 
        public String statusConta;
        @AuraEnabled 
        public Decimal preAprovado;
        @AuraEnabled 
        public Decimal valorMinimoOferta;
        @AuraEnabled 
        public Boolean cartaoSemRestricao;
        @AuraEnabled 
        public Boolean cpEmAndamento;
    }

    public class IniciarProposta{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String idProposta;
    }

    public class ConsultaElegibilidadeCliente{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean resultado;
    }

    public class EfetuarSimulacao{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public List<PlanoParcelamento> planos;
        @AuraEnabled 
        public String quantidadeParcelasMaxima;
        @AuraEnabled 
        public String quantidadeParcelasMinima;
    }

    public class PlanoParcelamento {
        @AuraEnabled
        public String codPlano;
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Decimal valorSolicitado;
        @AuraEnabled
        public String percentualValorSolicitado;
        @AuraEnabled
        public Decimal valorTotal;
        @AuraEnabled
        public String percentualValorTotal;
        @AuraEnabled
        public Decimal valorParcela;
        @AuraEnabled
        public String valorParcelaFormatado;
        @AuraEnabled
        public Decimal valorSeguro;
        @AuraEnabled
        public String percentualValorSeguro;
        @AuraEnabled
        public Decimal valorIOFTotal;
        @AuraEnabled
        public String percentualValorIOFTotal;
        @AuraEnabled
        public Decimal valorTotalDespesas;
        @AuraEnabled
        public String percentualDespesas;
        @AuraEnabled
        public Decimal encargosParcelamento;
        @AuraEnabled
        public Decimal quantidadeParcelas;
        @AuraEnabled
        public Decimal juros;
        @AuraEnabled
        public String jurosFormatado;
        @AuraEnabled
        public String percentualJuros;
        @AuraEnabled
        public Decimal cetAnual;
        @AuraEnabled
        public String cetAnualFormatado;
        @AuraEnabled
        public String dataPrimeiraParcela;
        @AuraEnabled
        public Decimal encargosParcelamentoPercentual;
        @AuraEnabled
        public Decimal valorTotalDespesasPercentual;
        @AuraEnabled
        public Decimal iofDiario;
        @AuraEnabled
        public String percentualIofDiario;
        @AuraEnabled
        public Decimal iofAdicional;
        @AuraEnabled
        public String percentualIofAdicional;
        @AuraEnabled
        public Decimal valorTotalJuros;
        @AuraEnabled
        public String percentualJurosDespesa;
        @AuraEnabled
        public Decimal valorSeguroMensal;
    }

    public class DadosSimulacao{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String idProposta;
        @AuraEnabled 
        public List<PlanoParcelamento> planosComSeguro;
        @AuraEnabled 
        public List<PlanoParcelamento> planosSemSeguro;
        @AuraEnabled 
        public String quantidadeParcelasMaxima;
        @AuraEnabled 
        public String quantidadeParcelasMinima;
    }

    public class SalvarSimulacao{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Resultado resultado;
    }

    public class Resultado{
        @AuraEnabled 
        public String id;
        @AuraEnabled 
        public String status;
    }

    public class ValidarDadosBancarios{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean valido;
    }

    public class SalvarDadosBancarios{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean valido;
        @AuraEnabled 
        public Resultado resultado;
    }

    public class Contratacao{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean resultado;
    }

    public class Cancelamento{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String mensagem;
        @AuraEnabled 
        public String codigoGA;
        @AuraEnabled 
        public String erro;
        @AuraEnabled 
        public String sistema;
    }

}