public class EnvioFaturaHelper {
    @invocableMethod(label='Envio de Faturas por Email')
    public static List<Boolean> EnvioFaturaPorEmail(List<InputEnvioFaturaPorEmail> inputs){
        List<Boolean> retorno = new List<Boolean>();

        for (InputEnvioFaturaPorEmail item: inputs) {
            retorno.add(IntegracoesFaturas.EnvioFaturaPorEmail(item.numeroConta, item.idEmpresa, item.cpf, item.mesRefFatura, item.emailParaEnvio, String.valueOf(item.idFatura), item.canal));
        }

        return retorno;
    }


    public class InputEnvioFaturaPorEmail{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String mesRefFatura;
        @InvocableVariable(required = true)
        public String emailParaEnvio;
        @InvocableVariable(required = true)
        public Integer idFatura;
        @InvocableVariable(required = true)
        public String canal;
    }
}