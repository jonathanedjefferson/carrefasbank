public class FlowTDCAManager {
    @InvocableMethod(label='TDCA: Obter boleto: obter boleto pelo orderId')
    public static List<Output> getBankSlipFromFlow(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        
        for (Input item : lstEntrada) {
            Output novoOutput = new Output();
            
            if (String.isNotBlank(item.orderId) && String.isNotBlank(item.brand)) {
                try {
                    GetBankSlipResponseWrapper bankSlipResponse = TDCAManager.getBankSlip(item.orderId, item.brand);
                    novoOutput.bankslipLink = bankSlipResponse.bankslipLink != null ? bankSlipResponse.bankslipLink : 'Vazio';

                    novoOutput.status = bankSlipResponse.message != null ? bankSlipResponse.message : 'Success';
                } catch (Exception e) {
                    novoOutput.status = 'Failed: ' + e.getMessage();
                }
            } else {
                novoOutput.status = 'Failed: Missing orderId or brand';
            }
            
            listaOutputs.add(novoOutput);
        }
        
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='Order ID' required=true)
        public String orderId;
        
        @InvocableVariable(label='Brand' required=true)
        public String brand;
    }

    public class Output {
        @AuraEnabled @InvocableVariable
        public String bankslipLink;

        @AuraEnabled @InvocableVariable
        public String status;
    }
}