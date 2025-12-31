public class FlowCaseCreation {
    
    @InvocableMethod(label='API para criação de novos casos')
    public static List<Output> callAPI(List<Input> lstInputs) {
        List<Output> outp = new List<Output>();
        for (Input inLst: lstInputs){
            APICaseCreation.CaseResponse response =  APICaseCreation.createCase(inLst.brand, inLst.preferenceContact, inLst.orderNumber, inLst.consignmentCode, inLst.origin, inLst.channel, inLst.typeorder, inLst.subjectReasonContact, inLst.event, inLst.document, inLst.emailClient, inLst.customerName, inLst.telephone, inLst.description, inLst.store);
            System.debug(response);
            System.debug('response');

            If(response != null){
            Output outpt = new Output();
            outpt.id = response.id;
            outpt.success =  response.success;
            outp.add(outpt);        
            } else {
                Output outNull = new Output();
                outNull.success = false;
                outp.add(outNull);
            }
        }
        System.debug('output: ' + outp);
        return outp;
    }
    public class Input {
        @InvocableVariable
        public String preferenceContact;
        
        @InvocableVariable
        public String orderNumber;
        
        @InvocableVariable
        public String consignmentCode;
        
        @InvocableVariable
        public String origin;
        
        @InvocableVariable
        public String channel;
        
        @InvocableVariable
        public String typeorder;
        
        @InvocableVariable
        public String subjectReasonContact;
        
        @InvocableVariable
        public String event;
        
        @InvocableVariable
        public String document;
        
        @InvocableVariable
        public String emailClient;
        
        @InvocableVariable
        public String customerName;
        
        @InvocableVariable
        public String telephone;
        
        @InvocableVariable
        public String description;
        
        @InvocableVariable
        public String brand;

        @InvocableVariable
        public String store;
    }
    
    public class Output {
        @AuraEnabled @InvocableVariable
        public String id;
        
        @AuraEnabled @InvocableVariable
        public Boolean success;
        
    }
}