public class ReimpressaoSenhaHelper {
    @invocableMethod(label='2º Via de Senha')
    public static List<String> ReimprimirSenha(List<input> listinput){
        List<String> listRetorno = new List<String>();
        for (input item: listinput) {
            List<String> listCartaoSerno = item.CartaoSerno.split(',');
            List<String> listCartaoOfuscado = item.CartaoOfuscado.split(',');
            Integer cont = 0;

            for (String itemCartao: listCartaoOfuscado) {
                if (itemCartao.EndsWith(item.CartaoEscolhido.split(' - ')[1])) {
                    listRetorno.add(ReimpressaoSenha.ReimprimirSenha(item.numeroConta, listCartaoSerno[cont], item.idEmpresa, item.cpf, item.canal, item.area, item.sistema));
                }
                cont++;
            }
        }

        return listRetorno;
    }   

    public class input{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String canal;
        @InvocableVariable(required = true)
        public String area;
        @InvocableVariable(required = true)
        public String sistema;
        @InvocableVariable(required = true)
        public String CartaoSerno;
        @InvocableVariable(required = true)
        public String CartaoOfuscado;
        @InvocableVariable(required = true)
        public String CartaoEscolhido;
    }
}