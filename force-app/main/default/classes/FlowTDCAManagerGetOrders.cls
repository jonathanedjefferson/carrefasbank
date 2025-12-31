public with sharing class FlowTDCAManagerGetOrders {
    
    @InvocableMethod(label='Get order by cpf')
    public static List<GetOrdersByCPFResponseWrapper> getOrdersByCpf(List<Input> inputs){
        List<GetOrdersByCPFResponseWrapper> outputs = new List<GetOrdersByCPFResponseWrapper>();
        for (Input input : inputs) {

            GetOrdersByCPFResponseWrapper response = TDCAManager.getOrdersByCPF(input.cpf, input.brand);
            outputs.add(response);
        }
 
        return outputs;
    }


    public class Input{
        @InvocableVariable(label='cpf' required=true)
        public String cpf;
        @InvocableVariable(label='brand' required= true)
        public String brand;
    }
}