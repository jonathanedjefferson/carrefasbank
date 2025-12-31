public with sharing class ConsultarSegurosHelper {
    @invocableMethod(label='Consultar Seguros')
    public static List<OutputConsultarSeguros> ConsultarSeguros(List<InputSeguros> inputs){
        OutputConsultarSeguros retorno = new  OutputConsultarSeguros();
        List<OutputConsultarSeguros> retornos = new  List<OutputConsultarSeguros>();
        List<String> listNome = new  List<String>();
        List<IntegracaoSeguros.OutputConsultarSeguros> response = new  List<IntegracaoSeguros.OutputConsultarSeguros>();
        List<IntegracaoSeguros.AdesaoConsultaSeguros> listAdesoes = new  List<IntegracaoSeguros.AdesaoConsultaSeguros>();
        

        for (InputSeguros item: inputs) {
            response.add(IntegracaoSeguros.consultarSeguros(item.idEmpresa, item.cpf, item.canal));
        }

        if (response[0].statusResponse == 'OK') {
            for (IntegracaoSeguros.AdesaoConsultaSeguros item : response[0].adesoes) {
                if (item.status == 'Ativo') {
                    listNome.add(item.nomeProduto);
                    listAdesoes.add(item);
                }
            }
        }
        retorno.adesoes =  JSON.serialize(listAdesoes);
        retorno.seguros = listNome;
        retorno.statusResponse = response[0].statusResponse;
        retornos.add(retorno);
        return retornos;
    }
    
    public class InputSeguros{    
        @InvocableVariable(required = true)
        public String  idEmpresa; 
        @InvocableVariable(required = true)
        public String  cpf;  
        @InvocableVariable(required = true)
        public String canal; 
    }

    //Output Consultar seguros
    public class OutputConsultarSeguros {
        @InvocableVariable
        public String statusResponse;
        @InvocableVariable
        public List<String> seguros;
        @InvocableVariable
        public String adesoes;
    }
}