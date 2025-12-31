public class FlowConsultOrderStatusAPI {
    
    @InvocableMethod(label='API Consulta status pedido' Category='Vtex')
    public static List<List<ConsultaPedidoResponse>> consultaStatusPedidoFlow(List<Input> entrada) {
        
        String cpf = entrada[0].cpf;
        System.debug('CPF'+ cpf);
        
        List<ConsultOrderStatusAPITO.List_Z> responseList = ConsultOrderStatusAPI.makeCalloutApiStatus(cpf);
        System.debug('Response list' + responseList);
        List<ConsultaPedidoResponse> listOutPut = new List<ConsultaPedidoResponse>();
        List<List<ConsultaPedidoResponse>> outputListAdd = new List<List<ConsultaPedidoResponse>>();

        
        for(ConsultOrderStatusAPITO.List_Z obj: responseList){
            ConsultaPedidoResponse output = new ConsultaPedidoResponse();
            output.orderId          = obj.orderId; 
            output.status           = obj.status;
            output.creationDate     = formateDate(obj.creationDate);
            output.isAnyDelivered   = obj.isAnyDelivered;
            output.ShippingEstimatedDateMax = obj.ShippingEstimatedDateMax;
            output.ShippingEstimatedDateMin = obj.ShippingEstimatedDateMin;
            listOutPut.add(output);
        }
        outputListAdd.add(listOutPut);

        System.debug('Return f ' + outputListAdd);
        return outputListAdd;
    }  

    public static Date formateDate(String data){

        List<String> strList = data.split('T').get(0).split('-');
        Date dateFormat = Date.newInstance( Integer.valueOf(strList.get(0)) , Integer.valueOf(strList.get(1)) , Integer.valueOf(strList.get(2)));

        return dateFormat;
    }

    public class Input {
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
    }
}