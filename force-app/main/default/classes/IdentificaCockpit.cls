public without sharing class IdentificaCockpit {
    public static ResponseAPIConta identificaConta(String cpf, String accountId, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaCockpit');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        String usuarioId = UserInfo.getUserId();
        
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'x-uat' => config.UAT__c
            }, 

            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Identifica Cliente Cockpit', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize(),
            usuarioId
        );
        
        ResponseAPIConta retorno;

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (ResponseAPIConta) System.JSON.deserialize(objHttpResponse.getBody(), ResponseAPIConta.class);
        }
        return retorno;
    }

    public static ResponseAPIContaFinanceira identificaNumeroConta(String numeroConta, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaCockpitNumeroConta');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        String usuarioId = UserInfo.getUserId();
        System.debug('UsuarioId:'+usuarioId);

        ResponseAPIContaFinanceira retorno;
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'numeroConta' => numeroConta,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Identifica Cliente Cockpit Conta Financeira', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize(),
            usuarioId
        );

        String status = String.valueOf(objHttpResponse.getStatusCode());
        System.debug('0000 '+status);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (ResponseAPIContaFinanceira) System.JSON.deserialize(objHttpResponse.getBody(), ResponseAPIContaFinanceira.class);
        }
        
        return retorno;
    }


    // Classe para o deserialize do identifica cockpit Conta(Account) - método (identificaConta)
    public class ResponseAPIConta{
        public DadosConta data;
        public Boolean ehBlindado;
        public Boolean ehBlindadoFull;

    }
    public class DadosConta {
        public Cliente cliente;
    }

    public class Cliente {
        public String cpf;
        public ContasResponse contaCartao;
        public List<DadosSociaisAccount> dadosSociais;
    }

    public class DadosSociaisAccount {
        public String numeroConta;
        public DateTime dataDeNascimento;
        public String nomeCompleto;
        public String nomePrimeiro;
        public String nomeMeio;
        public String nomeUltimo;
        public String nomeSocial;
        public String nomeMae;
        public String genero;
    }

    public class ContasResponse {
        public List<ContaResponse> contratos;
    }

    public class ContaResponse {
        public String statusConta;
        public String unidadeNegocio;
        public String numeroConta;
        public String tipoEnvioFatura;
        public Integer tipoCartaoTransversal;
        public String numeroContaSerno;
    }

// Classe para o deserialize do identifica conta financeira (identificaNumeroConta)
    public class ResponseAPIContaFinanceira {
        @AuraEnabled
        public Data data;
        public Boolean ehBlindado;
        public Boolean ehBlindadoFull;
    }
    public class Data {
        @AuraEnabled
        public ClientePorConta clientePorConta;
    }

    public class ClientePorConta {
        public String cpf;
        public List<DadosSociais> dadosSociais;
        @AuraEnabled
        public ContaCartao contaCartao;
        public Contato contato;
        public List<Identidades> identidades;
    }

    public class Identidades{
        public String tipo;
        public String valor;
    }

    public class DadosSociais {
        public Integer estadoCivil;
        public String numeroConta;
        public String statusConta;
        public String unidadeNegocio;
        public String genero;
    }

    public class ContaCartao {
        @AuraEnabled
        public List<Contrato> contratos;
    }

    public class Contrato {
        public Boolean aceiteRecebimentoDeEmail;
        public Integer tipoCartaoTransversal;
        public Boolean aumentoAutomaticoDeLimite;
        public String numeroConta;
        public String numeroContaSerno;
        public String unidadeNegocio;
        public String statusConta;
        public String tipoEnvioFatura;
        @AuraEnabled
        public Decimal valorLimiteDisponivel;
        @AuraEnabled
        public Decimal valorLimiteTotal;
        @AuraEnabled
        public List<Cartao> cartoes;
    }

    public class Cartao {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String numeroCartao;
        @AuraEnabled
        public Boolean ehAtivo;
        @AuraEnabled
        public Boolean ehPrimario;
        @AuraEnabled
        public Boolean ehVirtual;
        public String cpfPortador;
        @AuraEnabled
        public String nomePortador;
        @AuraEnabled
        public String tipoTitularidade;
        public DateTime dataAtivacao;
        @AuraEnabled
        public DateTime vencimentoCartao;
        public String nomeCartao;
        public String nomeProduto;
        public String idProduto;
        public String tipoCartao;
        public String bandeira;
        public Boolean ehContactless;
        @AuraEnabled
        public String statusCartao;
    }

    public class Contato {
        public List<DadosContato> dadosContato;
    }

    public class DadosContato {
        public String numeroConta;
        public String unidadeNegocio;
        public List<Endereco> enderecos;
        public List<Email> emails;
        public List<Telefone> telefones;
    }

    public class Endereco {
        public String cep;
        public List<String> tipoEndereco;
        public String logradouro;
        public String numero;
        public String complemento;
        public String bairro;
        public String uf;
        public String cidade;
        public String pais;
        public List<String> finalidadeEndereco;
    }

    public class Email {
        public String endereco;
        public List<String> tipoEmail;
    }

    public class Telefone {
        public Boolean celularSeguro;
        public String ddd;
        public List<String> tipoContato;
        public String numero;
        public String tipo;
    }
}