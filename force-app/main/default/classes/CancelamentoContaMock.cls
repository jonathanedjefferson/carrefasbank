@isTest
global class CancelamentoContaMock implements HttpCalloutMock{
    Map<String, HttpResponse> responseByEndpoint;

    /*************************************************************************************************************************************************
    * @description Constructor                                                                                                                       *
    * @param HttpResponse O HttpResponse para retornar se as respostas mapeadas forem nulas ou não encontrarem correspondência                       *
    * @param Map<String,HttpResponse> O mapa de respostas a serem retornadas com o ponto final ou a parte do corpo da resposta como as chaves        *
    **************************************************************************************************************************************************/
    public CancelamentoContaMock(Map<String, HttpResponse> responseByEndpoint) {
        this.responseByEndpoint = responseByEndpoint;
    }

    /*************************************************************************************************************************************************
    * @description Método de interface HttpCalloutMock para retornar a resposta                                                                      *
    * @param HttpRequest O Request                                                                                                                   *
    * @return HttpResponse O Response                                                                                                                *
    **************************************************************************************************************************************************/
    public HttpResponse respond(HttpRequest req) {
        if (responseByEndpoint.containsKey(req.getEndpoint())) {
            return responseByEndpoint.get(req.getEndpoint());
        }

        for (String item: responseByEndpoint.keySet()) {
            if (req.getEndpoint().containsIgnoreCase(item)) {
                return responseByEndpoint.get(item);
            }
        }

        return new HttpResponse();
    }
}