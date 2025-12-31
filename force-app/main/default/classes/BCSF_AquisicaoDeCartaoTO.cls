public with sharing class BCSF_AquisicaoDeCartaoTO {
    public class responseWrapper{
        public String message;
        public Integer statusCode;
        public Object body;
    }
    public class listResponseWrapper{
        public String message;
        public Integer statusCode;
        public List<Object> body;
    }
    public class iniciarChatBody {
        public String telefone;
    }
    public class iniciarChatResponseWrapper {
        public String idProposta;
        public String etapa;
        public Decimal limite;
        public String nome;
    }
    public class atualizarDadosContatoBody {
        public String email;
        public Boolean optinWhatsapp;
    }
    public class atualizarDadosPessoaisBody {
        public String nome;
        public String genero;
        public String dataNascimento;
        public String nomeMae;
        public Boolean pep;
    }
    public class buscarModelosContratacaoResponseWrapper{
        public String descricao;
        public Integer valor;
        public Boolean possuiEmpresa;
    }
    public class buscarProfissaoResponseWrapper {
        public List<Dados> dados;
        public Integer totalRegistros;
        public Integer totalPaginas;
        public Integer quantidadePorPagina;
        public Integer paginaAtual;
    }
    public class buscarCategoriasResponseWrapper {
        public List<Dados> dados;
        public Integer totalRegistros;
        public Integer totalPaginas;
        public Integer quantidadePorPagina;
        public Integer paginaAtual;
    }
    public class buscarDiasDeVencimentoResponseWrapper {
        public List<Dados> dados;
        public Integer totalRegistros;
        public Integer totalPaginas;
        public Integer quantidadePorPagina;
        public Integer paginaAtual;
    }
    public class Dados{
        public String descricao;
        public Integer valor;
    }
    public class atualizarDadosProfissionaisBody{
        public String cnpjEmpresa;
        public Integer idProfissao;
        public Integer idOcupacao;
    }
    public class buscarEnderecoPorCEPResponseWrapper{
        public String cep;
        public String logradouro;
        public String bairro;
        public String cidade;
        public String estado;
    }
    public class atualizarDadosDeEnderecoBody {
        public Endereco endereco;
    }
    
    public class Endereco {
        public String cep;
        public String logradouro;
        public String bairro;
        public String cidade;
        public String estado;
        public String numero;
        public String complemento;
    }
    public class Proposta {
        public String diaVencimento;
        public Decimal limite;
    }
    public class Produto {
        public String nome;
        public String diasEntrega;
        public Decimal anuidade;
    }
    
    public class iniciarAutenticacaoPorBiometriaResponseWrapper{
        public String urlAutenticacao;
    }
    public class validarAutenticacaoPorBiometriaResponseWrapper{
        public String etapa;
    }
    public class aceiteDaOfertaBody{
        public Boolean aceita;
    }
    public class abandonoDePropostaBody{
        public String motivo;
    }
    public class desistenciaDeCadastroDePropostaBody{
        public String motivo;
    }
    public class efetuarConfiguracaoDoCartaoBody{
        public Boolean optinAumentoLimite;
        public Boolean optinOverlimit;
        public Integer diaVencimento;
    }
    public class efetuarConfiguracaoDoCartaoResponseWrapper{
        public endereco endereco;
        public Proposta proposta;
        public Produto produto;
        public String termo;
    }
}