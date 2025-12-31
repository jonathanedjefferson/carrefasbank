public class IdentificaCockpitV2 {

    public static ResponseAPI identificaCockpitByCPF(String cpf, String canal){

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('IdentificaCockpitCpf');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String uat = config.UAT__c != null ? config.UAT__c : '';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'x-uat' => uat
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Identifica Cliente Cockpit Por CPF', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            null,
            canal.capitalize()
        );
        
        String status = String.valueOf(objHttpResponse.getStatusCode());

        ResponseAPI retorno = (status == '200' || status == '204') ? 
            (ResponseAPI) System.JSON.deserialize(objHttpResponse.getBody(), ResponseAPI.class) :
            new ResponseAPI();

        retorno.statusCode = status;

        return retorno;
    }

    public class ResponseAPI {
        @AuraEnabled
        public Data data;
        @AuraEnabled
        public String statusCode;
    }

    public class Data {
        @AuraEnabled
        public ClientePorCpfETipoProduto clientePorCpfETipoProduto;
    }

    public class ClientePorCpfETipoProduto {
        public String id;
        public String cpf;
        public Boolean ehBlindado;
        public Boolean ehBlindadoFull;
        @AuraEnabled
        public List<Contratacao> contratacoes;
        public List<Contato> contatos;
        //public List<Documentos> documentos;
    }

    public class Contratacao {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String chaveContratacao;
        @AuraEnabled
        public Datetime dataContratacao;
        @AuraEnabled
        public String statusContratacao;
        @AuraEnabled
        public String unidadeNegocio;
        @AuraEnabled
        public Produto produto;
        @AuraEnabled
        public DadosSociais dadosSociais;
        @AuraEnabled
        public String numeroContaSerno;
    }

    public class DadosSociais {
        public String nomePrimeiro;
        public String nomeMeio;
        public String nomeUltimo;
        public String nomeMae;
        public String nomeCompleto;
        public String genero;
        public DateTime dataNascimento;
    }

    public class Produto {
        @AuraEnabled
        public String idProduto;
        @AuraEnabled
        public String nomeProduto;
    }

    public class Contato {
        public String id;
        public String chaveContratacao;
        public String cpf;
        public String idPessoa;
        public String origem;
        public List<Email> emails;
        public List<Telefone> telefones;
        public List<Endereco> enderecos;
    }

    public class Email {
        public String endereco;
        public String id;
        public Boolean principal;

    }

    public class Telefone {
        public String numero;
        public String ddd;
        public Boolean celularSeguro;
        public String id;
        public String numeroCompleto;
        public Boolean principal;
        public String tipo;
    }

    public class Endereco {
        public String bairro;
        public String cep;
        public String cidade;
        public String uf;
        public String complemento;
        public String id;
        public String logradouro;
        public String numero;
        public Boolean principal;
    }
}