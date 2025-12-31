public class BCSF_AquisicaoDeCartaoOperacao {
    @invocableMethod(label='Gerenciar Operações')
    public static List<OutputData> manageActions(List<InputData> lLstInputs){
        InputData input = lLstInputs.get(0);
        List<OutputData> lLstOutputData = processAction(input);

        return lLstOutputData; 
    }

    private static List<OutputData> processAction(InputData input) {
        OutputData output = new OutputData();
        BCSF_AquisicaoDeCartaoTO.responseWrapper response;

        switch on input.actionName {
            when 'IniciarchatBuscaProposta' { //200

                Integer comprimento = input.numeroTelefone.length();
                if (comprimento == 12) {
                    input.numeroTelefone = input.numeroTelefone.substring(2, 4) + '9' + input.numeroTelefone.substring(4);
                } else if (comprimento > 11) {
                    input.numeroTelefone = input.numeroTelefone.substring(comprimento - 11);
                }

                response = BCSF_AquisicaoDeCartao.iniciarChat(input.idEmpresa, input.numeroTelefone, 'Whatsapp', input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                BCSF_AquisicaoDeCartaoTO.iniciarChatResponseWrapper responseBody = 
                   (BCSF_AquisicaoDeCartaoTO.iniciarChatResponseWrapper) response.body;

                output.statusCode = response.statusCode;
                output.message = response.message;
                output.idProposta = responseBody.idProposta;
                output.etapa = responseBody.etapa;
                output.limite = responseBody.limite;
                output.limiteFormatado = formatLimite(responseBody.limite);
                output.nome = responseBody.nome;
            }
            when 'IniciarAutenticacaoPorBiometria' { //200
                response = BCSF_AquisicaoDeCartao.iniciarAutenticacaoPorBiometria(input.idProposta, input.idEmpresa, 'Whatsapp', input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                BCSF_AquisicaoDeCartaoTO.iniciarAutenticacaoPorBiometriaResponseWrapper responseBody = 
                    (BCSF_AquisicaoDeCartaoTO.iniciarAutenticacaoPorBiometriaResponseWrapper) response.body;
                output.statusCode = response.statusCode;
                output.message = response.message;
                output.urlAutenticacao = responseBody.urlAutenticacao;
            }
            when 'ValidarAutenticacaoPorBiometria' { //200
                response = BCSF_AquisicaoDeCartao.validarAutenticacaoPorBiometria(input.idProposta, input.idEmpresa, 'Whatsapp', input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                 BCSF_AquisicaoDeCartaoTO.validarAutenticacaoPorBiometriaResponseWrapper responseBody = 
                    (BCSF_AquisicaoDeCartaoTO.validarAutenticacaoPorBiometriaResponseWrapper) response.body;
                output.statusCode = response.statusCode;
                output.message = response.message;
                output.etapa = responseBody.etapa;
            }
            when 'EfetuarConfiguracaoDoCartao' { //200
                response = BCSF_AquisicaoDeCartao.efetuarConfiguracaoDoCartao(input.idProposta, input.idEmpresa, 'Whatsapp',
                    input.optinAumentoLimite, input.optinOverlimit, input.diaVencimento, input.cpf);

                if (response.statusCode != 200) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoResponseWrapper body = 
                    (BCSF_AquisicaoDeCartaoTO.efetuarConfiguracaoDoCartaoResponseWrapper) response.body;

                output.cep = body.endereco.cep;
                output.logradouro = body.endereco.logradouro;
                output.bairro = body.endereco.bairro;
                output.cidade = body.endereco.cidade;
                output.estado = body.endereco.estado;
                output.numero = body.endereco.numero;
                output.complemento = body.endereco.complemento;
                output.diaVencimento = body.proposta.diaVencimento;
                output.limite = body.proposta.limite;
                output.limiteFormatado = formatLimite(body.proposta.limite);
                output.nome = body.produto.nome;
                output.diasEntrega = body.produto.diasEntrega;
                output.anuidade = formatLimite(body.produto.anuidade);
                output.termoId = insertFile(body.termo);
                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'AceiteDaOferta' { //204
                response = BCSF_AquisicaoDeCartao.aceiteDaOferta(input.idProposta, input.idEmpresa, 'Whatsapp', input.aceita, input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'AbandonoDeProposta' { //204
                response = BCSF_AquisicaoDeCartao.abandonoDeProposta(input.idProposta, input.idEmpresa, 'Whatsapp', input.motivo, input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }

                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when 'DesistenciaDeCadastroDeProposta' { //204
                response = BCSF_AquisicaoDeCartao.desistenciaDeCadastroDeProposta(input.idEmpresa, 'Whatsapp', input.motivo, input.cpf);

                if (response.statusCode != 204) {
                    output.statusCode = response.statusCode;
                    output.message = response.message;

                    return new List<OutputData>{output};
                }
                
                output.statusCode = response.statusCode;
                output.message = response.message;
            }
            when else {
                output.message = 'A ação com o nome ' + input.actionName + ' não existe';
                output.statusCode = 500;
            }
        }

        return new List<OutputData>{output};
    }

    private static String formatLimite(Decimal value) {
        if (value == null) {
            return '';
        }

        String formatedValue = value.setScale(2).format();
        List<String> valueParts = formatedValue.split(',');

        if (valueParts.size() == 1) {
            return 'R$ ' + formatedValue + ',00';
        }

        return valueParts[1].length() == 1 ? 'R$ ' + formatedValue + '0' : 'R$ ' + formatedValue;
    }

    private static Id insertFile(String fileData){
        
        Blob baseFile = EncodingUtil.base64Decode(fileData);
        String identificador = GuidUtil.NewGuid();

        ContentVersion itemContent = new ContentVersion(
            Title = 'Termo de Adesao Cartao Carrefour.pdf',
            PathOnClient = 'Termo de Adesao Cartao Carrefour.pdf',
            VersionData = baseFile, 
            origin = 'H',
            IsMajorVersion = true
        );

        insert itemContent;

        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Termo de Adesao Cartao Carrefour.pdf';
        cd.ContentVersionId = itemContent.Id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesExpires = true;
        datetime expiryTime = datetime.now().addMinutes(120);
        cd.ExpiryDate = expiryTime;
        insert cd;
               
        return itemContent.Id;
    }

    public class InputData {
        @InvocableVariable
        public String actionName;
        @InvocableVariable
        public Integer idEmpresa;
        @InvocableVariable
        public String cpf;
        @InvocableVariable
        public String numeroTelefone;
        @InvocableVariable
        public String idProposta;
        @InvocableVariable
        public Boolean optinAumentoLimite;
        @InvocableVariable
        public Boolean optinOverlimit;
        @InvocableVariable
        public String diaVencimento;
        @InvocableVariable
        public Boolean aceita;
        @InvocableVariable
        public String motivo;
    }

    public class OutputData {
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Integer statusCode;
        @InvocableVariable
        public String idProposta;
        @InvocableVariable
        public String etapa;
        @InvocableVariable
        public Decimal limite;
        @InvocableVariable
        public String limiteFormatado;
        @InvocableVariable
        public String nome;
        @InvocableVariable
        public String urlAutenticacao;
        @InvocableVariable
        public String cep;
        @InvocableVariable
        public String logradouro;
        @InvocableVariable
        public String bairro;
        @InvocableVariable
        public String cidade;
        @InvocableVariable
        public String estado;
        @InvocableVariable
        public String numero;
        @InvocableVariable
        public String complemento;
        @InvocableVariable
        public String diaVencimento;
        @InvocableVariable
        public String diasEntrega;
        @InvocableVariable
        public String anuidade;
        @InvocableVariable
        public Id termoId;
    }
}