public with sharing class CancelamentoComNFEWrapper {

    // ############################ BODY REQUEST ############################
    public class BodyRequestCancelamentoComNFE{
        public BodyRequestCancelamentoComNFE(){
            this.refund = new cls_refund();
        }

        public String protocolId;
        public String protocol;
        public String orderId;
        public String deliveryId;
        public String orderStatus;
        public String brand;
        public cls_refund refund;
    }
    public class cls_refund{
        public String methodBy;             // CC = CREDITO EM CONTA  ||  OP = ORDERM DE PAGAMENTO
        public String document;
        public String fullName;
        public String bankCode;             // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
        public String bankBranchCode;       // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
        public String bankAccountNumber;    // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
    }



    // ############################ RESPONSE ############################
    public class ResponseCancelamentoComNFE{
        public ResponseCancelamentoComNFE(){
            this.events = new List<cls_events>();
        }

        @InvocableVariable public String id;	
        @InvocableVariable public String protocolId;	
        @InvocableVariable public String protocol;	
        @InvocableVariable public String brand;	
        @InvocableVariable public String orderId;	
        @InvocableVariable public String createdAt;
        @InvocableVariable public String updatedAt;
        @InvocableVariable public list<cls_events> events;
        @InvocableVariable public boolean cancellationFinalized;
    }
    public class cls_events {
        @InvocableVariable public String originSystem;
        @InvocableVariable public String eventDescription;	
        @InvocableVariable public String status;	
        @InvocableVariable public String createdAt;
    }
}