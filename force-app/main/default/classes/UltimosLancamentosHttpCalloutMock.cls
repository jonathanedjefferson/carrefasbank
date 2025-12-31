@isTest
global class UltimosLancamentosHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('cpf', '12345678914');
        response.setHeader('Authorization', 'Bearer TokenExemplo');
        response.setBody('[{"data": "2025-07-15T00:00:00","valor": {"valor": 365.12,"moeda": "R$"},"numeroCartao": "5438821084697614","descricao": "Pagamento Banco CSF","descricaoGrupo": null},{"data": "2025-01-10T00:00:00","valor": {"valor": -1002.94,"moeda": "R$"},"numeroCartao": "5438821084697614","descricao": "Principal da parcela","descricaoGrupo": "Amortização Total do Parcelamento - 7/12"}]');
        response.setStatusCode(200);
        return response; 
    }
}