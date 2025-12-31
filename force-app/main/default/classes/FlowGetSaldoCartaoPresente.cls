public class FlowGetSaldoCartaoPresente {
    @InvocableMethod(label='TDCA: Consultar Saldo Cartão Presente')
    public static List<Output> getSaldo(List<Input> inputs){
        Output retorno = new Output();
        for (Input item: inputs) {
            SaldoCartaoPresenteWrapper retornoAPI = TDCAManager.getSaldoCartaoPresente(item.brand, item.numeroCartao, item.senha);
            
            if (retornoAPI.success != null) {
                retorno.balance         = retornoAPI.success.balance        != null ? retornoAPI.success.balance       : null;
                retorno.id              = retornoAPI.success.id             != null ? retornoAPI.success.id            : '';
                retorno.emissionDate    = retornoAPI.success.emissionDate   != null ? retornoAPI.success.emissionDate  : '';
                retorno.expiringDate    = retornoAPI.success.expiringDate   != null ? retornoAPI.success.expiringDate  : '';
                retorno.statusMessage   = 'Success';
            }else {
                retorno.statusMessage   = retornoAPI.error.message;
            }
            
            break;
        }

        return new List<Output>{retorno};
    }

    public class Input {
        @InvocableVariable(required=true)
        public String brand;
        @InvocableVariable(required=true)
        public String numeroCartao;
        @InvocableVariable(required=true)
        public String senha;
    }

    public class Output {
        @InvocableVariable 
        public Double balance;
        @InvocableVariable 
        public String id;
        @InvocableVariable 
        public String emissionDate;
        @InvocableVariable 
        public String expiringDate;
        @InvocableVariable 
        public String statusMessage;
    }
}