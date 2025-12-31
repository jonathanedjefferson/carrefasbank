public with sharing class IdentificaClienteChatV2 {
    public static OutputIdentifica IdentificarCliente(String token, String accountNumber, String uniqueId) {        
        OutputIdentifica retorno = new OutputIdentifica();
        String cpf = '';
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaClienteChatV2');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'NumeroConta' => accountNumber,
                'IdUnico' => uniqueId,
                'Authorization' => 'Bearer '+ token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputIdentifica) System.JSON.deserialize(objHttpResponse.getBody(), OutputIdentifica.class);
            cpf = retorno.data.cliente.cpf;
        }
        
        retorno.statusCode = status;
        
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Identifica Cliente Chat V2', 
            config.Endpoint__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            accountNumber,
            'Chat'
        );    

        return retorno;    
    }

    // RETORNO DO METODO "IdentificarCliente"
    public class OutputIdentifica {
        public Data data;
        public String statusCode;
    }

    public class Data {
        public Cliente cliente;
    }

    public class Cliente {
        public List<DadosSociais> dadosSociais;
        public ContaCartao contaCartao;
        public Contato contato;
        public String cpf;
    }

    public class DadosSociais {
        public String nomePrimeiro;
        public String nomeMeio;
        public String nomeUltimo;
        public String nomeSocial;
        public Datetime dataDeNascimento;
        public String nomeMae;
        public String genero;
        public String nomeCompleto;
        public String numeroConta;
        public String tipoEnvioFatura;
    }

    public class ContaCartao {
        public List<Contratos> contratos;
    }

    public class Contato {
        public List<DadosContato> dadosContato;
    }

    public class Contratos {
        public Decimal valorLimiteTotal;
        public Decimal valorLimiteDisponivel;
        public Boolean ehPropensoCancelamento;
        public String numeroContaSerno;
        public String statusGeralCartaoPrimario;
        public Integer classificacaoStatusConta;
        public Boolean aumentoAutomaticoDeLimite;
        public List<Cartoes> cartoes;
        public SaldoPreAprovado saldoPreAprovado;
        public Boolean podeContratarCreditoPessoal;
        public String numeroConta;
        public String unidadeNegocio;
        public String dataAberturaConta;
        public String statusConta;
        public String perfilAnuidade;
    }

    public class DadosContato {
        public String numeroConta;
        public List<Telefones> telefones;
        public List<Emails> emails;
    }

    public class Cartoes {
        public String dataAtivacao;
        public String nomeCartao;
        public String nomeProduto;
        public String idProduto;
        public String tipoCartao;
        public String bandeira;
        public String id;
        public String numeroCartao;
        public String statusCartao;
        public String tipoTitularidade;
        public String nomePortador;
        public Boolean ehPrimario;
        public Boolean ehAtivo;
        public Boolean ehVirtual;
    }

    public class SaldoPreAprovado {
        public Decimal contratacoesPermitidas;
        public Decimal contratacoesDisponiveis;
        public Decimal saldoDisponivel;
        public Decimal limiteTotal;
    }
    
    public class Telefones {
        public String ddd;
        public String numero;
        public Boolean celularSeguro;
    }

    public class Emails {
        public String endereco;
    }
}