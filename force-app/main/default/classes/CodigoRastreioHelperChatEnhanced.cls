public with sharing class CodigoRastreioHelperChatEnhanced {
    @invocableMethod(label='Get Código de Rastreio Chat Enhanced')
    public static List<Output> getCodigoRastreio(List<Input> listInputs) {
        String canal = '';
        ReemissaoCartao.OutputStatusReemissaoRastreio response = new ReemissaoCartao.OutputStatusReemissaoRastreio();
        Output retorno = new Output();

        for (Input item: listInputs) {
            response = ReemissaoCartao.ListRastreioCartaoReemitido(item.canal, item.area, item.cpf , item.idEmpresa, item.numeroConta);
            retorno.StatusAPI = response.StatusAPI;
            canal = item.canal;
            break;
        }
        
        if (retorno.StatusAPI.equalsIgnoreCase('OK')) {
            Integer contCodigo = 0;
            for (ReemissaoCartao.PostagemResponse item: response.postagemResponse) {
                if (item.codigoRastreio != '' && item.codigoRastreio != null) {
                    String option = item.nomeTitular.containsIgnoreCase('Titular') ? 'Titular ' + item.nomeTitular.split(' - ')[0] : 'Adicional ' + item.nomeTitular.split(' - ')[0];
                    String urlRastreio = item.urlRastreio.replace('http://', 'https://');

                    retorno.ListCartoesOptions.add(option);
                    retorno.ListStringAllCartoes += item.codigoRastreio + ' Cartão ' + item.nomeTitular + '\n' + urlRastreio + '<br>';
                }
                
                contCodigo = (item.codigoRastreio == '' || item.codigoRastreio == null) ? contCodigo + 1 : contCodigo;
            }
            retorno.RetornouCartoes = response.PostagemResponse.size() == 0 ? 'NAO' : 'SIM';
            retorno.TemCodigoRastreio = (contCodigo == response.PostagemResponse.size() || response.PostagemResponse.size() == 0) ? 'NAO' : 'SIM'; 
        }

        return new List<Output> {retorno};
    }

    public class Input {
        @InvocableVariable(required = true)
        public String canal; 
        @InvocableVariable(required = true)
        public String area; 
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String idEmpresa; 
        @InvocableVariable(required = true)
        public String numeroConta;
    }
    
    public class Output {
        @InvocableVariable
        public String StatusAPI;
        @InvocableVariable
        public String ListStringAllCartoes;
        @InvocableVariable
        public List<String> ListCartoesOptions;
        @InvocableVariable
        public String TemCodigoRastreio;
        @InvocableVariable
        public String RetornouCartoes;

        Output(){
            this.ListStringAllCartoes = '';
            this.ListCartoesOptions = new List<String>();
        }
    }
}