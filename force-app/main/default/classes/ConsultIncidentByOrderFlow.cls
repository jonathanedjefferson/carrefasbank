public with sharing class ConsultIncidentByOrderFlow {

    public class Request {
        @InvocableVariable(label='ID do Pedido' description='ID do pedido a ser consultado')
        public String orderId;
    }

    public class Result {
        @InvocableVariable public String consignmentCode;
        @InvocableVariable public String createdAt;

        @InvocableVariable public String customerFirstName;
        @InvocableVariable public String customerLastName;
        @InvocableVariable public String customerEmail;
        @InvocableVariable public String customerDocument;

        @InvocableVariable public String incidentStatus;
        @InvocableVariable public String incidentReasonDescription;
        @InvocableVariable public String incidentReasonCode;
        @InvocableVariable public String incidentProductDescription;
        @InvocableVariable public String incidentProductSku;
        @InvocableVariable public String incidentId;
        @InvocableVariable public String incidentCreatedAt;
        @InvocableVariable public String incidentHasRefund;
        @InvocableVariable public String incidentPrice;
        @invocableVariable public String message;        
    }
   
    @InvocableMethod(label='Consultar Incidente por Pedido' description='Consulta dados do incidente via pedido')
    public static List<Result> consultar(List<Request> requests) {
        List<Result> resultados = new List<Result>();

        if (requests == null || requests.isEmpty()) {
            return resultados;
        }

        for (Request req : requests) {
            Result res = new Result();
            try {
                ConsultIncident.Response resposta = TDCAManager.consultIncidentByOrder(req.orderId);
                if(resposta != null) {
                    res.consignmentCode = resposta.consignmentCode;
                    res.createdAt = resposta.createdAt;
                    
                    if (resposta.customer != null) {
                        res.customerFirstName = resposta.customer.firstName;
                        res.customerLastName = resposta.customer.lastName;
                        res.customerEmail = resposta.customer.email;
                        res.customerDocument = resposta.customer.document;
                    }

                    if (resposta.incident != null && !resposta.incident.isEmpty()) {
                        ConsultIncident.Incident inc = resposta.incident[0];
                        res.incidentStatus = inc.status;
                        res.incidentReasonDescription = inc.reasonDescription;
                        res.incidentReasonCode = inc.reasonCode;
                        res.incidentProductDescription = inc.productDescription;
                        res.incidentProductSku = inc.productSku;
                        res.incidentId = inc.id;
                        res.incidentCreatedAt = inc.createdAt;
                        res.incidentHasRefund = String.valueOf(inc.hasRefund);
                        res.incidentPrice = String.valueOf(inc.price);
                        res.message = 'Incidente resgatado com sucesso!';
                    }
                }else{
                    res.incidentReasonDescription = 'Erro API';
                }
            } catch (Exception e) {
                res.message = 'Erro: ' + e.getMessage();
                System.debug('Erro: ' + e.getMessage());
            }
            resultados.add(res);
        }

        System.debug(resultados);
        return resultados;
    }
}