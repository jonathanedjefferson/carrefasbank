public with sharing class AdesaoSegurosWhatsApp {
    
    @invocableMethod(label='Adesão de Seguros WhatsApp')
    public static List<Retorno> AdesaoSeguro(List<InputAdesaoSeguros> inputs){
        List<Retorno> retornoLista = new List<Retorno>();
        Retorno retorno = new Retorno();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AdesaoSegurosWPP');
        ContaFinanceira__c contaFinceira  = ContaFinanceiraDAO.getDadosContaFinanceiraNumero(inputs[0].numeroConta);
        
        if(contaFinceira != null){
            String body = carregarAdesaoBody(inputs[0], contaFinceira, config);
            IntegracaoSeguros.OutputAdesaoSeguro outputRequisicao = bcsf_cmp_SegurosController.adesaoSegurosWhatsApp(contaFinceira.UnidadeNegocio__c, inputs[0].canal, inputs[0].cpf, body);
            retorno.mensagem = outputRequisicao.mensagem;
            retorno.idAdesao = outputRequisicao.idAdesao;
            retorno.statusAPI = outputRequisicao.statusAPI;
        }  else{
            retorno.mensagem = 'Conta finaceira não retornada!';
        }

        retornoLista.add(retorno);

        return retornoLista; 
    }

    public static String carregarAdesaoBody(InputAdesaoSeguros input, ContaFinanceira__c contaFinceira, CarrefourAPICallout__mdt config){

        String dataNascimentoFormatada = contaFinceira.NomeCliente__r.DataNascimento__c != null ? Util.formatarData(contaFinceira.NomeCliente__r.DataNascimento__c) : '';
        String ddd = contaFinceira.Telefone__c != null ? Util.obterDDDTelefone(contaFinceira.Telefone__c) : '';
        String telefone = contaFinceira.Telefone__c != null ? Util.obterNumeroTelefone(contaFinceira.Telefone__c) : '';

        DadosMeioPagamento dadosMeioPagamento = new DadosMeioPagamento(
            9,
            'Cartao'
        );

        DadosVenda dadosVenda = new DadosVenda(
            'Nao',
            input.codCanalVenda, 
            input.codLoja,
            '',
            input.email,
            input.nomeLoja,
            '',
            2,
            1
        );

        DadosCliente dadosCliente = new DadosCliente(
            input.cpf,
            '',
            ddd,
            ddd,
            ddd,
            dataNascimentoFormatada,
            dataNascimentoFormatada,
            '',
            contaFinceira.Email__c != null ? contaFinceira.Email__c : '',
            0,
            '',
            'Brasileiro',
            contaFinceira.NomeCliente__r.Name != null ? contaFinceira.NomeCliente__r.Name : '',
            contaFinceira.NomeCliente__r.NomeMae__c != null ? contaFinceira.NomeCliente__r.NomeMae__c : '',
            contaFinceira.NomeCliente__r.Sexo__c != null ? contaFinceira.NomeCliente__r.Sexo__c : '',
            telefone,
            telefone,
            telefone
        );

        DadosCartao dadosCartao = new DadosCartao(
            '',
            '',
            1,
            1,
            contaFinceira.NomeCliente__r.Name != null ? contaFinceira.NomeCliente__r.Name : '',
            '',
            contaFinceira.NumeroConta__c != null ? contaFinceira.NumeroConta__c : ''
        );

        EnderecoCliente enderecoCliente = new EnderecoCliente(
            contaFinceira.Bairro__c != null ? contaFinceira.Bairro__c : '',
            contaFinceira.CEP__c != null ? contaFinceira.CEP__c : '',
            contaFinceira.Cidade__c != null ? contaFinceira.Cidade__c : '',
            contaFinceira.Complemento__c != null ? contaFinceira.Complemento__c : '',
            contaFinceira.Rua__c != null ? contaFinceira.Rua__c : '',
            contaFinceira.Numero__c != null ? String.valueOf(contaFinceira.Numero__c) : '',
            contaFinceira.Estado__c != null ? contaFinceira.Estado__c : '',
            0,
            'N'
        );

        EnderecoCobranca enderecoCobranca = new EnderecoCobranca(
            contaFinceira.Bairro__c != null ? contaFinceira.Bairro__c : '',
            contaFinceira.CEP__c != null ? contaFinceira.CEP__c : '',
            contaFinceira.Cidade__c != null ? contaFinceira.Cidade__c : '',
            contaFinceira.Complemento__c != null ? contaFinceira.Complemento__c : '',
            contaFinceira.Rua__c != null ? contaFinceira.Rua__c : '',
            contaFinceira.Numero__c != null ? String.valueOf(contaFinceira.Numero__c) : '',
            contaFinceira.Estado__c != null ? contaFinceira.Estado__c : '',
            1,
            'N'
        );

        DadosPlano dadosPlano = new DadosPlano(
            Integer.valueOf(input.idPlano),
            'N',
            input.nomePlano
        );

        DadosProduto dadosProduto = new DadosProduto(
            0,
            Integer.valueOf(input.idProduto),
            input.nomeProduto,
            true,
            1
        );

        TraceAdesao traceAdesao = new TraceAdesao(
            1,
            'Brasil',
            input.cpf,
            contaFinceira.Email__c != null ? contaFinceira.Email__c : '', 
            '',
            config != null ? config.Database__c : '',
            '',
            '',
            2,
            6,
            '',
            '',
            input.codLoja,
            Integer.valueOf(input.idPlano),
            new List<Eventos>()
        );

        Adesao adesao = new Adesao(
            0,
            System.now().addSeconds(Timezone.getTimeZone('America/Sao_Paulo').getOffset(System.now())/1000),
            new List<Respostas>(),
            dadosMeioPagamento,
            dadosVenda,
            dadosCliente,
            dadosCartao,
            enderecoCliente,
            enderecoCobranca,
            dadosPlano,
            dadosProduto,
            traceAdesao
        );

        AdesaoWrapper adesaoBody = new AdesaoWrapper(adesao);

        return JSON.serialize(adesaoBody);
    }

    public class InputAdesaoSeguros{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String cpf;
        //dados venda
        @InvocableVariable(required = true)
        public String codCanalVenda;
        @InvocableVariable(required = true)
        public String codLoja;
        @InvocableVariable(required = true)
        public String email;
        @InvocableVariable(required = true)
        public String nomeLoja;
        //dados produto
        @InvocableVariable(required = true)
        public String idProduto;
        @InvocableVariable(required = true)
        public String nomeProduto;
         //dados plano
        @InvocableVariable(required = true)
        public String nomePlano;
        @InvocableVariable(required = true)
        public String idPlano;
        @InvocableVariable(required = true)
        public String canal;

    }

    public class Retorno{
        @InvocableVariable
        public String mensagem;
        @InvocableVariable
        public Decimal idAdesao;
        @InvocableVariable
        public String statusAPI;
    }

   public class AdesaoWrapper{
        public Adesao adesao;

        public AdesaoWrapper(Adesao adesao){
            this.adesao = adesao;
        }
   }

    public class Adesao{
        public Integer idAdesao;
        public Datetime data;
        public List<Respostas> respostas;
        public DadosMeioPagamento dadosMeioPagamento;
        public DadosVenda dadosVenda;
        public DadosCliente dadosCliente;
        public DadosCartao dadosCartao;
        public EnderecoCliente enderecoCliente;
        public EnderecoCobranca enderecoCobranca;
        public DadosPlano dadosPlano;
        public DadosProduto dadosProduto;
        public TraceAdesao traceAdesao;

        public Adesao(Integer idAdesao, Datetime data, List<Respostas> respostas, DadosMeioPagamento dadosMeioPagamento, DadosVenda dadosVenda, DadosCliente dadosCliente, DadosCartao dadosCartao, EnderecoCliente enderecoCliente, EnderecoCobranca enderecoCobranca, DadosPlano dadosPlano, DadosProduto dadosProduto, TraceAdesao traceAdesao){
            this.idAdesao = idAdesao;
            this.data = data;
            this.respostas = respostas;
            this.dadosMeioPagamento = dadosMeioPagamento;
            this.dadosVenda = dadosVenda;
            this.dadosCliente = dadosCliente;
            this.dadosCartao = dadosCartao;
            this.enderecoCliente = enderecoCliente;
            this.enderecoCobranca = enderecoCobranca;
            this.dadosPlano = dadosPlano;
            this.dadosProduto = dadosProduto;
            this.traceAdesao = traceAdesao;
        }
    }

    public class Respostas{
    }

    public class DadosMeioPagamento{
        public Integer idMeioPagamento;
        public String tipo;

        public DadosMeioPagamento(Integer idMeioPagamento, String tipo){
            this.idMeioPagamento = idMeioPagamento;
            this.tipo = tipo;
        }
    }

    public class DadosVenda{
        public String assinaturaDigital;
        public String codCanalVenda;
        public String codLoja;
        public String codVendedor;
        public String email;
        public String nomeLoja;
        public String nomeVendedor;
        public Integer tipoEnvio;
        public Integer tipoVenda;

        public DadosVenda(String assinaturaDigital, String codCanalVenda, String codLoja, String codVendedor, String email, String nomeLoja, String nomeVendedor, Integer tipoEnvio, Integer tipoVenda){  
            this.assinaturaDigital = assinaturaDigital;
            this.codCanalVenda = codCanalVenda;
            this.codLoja = codLoja;
            this.codVendedor = codVendedor; 
            this.email = email;
            this.nomeLoja = nomeLoja;
            this.nomeVendedor = nomeVendedor;
            this.tipoEnvio = tipoEnvio;
            this.tipoVenda = tipoVenda;
        }
    }

    public class DadosCliente{
        public String cpf;
        public String codProfissaoPR;
        public String dddCelular;
        public String dddComercial;
        public String dddResidencial;
        public String dataExpedicaoRG;
        public String dataNascimento;
        public String descProfissao;
        public String email;
        public Integer estadoCivil;
        public String estadoCivilDesc;
        public String naturalidade;
        public String nome;
        public String nomeMae;
        public String sexo; 
        public String telefoneCelular;
        public String telefoneComercial;
        public String telefoneResidencial;

        public DadosCliente(String cpf, String codProfissaoPR, String dddCelular, String dddComercial, String dddResidencial, String dataExpedicaoRG, String dataNascimento, String descProfissao, String email, Integer estadoCivil, String estadoCivilDesc, String naturalidade, String nome, String nomeMae, String sexo, String telefoneCelular, String telefoneComercial, String telefoneResidencial){
            this.cpf = cpf;
            this.codProfissaoPR = codProfissaoPR;
            this.dddCelular = dddCelular;
            this.dddComercial = dddComercial;
            this.dddResidencial = dddResidencial;
            this.dataExpedicaoRG = dataExpedicaoRG;
            this.dataNascimento = dataNascimento;
            this.descProfissao = descProfissao;
            this.email = email;
            this.estadoCivil = estadoCivil;
            this.estadoCivilDesc = estadoCivilDesc;
            this.naturalidade = naturalidade;
            this.nome = nome;
            this.nomeMae = nomeMae;
            this.sexo = sexo;
            this.telefoneCelular = telefoneCelular;
            this.telefoneComercial = telefoneComercial;
            this.telefoneResidencial = telefoneResidencial;
        }
    }

    public class DadosCartao{
        public String bandeira;
        public String dataValidade;
        public Integer diaFechamentoFatura;
        public Integer diaVencimentoFatura;
        public String nomeCartao;
        public String numeroCartao;
        public String numeroConta;
        
        public DadosCartao(String bandeira, String dataValidade, Integer diaFechamentoFatura, Integer diaVencimentoFatura, String nomeCartao, String numeroCartao, String numeroConta){
            this.bandeira = bandeira;
            this.dataValidade = dataValidade;
            this.diaFechamentoFatura = diaFechamentoFatura;
            this.diaVencimentoFatura = diaVencimentoFatura;
            this.nomeCartao = nomeCartao;
            this.numeroCartao = numeroCartao;
            this.numeroConta = numeroConta;
        }
    }

    public class EnderecoCliente{
        public String bairro;
        public String cep;
        public String cidade;
        public String complemento;
        public String endereco;
        public String numero;
        public String siglaEstado;
        public Integer tipoEndereco;
        public String flagRisco;

        public EnderecoCliente(String bairro, String cep, String cidade, String complemento, String endereco, String numero, String siglaEstado, Integer tipoEndereco,  String flagRisco){
            this.bairro = bairro;
            this.cep = cep;
            this.cidade = cidade;
            this.complemento = complemento;
            this.endereco = endereco;
            this.numero = numero;
            this.siglaEstado = siglaEstado;
            this.tipoEndereco = tipoEndereco;
            this.flagRisco = flagRisco;
        }
    }

    public class EnderecoCobranca{
        public String bairro;
        public String cep;
        public String cidade;
        public String complemento;
        public String endereco;
        public String numero;
        public String siglaEstado;
        public Integer tipoEndereco;
        public String flagRisco;

        public EnderecoCobranca(String bairro, String cep, String cidade, String complemento, String endereco, String numero, String siglaEstado, Integer tipoEndereco,  String flagRisco){
            this.bairro = bairro;
            this.cep = cep;
            this.cidade = cidade;
            this.complemento = complemento;
            this.endereco = endereco;
            this.numero = numero;
            this.siglaEstado = siglaEstado;
            this.tipoEndereco = tipoEndereco;
            this.flagRisco = flagRisco;
        }
    }

    public class DadosPlano{
        public Integer idPlano;
        public String emitirCertificadoAutomaticamente;
        public String nomePlano;
        
        public DadosPlano(Integer idPlano, String emitirCertificadoAutomaticamente, String nomePlano){
            this.idPlano = idPlano;
            this.emitirCertificadoAutomaticamente = emitirCertificadoAutomaticamente;
            this.nomePlano = nomePlano;
        }
    }

    public class DadosProduto{
        public Integer codProdutoPR;
        public Integer idProduto;
        public String nomeProduto;
        public Boolean imprimeCerfificadoAposAdesao;
        public Integer qtdMaximaContratosVendaNova;

        public DadosProduto(Integer codProdutoPR, Integer idProduto, String nomeProduto, Boolean imprimeCerfificadoAposAdesao, Integer qtdMaximaContratosVendaNova){
            this.codProdutoPR = codProdutoPR;
            this.idProduto = idProduto;
            this.nomeProduto = nomeProduto;
            this.imprimeCerfificadoAposAdesao = imprimeCerfificadoAposAdesao;
            this.qtdMaximaContratosVendaNova = qtdMaximaContratosVendaNova;
        }
    }

    public class TraceAdesao{
        public Integer operacao;
        public String regiao;
        public string cpf;
        public String email;
        public String ip;
        public String url;
        public String token;
        public String sessao;
        public Integer idSistema;
        public Integer idFluxo;
        public String nomeDoBrowser;
        public String versaoDoBrowser;
        public String canal;
        public Integer idPlano;
        public List<Eventos> eventos;

        public TraceAdesao(Integer operacao, String regiao, String cpf, String email, String ip, String url, String token, String sessao, Integer idSistema, Integer idFluxo, String nomeDoBrowser, String versaoDoBrowser, String canal, Integer idPlano, List<Eventos> eventos){
            this.operacao = operacao;
            this.regiao = regiao;
            this.cpf = cpf;
            this.email = email;
            this.ip = ip;
            this.url = url;
            this.token = token;
            this.sessao = sessao;
            this.idSistema = idSistema;
            this.idFluxo = idFluxo;
            this.nomeDoBrowser = nomeDoBrowser;
            this.versaoDoBrowser = versaoDoBrowser;
            this.canal = canal;
            this.idPlano = idPlano;
            this.eventos = eventos;
        }
    }

    public class Eventos{ 
    }
}