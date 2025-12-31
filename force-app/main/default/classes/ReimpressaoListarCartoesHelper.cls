public class ReimpressaoListarCartoesHelper {
    @invocableMethod(label='Listar Cartões - 2º Via de Senha')
    public static List<Output> listarCartoes(List<Input> listInput){
        List<ReimpressaoSenha.OutputListarCartoes> listListagem = new List<ReimpressaoSenha.OutputListarCartoes>();
        List<Output> listRetorno = new List<Output>();
        Output retorno = new Output();

        for (Input item: listInput) {
            listListagem.addAll(ReimpressaoSenha.ListarCartoes(item.numeroConta, item.idEmpresa, item.cpf, item.canal, item.area));
        }
        
        if (listListagem.size() > 0) {    
            if (listListagem[0].StatusOK != 'ERROR') {
                for (ReimpressaoSenha.OutputListarCartoes item: listListagem) {
                    retorno.listaCartoes.add(item.nomePortador + ' - ' + item.numeroCartaoOfuscado.split('\\.')[3]);
                    retorno.listCartaoOfuscado += ',' + item.numeroCartaoOfuscado;
                    retorno.listCartaoSerno += ',' + item.numeroCartaoSerno;
                    retorno.StatusOK = item.StatusOK;
                }
                listRetorno.add(retorno);
            }else if(listListagem[0].StatusOK == 'ERROR'){
                retorno.StatusOK = 'ERROR';
                listRetorno.add(retorno);
            }
        }
        return listRetorno;
    }


    public class Input{
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
    }

    public class Output{
        @InvocableVariable
        public List<String> listaCartoes;
        @InvocableVariable
        public String listCartaoSerno;
        @InvocableVariable
        public String listCartaoOfuscado;
        @InvocableVariable
        public String StatusOK;

        public Output(){
            this.listaCartoes = new List<String>();
            this.listCartaoSerno = '';
            this.listCartaoOfuscado = '';
            this.StatusOK = 'ERROR';
        }
    }
}