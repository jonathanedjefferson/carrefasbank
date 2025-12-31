public class FlowAbrirIncidente {
    
    @InvocableMethod(label='API para abertura de novos incidentes')
    public static List<Output> callAPI(List<Input> lstInputs) {
        List<Output> outp = new List<Output>();
        for (Input inLst: lstInputs){
            sendIncidentTdcaTO.response response =  TDCAManager.sendIncidenteTdca(inLst.orderId, inLst.consignmentId, inLst.orderLineId, inLst.contactReason, inLst.brand);
            
            Output outpt = new Output();
            outpt.status = response.status;
            outpt.message =  response.message;
            outp.add(outpt);   
        } 
        return outp;
    }
    public class Input {
        @InvocableVariable
        public String orderId;
        
        @InvocableVariable
        public String consignmentId;
        
        @InvocableVariable
        public String orderLineId;
        
        @InvocableVariable
        public String contactReason;
        
		@InvocableVariable
        public String brand;

    }
    
    public class Output {
        @AuraEnabled @InvocableVariable
        public Integer status;
        
        @AuraEnabled @InvocableVariable
        public String message;
        
    }

}