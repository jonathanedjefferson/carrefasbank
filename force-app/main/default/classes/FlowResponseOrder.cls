global class FlowResponseOrder {
        @AuraEnabled @InvocableVariable
        public String type;
        @AuraEnabled @InvocableVariable
        public String status;
        @AuraEnabled @InvocableVariable
        public String creationTime;
        @AuraEnabled @InvocableVariable
        public String estimateDate;
        @AuraEnabled @InvocableVariable
        public String modality;
        @AuraEnabled @InvocableVariable
        public String sellersName;
        @AuraEnabled @InvocableVariable
        public String orderCode;
        @AuraEnabled @InvocableVariable
        public String orderDate;
        @AuraEnabled @InvocableVariable
        public String items;
}