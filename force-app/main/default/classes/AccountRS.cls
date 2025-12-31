@RestResource(urlMapping='/accountService/*')
global class AccountRS {

    @HttpPost
    global static AccountResponse createAccount() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Lê o JSON do corpo da requisição
        AccountRequest input = (AccountRequest) JSON.deserialize(req.requestBody.toString(), AccountRequest.class);

        AccountResponse output = new AccountResponse();

        try {
            IdentificaCockpit.ResponseAPIContaFinanceira responseIdc = IdentificaCockpit.identificaNumeroConta(input.accountNumber, '', '', '');
            String cpf = responseIdc?.data?.clientePorConta?.cpf;
            Account newAccount = IdentificaCockpitController.consultaContaPorCPF(cpf, 'Cockpit');
            ContaFinanceira__c financialAccount = ContaFinanceiraDAO.getDadosContaFinanceiraNumero(input.accountNumber);

            output.finAccountId = financialAccount.Id;
            output.message = 'Conta criada com sucesso.';
            res.statusCode = 201; // Created
        } catch (Exception e) {
            res.statusCode = 400;
            output.message = 'Erro ao criar a conta financeira: ' + e.getMessage();
        }

        return output;
    }

    global class AccountRequest {
        public String accountNumber;
    }
    
    global class AccountResponse {
        public String finAccountId;
        public String message;
    }
}