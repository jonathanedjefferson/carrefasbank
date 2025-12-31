global class FlowIdentificaClienteAPIHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        response.setHeader('Cookie', 'incap_ses_1218_2400284=NWlwBv01iErhbWmFazXnEI0zhWIAAAAAaNqNnManGXUp6inBuasQoQ==;4');
        response.setBody('{"data":{"cliente":{"cpf":"02272276032","dadosSociais":[{"numeroConta":"37000038721","nomePrimeiro":"BRUNO","nomeMeio":"GOMES","nomeUltimo":"DANTAS","nomeCompleto":"BRUNO GOMES DANTAS","nomeSocial":"","dataDeNascimento":"0001-01-01T00:00:00"}],"contaCartao":{"contratos":[{"numeroConta":"37000038721","numeroContaSerno":"682895","codigoProdutoCurto":"AMCHL","unidadeNegocio":"CSF","classificacaoStatusConta":0,"statusConta":"DLNQ","valorLimiteTotal":10000,"valorLimiteDisponivel":10000,"diaVencimento":0,"cartoes":[{"numeroCartao":"5300.XXXX.XXXX.9562","ehVirtual":false,"statusCartao":"DLNQ","vencimentoCartao":"0001-01-01T00:00:00+00:00","ehPrimario":true,"ehAtivo":false}]}],"ultimaDataModificacao":"0001-01-01T00:00:00"},"contato":{"dadosContato":[{"numeroConta":"37000038721","emails":[{"endereco":"fake@person.com","numeroSerie":0}],"telefones":[{"numero":"988888888","ddd":"11","celularSeguro":false,"numeroSerie":0},{"numero":"44443333","ddd":"11","celularSeguro":false,"numeroSerie":0},{"numero":"991055985","ddd":"11","celularSeguro":true,"numeroSerie":0}]}],"ultimaDataModificacao":"0001-01-01T00:00:00"},"ultimaDataModificacao":"0001-01-01T00:00:00"}}}');
        response.setStatusCode(200);
        return response; 
    }
}