public with sharing class ConsultarPedidosCliente {
    public static ConsultarPedidosClienteTO.Retorno makeAPIRequest(String email, String orderCode) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Verificar se pedido existe no email');
        String apiUrl = config.endpoint__c + '?email=' + email + '&limit=10&offset=0&viewType=AREA_LOGADA';

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        request.setMethod(config.method__c);
        request.setEndpoint(apiUrl);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', config.token__c);
        request.setHeader('x-api-key', config.apiKey__c);

        HttpResponse response = http.send(request);
        LogIntegracaoBO.InsertLog('Verificar se pedido existe no email', apiUrl, config.method__c, 'vazio', 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');
        ConsultarPedidosClienteTO.responseWrapper retorno = (ConsultarPedidosClienteTO.responseWrapper) JSON.deserialize(response.getBody(), ConsultarPedidosClienteTO.responseWrapper.class);
        ConsultarPedidosClienteTO.Retorno resposta = new ConsultarPedidosClienteTO.Retorno();

        if(orderCode != null && orderCode != '') {
            for (ConsultarPedidosClienteTO.objects objeto: retorno.objects) {
                //statusCode = 0: pedido encontrado no email informado.
                //statusCode = 1: pedido não encontrado no email informado.
                if(objeto.orderCode == orderCode) {
                    resposta.numeroPedido = objeto.orderCode;
                    resposta.modalidade = objeto.consignments[0].delivery.modality;
                    resposta.status = objeto.consignments[0].status.status;
                    resposta.dataAtualizacaoStatus = objeto.consignments[0].status.creationTime;
                    resposta.statusCode = '0';
                    resposta.quantidadePedidos = retorno.objects.size();
                    resposta.type = objeto.consignments[0].type;

                    resposta.consigmentCodesNames = new List<ConsultarPedidosClienteTO.mapConsigmentCodeName>();
                    for(ConsultarPedidosClienteTO.Consignments objConsigments: objeto.consignments) {
                        ConsultarPedidosClienteTO.mapConsigmentCodeName newConsigmentName = new ConsultarPedidosClienteTO.mapConsigmentCodeName();
                        newConsigmentName.consigmentCode = objConsigments.consignmentCode;
                        newConsigmentName.name = objConsigments.items[0].name;
                        newConsigmentName.estimateDate = objConsigments.delivery.estimateDate;
                        newConsigmentName.status = objConsigments.status.status;
                        resposta.consigmentCodesNames.add(newConsigmentName);
                    }
                    return resposta;
                }  
            }
        }

        resposta.quantidadePedidos = retorno.objects.size();

        resposta.statusCode = '1';
        return resposta;
    }
}