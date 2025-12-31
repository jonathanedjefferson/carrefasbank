public class BoletoAvulsoHelper {

    @invocableMethod(label='Gerar Boleto Avulso')
    public static List<OutputGerarBoleto> gerarBoletoAvulso(List<InputGerarBoleto> inputs){
        List<OutputGerarBoleto> outputList = new List<OutputGerarBoleto>();

        Decimal valorBoleto = Decimal.valueOf(inputs[0].valorBoleto);
        
        BoletoAvulso.OutputGerarBoleto retornoAPI =  BoletoAvulsoController.gerarBoletoAvulso(inputs[0].numeroConta, inputs[0].cpf, inputs[0].unidade, inputs[0].canal, inputs[0].email, valorBoleto, inputs[0].tipoBoleto, inputs[0].sistema, inputs[0].area, inputs[0].loginOperador);
        
        // Estruturar output
        OutputGerarBoleto output = new OutputGerarBoleto();
        output.statusAPI = retornoAPI.statusAPI;
        if(retornoAPI.statusAPI == 'OK'){
            output.codigoBarras = retornoAPI.codigoBarras;
            Date dataVencimento = Date.valueOf(retornoAPI.dataVencimentoBoleto);
            String dataVencimentoFormata = Util.formatarData(dataVencimento);
            output.dataVencimentoBoleto = dataVencimentoFormata;
            output.linhaDigitavel = retornoAPI.linhaDigitavel;
        }

        outputList.add(output);

        return outputList; 
    }

    public class InputGerarBoleto{
        @InvocableVariable(label='Conta financeira' required = true)
        public String numeroConta;
        @InvocableVariable(label='CPF' required = true)
        public String cpf;
        @InvocableVariable(label='Unidade de negocio' required = true)
        public String unidade;
        @InvocableVariable(label='Canal de atendimento' required = true)
        public String canal;
        @InvocableVariable(label='Email' required = false)
        public String email;
        @InvocableVariable(label='Valor boleto' required = true)
        public String valorBoleto;
        @InvocableVariable(label='Tipo boleto' required = true)
        public Integer tipoBoleto;
        @InvocableVariable(label='Sistema' required = true)
        public String sistema;
        @InvocableVariable(label='Area' required = true)
        public String area;
        @InvocableVariable(label='Login operador' required = true)
        public String loginOperador;
    }

    public class OutputGerarBoleto{
        @InvocableVariable (label='Status da API')
        public String statusAPI;
        @InvocableVariable (label='Codigo de barras')
        public String codigoBarras;
        @InvocableVariable (label='Data de vencimento')
        public String dataVencimentoBoleto;
        @InvocableVariable (label='Linha digitavel')
        public String linhaDigitavel;
    }
}