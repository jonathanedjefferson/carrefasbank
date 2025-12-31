public class IdentificaComprouVoltou {

    private static String customerCpf;
    private static String customerPhone;
    private static String bussinessUnit;
    private static String origin;
    private static List<String> validCreditCardStatus;
    private static List<String> validCreditCardStatusInsecurityPhone;
    private static final Map<String, String> MAP_BUSSINESS_UNIT = new Map<String, String>{
        '1' => 'CSF',
        '2' => 'ATC',
        '6' => 'SAMS'
    };

    @InvocableMethod(label='Identifica Cliente Comprou Voltou')
    public static List<Output> identificaClienteComprouVoltou(List<Input> lLstInput) {

        if (validateInput(lLstInput)) {
            return executionError('ERROR', 'Parâmetros obrigatórios ausentes');
        }

        setVariables(lLstInput);

        IdentificaCockpitV2.ResponseAPI response = IdentificaCockpitV2.identificaCockpitByCPF(customerCpf, origin);

        if ('500'.equals(response.statusCode)) {
            return executionError('ERROR', 'Falha na integração');
        }

        if (response.data == null || '404'.equals(response.statusCode)) {
            return executionError('NOTFOUND', 'Cliente não encontrado');
        }

        Output returnResponse = new Output();
        evaluateCustomerHasCashback(response, returnResponse);

        if ('Whatsapp'.equals(origin) || String.isBlank(origin)) {
            evaluateSecurityPhone(response, customerPhone, returnResponse);
            evaluateCreditCard(response, returnResponse);
        }

        returnResponse.statusAPI = 'OK';
        returnResponse.message = 'Executado com sucesso';

        return new List<Output>{returnResponse};
    }

    private static void setVariables(List<Input> lLstInput) {
        customerCpf = lLstInput.get(0).cpf;
        customerPhone = lLstInput.get(0).phone;
        origin = lLstInput.get(0).origin;
        String bussinessUnitEntry = lLstInput.get(0).bussinessUnit;
        bussinessUnit = MAP_BUSSINESS_UNIT.get(bussinessUnitEntry);
        validCreditCardStatus = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPermitido' + bussinessUnit);
        validCreditCardStatusInsecurityPhone = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPermitidoSemCelularSeguro');
    }

    private static Boolean validateInput(List<Input> lLstInput) {
        if (lLstInput.isEmpty()) {
            return true;
        }

        String customerCpf = lLstInput.get(0).cpf;
        String customerPhone = lLstInput.get(0).phone;
        String bussinessUnit = lLstInput.get(0).bussinessUnit;
        String origin = lLstInput.get(0).origin;

        //Validação para Chat
        if ('Chat'.equals(origin) && String.isBlank(customerCpf)) {
            return true;
        }

        //Validação para Whatsapp
        if (('Whatsapp'.equals(origin) || String.isBlank(origin)) && 
            (String.isBlank(customerCpf) || String.isBlank(customerPhone) || String.isBlank(bussinessUnit))) {
            return true;
        }

        return false;
    }

    private static List<Output> executionError(String statusApi, String message) {
        Output returnValue = new Output();
        returnValue.hasComprouVoltou = false;
        returnValue.statusAPI = statusApi;
        returnValue.message = message;

        return new List<Output>{returnValue};
    }

    private static void evaluateCustomerHasCashback(IdentificaCockpitV2.ResponseAPI response, Output returnValue) {
        IdentificaCockpitV2.ClientePorCpfETipoProduto clientData = response?.data?.ClientePorCpfETipoProduto;
        List<IdentificaCockpitV2.Contratacao> lLstContratacoes = clientData.contratacoes;

        if (lLstContratacoes == null || lLstContratacoes.isEmpty()) {
            return;
        }

        Boolean hasComprouVoltou = false;
        for (IdentificaCockpitV2.Contratacao contratacao : lLstContratacoes) {
            IdentificaCockpitV2.Produto product = contratacao.produto;

            if ('Cashback'.equals(product.nomeProduto)) {
                hasComprouVoltou = true;
                returnValue.contractStatus = contratacao.statusContratacao;
                returnValue.contractNumber = contratacao.chaveContratacao;
                break;
            }
        }

        returnValue.hasComprouVoltou = hasComprouVoltou;
    }

    private static void evaluateSecurityPhone(IdentificaCockpitV2.ResponseAPI response, String customerPhone, Output returnValue) {
        String customerPhoneNumber = customerPhone.replace('whatsapp:+', '');
        customerPhoneNumber = formatPhone(customerPhoneNumber);

        List<IdentificaCockpitV2.Contato> lLstContatos = response.data.clientePorCpfETipoProduto.contatos;

        if (lLstContatos == null || lLstContatos.isEmpty()) {
            return;
        }

        for (IdentificaCockpitV2.Contato contato : lLstContatos) {
            if (contato.telefones == null || contato.telefones.isEmpty()) {
                continue;
            }

            for (IdentificaCockpitV2.Telefone telefone : contato.telefones) {
                telefone.numeroCompleto = formatPhone(telefone.numeroCompleto);
                if (telefone.numeroCompleto == customerPhoneNumber) {
                    returnValue.hasSecurityPhone = true;
                    break;
                }
            }
        }
    }

    private static String formatPhone(String phoneNumber) {
        phoneNumber = phoneNumber.replaceAll('\\D', '');

        if (phoneNumber.startsWith('55')) {
            phoneNumber = phoneNumber.substring(2);
        }

        if (phoneNumber.length() == 11) {
            return '55' + phoneNumber;
        }
        else if (phoneNumber.length() == 10) {
            phoneNumber = phoneNumber.substring(0, 2) + '9' + phoneNumber.substring(2);
        }

        return '55' + phoneNumber;
    }

    private static void evaluateCreditCard(IdentificaCockpitV2.ResponseAPI response, Output returnValue) {
        List<IdentificaCockpitV2.Contratacao> lLstContratacao = response.data.clientePorCpfETipoProduto.contratacoes;

        if (lLstContratacao == null || lLstContratacao.isEmpty()) {
            return;
        }

        for (IdentificaCockpitV2.Contratacao contratacao : lLstContratacao) {
            IdentificaCockpitV2.Produto product = contratacao.produto;
            if (returnValue.hasSecurityPhone && 'Cartão'.equals(product.nomeProduto) && bussinessUnit.equals(contratacao.unidadeNegocio)) {
                returnValue.hasCreditCard = true;
                
                if (validCreditCardStatus.contains(contratacao.statusContratacao)) {
                    returnValue.hasAccessToApp = true;
                }
                
                break;
            }

            if (!returnValue.hasSecurityPhone && 'Cartão'.equals(product.nomeProduto) && bussinessUnit.equals(contratacao.unidadeNegocio)) {
                returnValue.hasCreditCard = true;

                if (validCreditCardStatusInsecurityPhone.contains(contratacao.statusContratacao)) {
                    returnValue.hasAccessToApp = true;
                }

                break;
            }
        }
    }

    public class Input {
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String bussinessUnit;
        @InvocableVariable
        public String phone;
        @InvocableVariable
        public String origin; //Chat ou Whatsapp
    }

    public class Output {
        @InvocableVariable
        public Boolean hasComprouVoltou = false;
        @InvocableVariable
        public String contractStatus;
        @InvocableVariable
        public String contractNumber;
        @InvocableVariable
        public Boolean hasSecurityPhone = false;
        @InvocableVariable
        public Boolean hasCreditCard = false;
        @InvocableVariable
        public Boolean hasAccessToApp = false;
        @InvocableVariable
        public String statusAPI;
        @InvocableVariable
        public String message;
    }
}