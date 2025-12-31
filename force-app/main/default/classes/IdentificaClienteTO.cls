global class IdentificaClienteTO {
    global class DadosTO{
        @InvocableVariable 
        global DadosGeraisTO data;
        global String telefoneEntrada;

        global DadosTO(){
            this.data = new DadosGeraisTO();
        }
    }

    global class DadosGeraisTO{
        
        @InvocableVariable
        global ClienteTO cliente;
        global DadosGeraisTO(){
            this.cliente = new ClienteTO();
        }
    }

    global class ClienteTO{
        @InvocableVariable
        global String cpf;
        @InvocableVariable
        global List<DadosSociaisTO> dadosSociais;
        @InvocableVariable
        global ContaCartaoTO contaCartao; 
        @InvocableVariable
        global ContatoTO contato; 

        global ClienteTO(){
            this.dadosSociais = new List<DadosSociaisTO>();
            this.contaCartao = new ContaCartaoTO();
            this.contato = new ContatoTO();
        }
    }

    global class DadosSociaisTO{
        @InvocableVariable
        global String numeroConta;
        @InvocableVariable
        global String nomePrimeiro;
        @InvocableVariable
        global String nomeMeio;
        @InvocableVariable
        global String nomeUltimo;
        @InvocableVariable
        global String nomeCompleto;
        @InvocableVariable
        global String nomeSocial;
        @InvocableVariable
        global String dataDeNascimento;
        @InvocableVariable
        global String tipoEnvioFatura;
    }

    global class ContaCartaoTO{
        @InvocableVariable
        global List<ContratoTO> contratos;
        @InvocableVariable
        global String ultimaDataModificacao;

        global ContaCartaoTO(){
            this.contratos = new List<ContratoTO>();
        }
    }

    global class ContratoTO{
        @InvocableVariable
        global string numeroConta;
        @InvocableVariable
        global string numeroContaSerno;
        @InvocableVariable
        global string codigoProdutoCurto;
        @InvocableVariable
        global string unidadeNegocio;
        @InvocableVariable
        global Integer classificacaoStatusConta;
        @InvocableVariable
        global string statusConta;
        @InvocableVariable
        global Decimal valorLimiteTotal;
        @InvocableVariable
        global Decimal valorLimiteDisponivel;
        @InvocableVariable
        global Integer diaVencimento;
        @InvocableVariable
        global String dataAberturaConta;
        @InvocableVariable
        global List<CartaoTO> cartoes;
        @InvocableVariable
        global Integer tipoCartaoTransversal;

        global ContratoTO(){
            this.cartoes = new List<CartaoTO>();
        }
    }

    global class CartaoTO{
        @InvocableVariable
        global string id;
        @InvocableVariable
        global string numeroCartao;
        @InvocableVariable
        global Boolean ehVirtual;
        @InvocableVariable
        global string statusCartao;
        @InvocableVariable
        global string vencimentoCartao;
        @InvocableVariable
        global Boolean ehPrimario;
        @InvocableVariable
        global Boolean ehAtivo;
    }

    global class ContatoTO{
        global List<DadosContatoTO> dadosContato;

        global ContatoTO(){
            this.dadosContato = new LisT<DadosContatoTO>();
        }
    }

    global class DadosContatoTO{
        @InvocableVariable
        global List<EmailTO> emails;
        @InvocableVariable
        global List<TelefoneTO> telefones;
        @InvocableVariable
        global String numeroConta;

        global DadosContatoTO(){
            this.emails = new List<EmailTO>();
            this.telefones = new List<TelefoneTO>();
        }
    }

    global class EmailTO{
        @InvocableVariable
        global string endereco;
        @InvocableVariable
        global Integer numeroSerie;
    }

    global class TelefoneTO{
        @InvocableVariable
        global string numero;
        @InvocableVariable
        global string ddd;
        @InvocableVariable
        global Boolean celularSeguro;
        @InvocableVariable
        global Integer numeroSerie;
    }
}