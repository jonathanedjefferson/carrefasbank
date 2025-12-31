global class ResponseGetCaseTDCA {

    @InvocableVariable
    public Integer totalSize = 0;
    @InvocableVariable
    public Boolean done = false;
    @InvocableVariable
    public List<CaseRecord> records = new List<CaseRecord>();

    public class CaseRecord {
        @InvocableVariable
        public AttributesJson attributesJson;
        @InvocableVariable
        public String caseNumber;
        @InvocableVariable
        public String orderNumber;
        @InvocableVariable
        public String modality;
        @InvocableVariable
        public String documentNumber;
        @InvocableVariable
        public String typeorder;
        @InvocableVariable
        public String category;
        @InvocableVariable
        public String reason;
        @InvocableVariable
        public String event;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String brand;
        @InvocableVariable
        public String protocolTypeName;
        @InvocableVariable
        public String dateCreation;
        @InvocableVariable
        public String channel;
        @InvocableVariable
        public Boolean isVoiceSlaOnTime;
        @InvocableVariable
        public String consigmentCode;
    }
    
    public class AttributesJson {
        @InvocableVariable
        public String type;
        @InvocableVariable
        public String url;
    }
}