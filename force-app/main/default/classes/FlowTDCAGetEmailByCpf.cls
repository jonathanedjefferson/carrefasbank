public with sharing class FlowTDCAGetEmailByCpf {
    @InvocableMethod(label='Get email by CPF TDCA')
    public static List<Output> getOrdersByCpf(List<Input> inputs){
        List<Output> outputs = new List<Output>();
        for (Input input : inputs) {
            Output output;
            GetOrdersByCPFResponseWrapper response = TDCAManager.getOrdersByCPF(input.cpf, input.brand);
            if (response.content.size() > 0 && response.content[0].order != null && String.isNotBlank(response.content[0].order.customer.email)) {
                output = new output(response.content[0].order.customer.email,'success');
            }else {
                output = new output('','Email não encontrado');
            }
            outputs.add(output);
        }
 
        return outputs;
    }

    public class Input{
        @InvocableVariable(label='cpf' required=true)
        public String cpf;
        @InvocableVariable(label='brand' required= true)
        public String brand;
    }

    public class Output{
        @InvocableVariable(label='Email')
        public String email;

        @InvocableVariable(label='Status')
        public String status;
        
        public Output(String email, String status){
            this.email = email;
            this.status = status;
        }
    }
}