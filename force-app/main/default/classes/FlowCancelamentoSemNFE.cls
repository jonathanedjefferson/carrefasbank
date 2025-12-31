public with sharing class FlowCancelamentoSemNFE {
    @InvocableMethod(label='TDCA: Cancelamento Sem NFE')
    public static List<CancelamentoSemNFEWrapper> cancelamentoSemNFE(List<Input> lstInput) {
        CancelamentoSemNFEWrapper retorno = new CancelamentoSemNFEWrapper();
        for (Input item: lstInput) {
            retorno = TDCAManager.cancelamentoSemNFE(item.brand, item.orderNumber);
            break;
        }

        if (retorno != null) {
            return new List<CancelamentoSemNFEWrapper>{retorno};
        }
        return null;
    }

    public class Input{        
        @InvocableVariable (required=true) public String brand;
        @InvocableVariable (required=true) public String orderNumber;
    }
}