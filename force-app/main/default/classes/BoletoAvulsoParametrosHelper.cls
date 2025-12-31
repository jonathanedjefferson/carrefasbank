public class BoletoAvulsoParametrosHelper {

    @invocableMethod(label='Obter Parametros Iniciais')
    public static List<OutputParametrosIniciais> obterParametrosIniciais(List<InputParametrosIniciais> inputs){
        List<OutputParametrosIniciais> outputList = new List<OutputParametrosIniciais>();
        
        BoletoAvulso.OutputParametrosIniciais retornoAPI =  BoletoAvulsoController.obterParametrosIniciais(inputs[0].numeroConta, inputs[0].cpf, inputs[0].unidade, inputs[0].canal, inputs[0].sistema, inputs[0].area, inputs[0].loginOperador);
        
        // Estruturar output
        OutputParametrosIniciais output = new OutputParametrosIniciais();
        output.statusAPI = retornoAPI.statusAPI;       
        if(retornoAPI.statusAPI == 'OK'){
            output.valorMinimo = retornoAPI.valorMinimo != null ? String.valueOf(retornoAPI.valorMinimo.setScale(2)) : null;
            output.valorMaximo = retornoAPI.valorMaximo != null ? String.valueOf(retornoAPI.valorMaximo.setScale(2)) : null;
            output.saldoDevedorInsuficiente =  retornoAPI.saldoDevedorInsuficiente;
            output.possuiBoletoEmitido = false;

            Datetime dataEmissaoUltimoBoletoValido;

            if(retornoAPI.boletosValidos != null){
                for(BoletoAvulso.BoletoValido boleto : retornoAPI.boletosValidos){
                    Datetime dt = Datetime.valueOf(boleto.dataEmissao.split('\\.')[0].replace('T', ' '));
                    if(dt >= dataEmissaoUltimoBoletoValido || dataEmissaoUltimoBoletoValido == null){
                        output.possuiBoletoEmitido = true;
                        output.idUltimoBoletoEitido = String.valueOf(boleto.id);
                        output.codigoBarrasUltimoBoleto = boleto.codigoBarras;
                        output.linhaDigitavelUltimoBoleto = boleto.linhaDigitavel;
                        output.valorUltimoBoleto = String.valueOf(boleto.valorBoleto.setScale(2));
                        output.dataVencimentoUltimoBoleto = Datetime.valueOf(boleto.dataVencimento.split('\\.')[0].replace('T', ' ')).format('dd/MM/yyyy');
                        dataEmissaoUltimoBoletoValido = Datetime.valueOf(boleto.dataEmissao.split('\\.')[0].replace('T', ' '));
                    }
                }
            }
            
        }
        outputList.add(output);

        return outputList; 
    }

    public class InputParametrosIniciais{
        @InvocableVariable(label='Conta financeira' required = true)
        public String numeroConta;
        @InvocableVariable(label='CPF' required = true)
        public String cpf;
        @InvocableVariable(label='Unidade de negocio' required = true)
        public String unidade;
        @InvocableVariable(label='Canal de atendimento' required = true)
        public String canal;
        @InvocableVariable(label='Sistema' required = true)
        public String sistema;
        @InvocableVariable(label='Area' required = true)
        public String area;
        @InvocableVariable(label='Login operador' required = true)
        public String loginOperador;
        
    }

    public class OutputParametrosIniciais{
        @InvocableVariable (label='Status da API')
        public String statusAPI;
        @InvocableVariable (label='Valor minimo')
        public String valorMinimo;
        @InvocableVariable (label='Valor maximo')
        public String valorMaximo;
        @InvocableVariable (label='Saldo deve insuficiente para gerar boleto')
        public Boolean saldoDevedorInsuficiente;
        @InvocableVariable (label='Boleto valido ja emitido')
        public Boolean possuiBoletoEmitido;
        @InvocableVariable (label='Id boleto valido')
        public String idUltimoBoletoEitido;
        @InvocableVariable (label='Codigo barras boleto valido')
        public String codigoBarrasUltimoBoleto;
        @InvocableVariable (label='Linha digitavel boleto valido')
        public String linhaDigitavelUltimoBoleto;
        @InvocableVariable (label='Data vencimento boleto valido') 
        public String dataVencimentoUltimoBoleto;
        @InvocableVariable (label='Valor boleto valido')
        public String valorUltimoBoleto;
    }
}