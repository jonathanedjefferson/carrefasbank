public class FlowCancelamentoComNFE {
    @InvocableMethod(label='TDCA: Cancelamento com NFE')
    public static List<CancelamentoComNFEWrapper.ResponseCancelamentoComNFE> solicitarCancelamentoComNFE(List<Input> lstInput) {
        CancelamentoComNFEWrapper.ResponseCancelamentoComNFE retorno = new CancelamentoComNFEWrapper.ResponseCancelamentoComNFE();
        for (Input item: lstInput) {
            CancelamentoComNFEWrapper.BodyRequestCancelamentoComNFE bodyRequest = new CancelamentoComNFEWrapper.BodyRequestCancelamentoComNFE();
            bodyRequest.protocolId                  = item.caseId               != null ? item.caseId               : '';
            bodyRequest.protocol                    = item.caseNumber           != null ? item.caseNumber           : '';
            bodyRequest.orderId                     = item.orderId              != null ? item.orderId              : '';
            bodyRequest.deliveryId                  = item.deliveryId           != null ? item.deliveryId           : '';
            bodyRequest.orderStatus                 = item.orderStatus          != null ? item.orderStatus          : '';
            bodyRequest.brand                       = item.brand                != null ? item.brand                : '';
            bodyRequest.refund.methodBy             = item.methodBy             != null ? item.methodBy             : '';
            bodyRequest.refund.document             = item.document             != null ? item.document             : '';
            bodyRequest.refund.fullName             = item.fullName             != null ? item.fullName             : '';
            bodyRequest.refund.bankCode             = item.bankCode             != null ? item.bankCode             : '';
            bodyRequest.refund.bankBranchCode       = item.bankBranchCode       != null ? item.bankBranchCode       : '';
            bodyRequest.refund.bankAccountNumber    = item.bankAccountNumber    != null ? item.bankAccountNumber    : '';

            retorno = TDCAManager.solicitarCancelamentoComNFE(item.canal, bodyRequest);
            break;
        }

        if (retorno != null) {
            return new List<CancelamentoComNFEWrapper.ResponseCancelamentoComNFE>{retorno};
        }
        return null;
    }

    public class Input{        
        @InvocableVariable (required=true) public String canal;
        @InvocableVariable (required=true) public String caseId;
        @InvocableVariable (required=true) public String caseNumber;
        @InvocableVariable (required=true) public String orderId;
        @InvocableVariable (required=true) public String deliveryId;
        @InvocableVariable (required=true) public String orderStatus;
        @InvocableVariable (required=true) public String brand;
        @InvocableVariable (required=true) public String methodBy;              // CC = CREDITO EM CONTA  ||  OP = ORDERM DE PAGAMENTO
        @InvocableVariable (required=true) public String document;
        @InvocableVariable (required=true) public String fullName;
        @InvocableVariable public String bankCode;                              // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
        @InvocableVariable public String bankBranchCode;                        // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
        @InvocableVariable public String bankAccountNumber;                     // SÓ É NECESSARIO SE FOR CREDITO EM CONTA
    }
}