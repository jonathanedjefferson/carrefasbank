public class IntegrationAlteracaoCadastral {
    public static Boolean AlterarEmail(String cpf, String idEmpresa, String canal, String email, String numeroConta, String area, String sistema){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AlterarEmail');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'area' => area,
                'sistema' => sistema,
                'canal' => canal,
                'login_operador' => loginOperador,
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c

            }, 
            config.Body__c.replace('{email}', email), 
            Integer.valueof(config.Timeout__c)
        );

        String statusCode = String.valueOf(objHttpResponse.getStatusCode());
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Alteração de E-mail', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c.replace('{email}', email), 
            cpf, 
            statusCode, 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        ); 
        
        if (statusCode.equals('200') || statusCode.equals('204')) {
            return true;
        }
        return false;
    }

    /* 
        OBS:
            - Nas informações do bodyRequest, se não for preciso alterar determinado campo, definir o valor como 'null'.
    */
    public static Boolean AlterarDadosCadastrais(String cpf, String idEmpresa, String canal, String numeroConta, String area, String sistema, BodyRequestAlterarDadosCadastrais bodyRequest){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AlterarDadosCadastrais');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'cpf' => cpf,
                'area' => area,
                'sistema' => sistema,
                'canal' => canal,
                'login_operador' => loginOperador,
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c
            }, 
            System.JSON.serialize(bodyRequest), 
            Integer.valueof(config.Timeout__c)
        );

        String statusCode = String.valueOf(objHttpResponse.getStatusCode());
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Alteração Cadastral', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            System.JSON.serialize(bodyRequest), 
            cpf, 
            statusCode, 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        ); 
        
        if (statusCode.equals('200') || statusCode.equals('204')) {
            return true;
        }
        return false;
    }

// ######################################## BODY REQUEST DO METODO 'AlterarDadosCadastrais' ########################################
    /* 
        OBS:
            - Nas informações do bodyRequest, se não for preciso alterar determinado campo, definir o valor como 'null'.
    */
    public class BodyRequestAlterarDadosCadastrais {
        public Cliente cliente;

        public BodyRequestAlterarDadosCadastrais(){
            this.cliente = new Cliente();
        }
    }

    public class Cliente {
        public DadosGerais dadosGerais;
        public Contrato contrato;
        public Documentos documentos;
        public Endereco endereco;
        public Contato contato;
        public Consentimentos consentimentos;

        public Cliente(){
            this.dadosGerais = new DadosGerais();
            this.contrato = new Contrato();
            this.documentos = new Documentos();
            this.endereco = new Endereco();
            this.contato = new Contato();
            this.consentimentos = new Consentimentos();
        }
    }
    
    public class DadosGerais {
        public String primeiroNome;
        public String nomeMeio;
        public String sobrenome;
        public String dataNascimento;   // FORMATO: "dd-mm-yyyy"
        public Integer sexo;            // VALORES: FEMININO = 1 | MASCULINO = 2
        public String naturalidade;
        public Integer estadoCivil;     // VALORES: NAO_INFORMADO = 0 | SOLTEIRO = 1 | CASADO = 2 | VIUVO = 3 | DIVORCIADO = 4 | SEPARADO = 5 | UNIAO_ESTAVEL = 6 | DESCONHECIDO = 7 | OUTRO = 8
        public String nomeMae;
    }
    
    public class Contrato {
        public String numeroConta;
    }

    public class Documentos {
        public String rg;
    }
    
    public class Endereco {
        public String cep;
        public String logradouro;
        public String numero;
        public String complemento;
        public String bairro;
        public String cidade;
        public String uf;
    }

    public class Contato {
        public String dddTelefoneResidencial;
        public String telefoneResidencial;
        public String dddTelefoneCelular;
        public String telefoneCelular;
        public String email;
    }

    public class Consentimentos {
        public Boolean aceiteRecebimentoEmail;
        public Boolean indicadorAceiteAtualizacaoLimite;
    }
// ######################################## FIM BODY REQUEST DO METODO 'AlterarDadosCadastrais' ########################################
}