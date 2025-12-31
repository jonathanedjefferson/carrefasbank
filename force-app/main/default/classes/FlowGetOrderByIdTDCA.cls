public class FlowGetOrderByIdTDCA {
    @InvocableMethod(label='TDCA: Obter informações do pedido pelo orderId')
    public static List<FlowGetOrderByIdTDCAResponseWrapper> getBankSlipFromFlow(List<Input> lstEntrada) {
        List<FlowGetOrderByIdTDCAResponseWrapper> listaOutputs = new List<FlowGetOrderByIdTDCAResponseWrapper>();
        for (Input item : lstEntrada) {
            FlowGetOrderByIdTDCAResponseWrapper novoOutput = new FlowGetOrderByIdTDCAResponseWrapper();
            if (String.isNotBlank(item.orderId) && String.isNotBlank(item.brand)) {
                try {
                    GetOrderByOrderIdResponseWrapper orderResponse = TDCAManager.getOrdersByOrderId(item.orderId, item.brand);
                    if (orderResponse != null) {
                        if (orderResponse.status.equalsIgnoreCase('pedido invalido')) {
                            novoOutput.status = orderResponse.status;
                        }else{
                            String sellerName = orderResponse.seller.name;
                            sellerName = orderResponse.origin.startsWith('JANIS') ? orderResponse.consignments[0].delivery.deliveryCompany : sellerName;
                            novoOutput.sellerName                       = sellerName;
                            novoOutput.email                            = orderResponse.customer.email;
                            novoOutput.firstName                        = orderResponse.customer.firstName;
                            novoOutput.lastName                         = orderResponse.customer.lastName;
                            novoOutput.modality                         = orderResponse.consignments[0].delivery.modality;
                            novoOutput.getBankSlipAllowed               = orderResponse.actions.getBankSlipAllowed;
                            novoOutput.consignmentsWithInvoiceAllowed   = new List<String>();
                            novoOutput.consignmentsWithInvoiceAllowed   = orderResponse.actions.consignmentsWithInvoiceAllowed;
                            novoOutput.items                            = new List<ItemsOutputTDCA>();
                            novoOutput.consignments                     = orderResponse.consignments;
                            novoOutput.statusPedido                     = orderResponse.status;
                            novoOutput.totalValuePedido                 = String.valueOf(orderResponse.totalValue);

                            for(ConsignmentsWrapper cons : novoOutput.consignments){
                                cons.mostRecentConsignmentStatus        = cons.consignmentStatusHistory[0].status;
                                cons.suspended                          = cons.flags.suspended;
                                cons.deliveryLate                       = cons.flags.deliveryLate;
                                cons.cancelOrderAlloed                  = cons.actions.cancelOrderAllowed;
                                cons.refundOrderAllowed                 = cons.actions.refundOrderAllowed;
                                cons.modality                           = cons.delivery.modality;
                                cons.shippingConcludedTime              = (cons.delivery != null && cons.delivery.shippingConcludedTime != null) ? cons.delivery.shippingConcludedTime  : '';
                                cons.shippingEstimateDate               = (cons.delivery != null && cons.delivery.shippingEstimateDate  != null) ? cons.delivery.shippingEstimateDate   : '';
                                cons.deliveryCompany                    = (cons.delivery != null && cons.delivery.deliveryCompany       != null) ? cons.delivery.deliveryCompany        : '';
                                cons.trackingLink                       = (cons.delivery != null && cons.delivery.trackingLink          != null) ? cons.delivery.trackingLink           : 'Nenhum';
                                for (ItemsOutputTDCA itens : cons.items){
                                    itens.consigmentCode = cons.consignmentCode;
                                }
                                novoOutput.items.addAll(cons.items);
                            }
                            novoOutput.payments                         = orderResponse.payments;
                            novoOutput.deliveryLate                     = orderResponse.flags.deliveryLate;
                            novoOutput.creationDate                     = orderResponse.creationDate;
                            novoOutput.document                         = orderResponse.customer.documentNumber;
                            novoOutput.status                           = 'Success';
                        }
                    } else {
                        novoOutput.status = 'Failed: No response or invalid response';
                    }
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
}