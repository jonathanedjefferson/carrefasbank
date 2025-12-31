public class BoletoAvulsoEnvioHelper {
 
    @invocableMethod(label='Enviar Boleto Avulso')
    public static List<OutputEnvioBoleto> enviarBoleto(List<InputEnvioBoleto> inputs){
        List<OutputEnvioBoleto> outputList = new List<OutputEnvioBoleto>();

        List<String> idBoletoLst = new List<String>{inputs[0].idBoleto};
        
        BoletoAvulso.OutputEnviarBoleto retornoAPI =  BoletoAvulsoController.enviarBoleto(inputs[0].numeroConta, inputs[0].cpf, inputs[0].unidade, inputs[0].canal, inputs[0].email, idBoletoLst, inputs[0].sistema, inputs[0].area, inputs[0].loginOperador);
        
        // Estruturar output
        OutputEnvioBoleto output = new OutputEnvioBoleto();
        output.statusAPI = retornoAPI.statusAPI;
        outputList.add(output);

        return outputList; 
    }

    public class InputEnvioBoleto{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String unidade;
        @InvocableVariable(required = true)
        public String canal;
        @InvocableVariable(required = false)
        public String email;
        @InvocableVariable(required = true)
        public String idBoleto;
        @InvocableVariable(required = true)
        public String sistema;
        @InvocableVariable(required = true)
        public String area;
        @InvocableVariable(required = true)
        public String loginOperador;
    }

    public class OutputEnvioBoleto{
        @InvocableVariable (label='Status da API')
        public String statusAPI;
    }
}