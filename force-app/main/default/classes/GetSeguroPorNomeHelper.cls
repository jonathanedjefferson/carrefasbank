public without sharing class GetSeguroPorNomeHelper {
    @InvocableMethod(label='Pegar seguro selecionado pelo nome ' description='Procura e retorna um seguro na lista pelo nome')
    public static List<OutputGetSeguroPorNome> getSegurosPorNome(List<InputBuscarSeguro> inputs) {
        List<OutputGetSeguroPorNome> retorno = new List<OutputGetSeguroPorNome>();
        
        for (InputBuscarSeguro input : inputs) {
            if (String.isNotBlank(input.lista)) {
                List<OutputGetSeguroPorNome> listaSeguros = 
                    (List<OutputGetSeguroPorNome>) JSON.deserialize(input.lista, List<OutputGetSeguroPorNome>.class);
                
                for (OutputGetSeguroPorNome seguro : listaSeguros) {
                    if (seguro.nomeProduto == input.nome) {
                        seguro.idAdesao = String.isEmpty(seguro.idAdesaoProseg) ? seguro.idAdesaoPdr : seguro.idAdesaoProseg;
                        seguro.nomeAdesao = String.isEmpty(seguro.idAdesaoProseg) ? 'idAdesaoPdr' : 'idAdesaoProseg';
                        retorno.add(seguro);
                        break; 
                    }
                }
            }
        }
        
        return retorno;
    }

    public class InputBuscarSeguro {
        @InvocableVariable(label='Nome seguro' required=true)
        public String nome;
        @InvocableVariable(label='Lista de Seguros' required=true)
        public String lista;
    }

    public class OutputGetSeguroPorNome {
        @InvocableVariable 
        public String status;
        @InvocableVariable 
        public String nomeProduto;
        @InvocableVariable 
        public String nomePlano;
        @InvocableVariable 
        public Double valor;
        @InvocableVariable 
        public String tipoadesao;
        @InvocableVariable 
        public String dataAdesao;
        @InvocableVariable 
        public String dataInicioVigencia;
        @InvocableVariable 
        public String dataFimVigencia;
        @InvocableVariable 
        public String codCanalAdesao;
        @InvocableVariable 
        public String codLojaAdesao;
        @InvocableVariable 
        public String idAdesao;
        @InvocableVariable 
        public String nomeAdesao;
        public String idAdesaoProseg;
        public String idAdesaoPdr;
    }
}