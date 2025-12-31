public with sharing class CancelarSegurosHelper {
    @invocableMethod(label='Cancelar Seguros')
    public static List<OutputCancelarSeguros> CancelamentoSeguros(List<InputCancelamentoSeguros> inputs){
        List<OutputCancelarSeguros> retornos = new  List<OutputCancelarSeguros>();
        OutputCancelarSeguros retorno = new  OutputCancelarSeguros();
        List<IntegracaoSeguros.OutputCancelarSeguros> response = new  List<IntegracaoSeguros.OutputCancelarSeguros>();
        

        for (InputCancelamentoSeguros item: inputs) {
            IntegracaoSeguros.InputCancelamento contrato = new IntegracaoSeguros.InputCancelamento();
            contrato.idAdesao = item.idAdesao;
            contrato.nomeAdesao = item.nomeAdesao;
            contrato.dataCancelamento = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            contrato.codMotivoCancelamento = item.codMotivoCancelamento;
            contrato.codigoCanalCancelamento = item.codigoCanalCancelamento;
            contrato.nomeCanalCancelamento = item.nomeCanalCancelamento;
            contrato.codigoUsuarioCancelamento = item.codigoUsuarioCancelamento;
            contrato.nomeUsuarioCancelamento = item.nomeUsuarioCancelamento;
            contrato.comentarioCancelamento = item.comentarioCancelamento;
            contrato.cpf = item.cpf;
            contrato.unidadeNegocio = item.unidadeNegocio;
            contrato.canal = item.canal;
            response.add(IntegracaoSeguros.cancelamentoSeguro(contrato));
        }
        retorno.messageId = response[0].messageId;
        retorno.statusResponse = response[0].statusResponse;
        retornos.add(retorno);
        return retornos;
    }

     //input e output Cancelar seguro
    public class InputCancelamentoSeguros {
        @InvocableVariable(required = true)
        public String idAdesao;
        @InvocableVariable(required = true)
        public String nomeAdesao;
        @InvocableVariable(required = true)
        public String codMotivoCancelamento;
        @InvocableVariable(required = true)
        public String codigoCanalCancelamento;
        @InvocableVariable(required = true)
        public String nomeCanalCancelamento;
        @InvocableVariable(required = true)
        public String codigoUsuarioCancelamento;
        @InvocableVariable(required = true)
        public String nomeUsuarioCancelamento;
        @InvocableVariable(required = true)
        public String comentarioCancelamento;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String unidadeNegocio;
        @InvocableVariable(required = true)
        public String canal;
    }

    public class OutputCancelarSeguros {
        @InvocableVariable 
        public String statusResponse;
        @InvocableVariable  
        public String messageId;
    }

}