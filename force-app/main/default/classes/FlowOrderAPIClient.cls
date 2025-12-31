public class FlowOrderAPIClient {
    
    @InvocableMethod(label='API Order pedido 1' Category='API Order')
    public static List<List<FlowResponseOrder>> chamarAPIPedido1P(List<Input> entrada) {
        
        String email = entrada[0].email;
        System.debug('Email'+ email);
        List<FlowResponseOrder> outputList = new List<FlowResponseOrder>();
        List<List<FlowResponseOrder>> outputListAdd = new List<List<FlowResponseOrder>>();

        OrderAPIClientTO.ResponseWrapper response = OrderAPIClient.getResponsePedido1P(email);
        System.debug('return response' + response);
        
        if(response.objects != null){
            for (OrderAPIClientTO.Objects obj : response.objects) {
                if(!obj.consignments.isEmpty()) {
                    FlowResponseOrder output = new FlowResponseOrder();
                    output.type = obj.consignments[0].type;
                    if(obj.consignments[0].status != null) {
                        output.status = obj.consignments[0].status.status;
                        output.creationTime = obj.consignments[0].status.creationTime;
                    }
                    if(obj.consignments[0].delivery != null) {
                        output.estimateDate = obj.consignments[0].delivery.estimateDate;
                        output.modality = obj.consignments[0].delivery.modality;
                    }
                    output.sellersName = obj.sellersName;
                    output.orderCode = obj.orderCode;
                    output.orderDate = obj.orderDate;
                    output.items = getItemNames(obj.consignments[0].items);
                    outputList.add(output);
                }
            }
        }
        outputListAdd.add(outputList);
        System.debug('Return: ' + outputListAdd); 
        return outputListAdd;
    }

    public class Input {
        @InvocableVariable(label='Email' required=true)
        public String email;
    }
    public static String getItemNames(List<OrderAPIClientTO.Item> items) {
        List<String> itemNamesList = new List<String>();
        for (OrderAPIClientTO.Item item : items) {
            itemNamesList.add(item.name);
        }
        return String.join(itemNamesList, ', ');
    } 
}