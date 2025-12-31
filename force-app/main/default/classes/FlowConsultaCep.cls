public with sharing class FlowConsultaCep {
    @invocableMethod(label='Consultar Cep')
    public static List<Output> consultarCep(List<Input> inputs){
        List<Output> outputs = new List<Output>();
        for (Input input : inputs) {
            ConsultarCepService.ResponseCep response = ConsultarCepService.execute(input.cep);
            outputs.add(new Output(response.success,response.payload.uf,response.payload.cidade,response.payload.bairro,response.payload.logradouro));
        }
        return outputs;
    }

    public class Input{
        @InvocableVariable(label='Cep' required=true)
        public String cep;

    }

    public class Output{
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String estado;
        @InvocableVariable
        public String cidade;
        @InvocableVariable
        public String bairro;
        @InvocableVariable
        public String logradouro;

        public Output(Boolean success, String estado, String cidade, String bairro, String logradouro) {
            this.success = success;
            this.estado = estado;
            this.cidade = cidade;
            this.bairro = bairro;
            this.logradouro = logradouro;
        }

    }
}