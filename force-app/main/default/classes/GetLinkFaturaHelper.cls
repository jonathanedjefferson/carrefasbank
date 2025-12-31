public class GetLinkFaturaHelper {
    @invocableMethod(label='Get Link da Fatura')
    public static List<IntegracoesFaturas.OutputGetLinkFatura> GetLinkFatura(List<Input> inputs) {
        List<IntegracoesFaturas.OutputGetLinkFatura> listRetorno = new List<IntegracoesFaturas.OutputGetLinkFatura>();

        for (Input item: inputs) {
            IntegracoesFaturas.OutputGetLinkFatura retorno = IntegracoesFaturas.GetLinkFatura(item.numeroConta, item.idEmpresa, item.cpf, item.mesRefFatura, item.canal);
            listRetorno.add(retorno);
            break;
        }

        return listRetorno;
    }

    public class Input {
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String mesRefFatura;
        @InvocableVariable(required = true)
        public String canal;
    }
}