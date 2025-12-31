public class FlowCancelamentoProdutoWhatsApp{
    
    @InvocableMethod(label='API Order - cancelamento de pedido' Category='API Order')
    public static List<FlowResponseOrder> cancelamentoProdutoWhatsApp(List<Input> entrada) {
        
        String email  = entrada[0].email;
        String pedido = entrada[0].pedido;
        pedido = pedido.replace('#', '');
        if (String.isBlank(email) || String.isBlank(pedido)) {
            return new List<FlowResponseOrder>();
        }

        List<FlowResponseOrder> outputList = new List<FlowResponseOrder>();
        List<OrderAPIClientTO.Objects> objectsList  = OrderAPIClient.makeCalloutApiOrder(email);

        if(objectsList != null){

            Map<String, OrderAPIClientTO.Objects> pedidosMap = new Map<String, OrderAPIClientTO.Objects>();
            for (OrderAPIClientTO.Objects obj : objectsList) {
                if (obj.orderCode == pedido && !pedidosMap.containsKey(pedido)) {
                    pedidosMap.put(obj.orderCode, obj);
                }
            }
            for (OrderAPIClientTO.Objects obj : pedidosMap.values()){
                FlowResponseOrder flowResponseOrder = new FlowResponseOrder();
                flowResponseOrder.orderCode = obj.orderCode;
                flowResponseOrder.orderDate = obj.orderDate;
                flowResponseOrder.sellersName = obj.sellersName;
                flowResponseOrder.type = obj.consignments[0].type;
                flowResponseOrder.status = obj.consignments[0].status.status;
                flowResponseOrder.creationTime = obj.consignments[0].status.creationTime;
                flowResponseOrder.estimateDate = obj.consignments[0].delivery.estimateDate;
                flowResponseOrder.modality = obj.consignments[0].delivery.modality;
                flowResponseOrder.items = FlowOrderAPIClient.getItemNames(obj.consignments[0].items);
                outputList.add(flowResponseOrder);
            }
            return outputList;
        }else{
            return new List<FlowResponseOrder>();
        }
    }
    
    public class Input {
        @InvocableVariable(label='Email'  required=true)
        public String email;
        @InvocableVariable(label='Pedido' required=true)
        public String pedido;
    }
}