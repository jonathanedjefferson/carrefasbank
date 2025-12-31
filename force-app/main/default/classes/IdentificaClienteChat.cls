public class IdentificaClienteChat {
    public static OutputIdentifica IdentificarCliente(String tokenLogado, String idEmpresa) {        
        OutputIdentifica retorno = new OutputIdentifica();
        String cpf = '';
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaClienteChat');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenLogado,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputIdentifica) System.JSON.deserialize(objHttpResponse.getBody(), OutputIdentifica.class);
            cpf = retorno.data.cliente.cpf;
        }else{
            List<TokenDecode.Input> listTokenInput = new List<TokenDecode.Input>();
            TokenDecode.Input inputToken = new TokenDecode.Input();
            inputToken.Token = tokenLogado;
            listTokenInput.add(inputToken);
            List<TokenDecode.Output> retornoToken = TokenDecode.DecodeToken(listTokenInput);

            cpf = retornoToken[0].cpf;
        }
        retorno.statusCode = status;
        
        
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Identifica Cliente', 
            config.Endpoint__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
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
        public String nomeCompleto;
        public String numeroConta;
        public Datetime dataDeNascimento;
        public String nomeMae;
        public String genero;
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
        public String numeroContaSerno;
        public List<Cartoes> cartoes;
        public String numeroConta;
        public String unidadeNegocio;
        public String dataAberturaConta;
        public String statusConta;
        public String perfilAnuidade;
        public String tipoCartaoTransversal;
    }

    public class DadosContato {
        public String numeroConta;
        public List<Telefones> telefones;
        public List<Emails> emails;
    }

    public class Cartoes {
        public String id;
        public String numeroCartao;
        public String statusCartao;
        public Boolean ehPrimario;
        public Boolean ehAtivo;
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