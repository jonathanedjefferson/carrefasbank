public with sharing class ProtocoloAtendimentoHelper {
    @invocableMethod(label='Consulta de Protocolo de Atendimento')
    public static List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> ProtocoloAtendimento(List<InputConsultaProtocolo> inputs) {
        ProtocoloAtendimento.ConsultaAPI objConsultaAPI = new ProtocoloAtendimento.ConsultaAPI();

        List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo> lstOutputConsultaProtocolo = new List<ProtocoloAtendimentoHelper.OutputConsultaProtocolo>();
        ProtocoloAtendimentoHelper.OutputConsultaProtocolo objOutputConsultaProtocolo = new ProtocoloAtendimentoHelper.OutputConsultaProtocolo();

        objConsultaAPI = ProtocoloAtendimento.ProtocoloAtendimento(inputs[0].cpf, inputs[0].unidadeNegocio, inputs[0].canal);
        if(objConsultaAPI.descricao != 'ERRO'){
            if(objConsultaAPI.exchange != null){
                for (ProtocoloAtendimento.Protocolos item : objConsultaAPI.exchange.protocolos) {
                    if (item.IndicadorOuvidoria == 'true'){
                        objOutputConsultaProtocolo.possuiProtocolo = 'Sim';
                        break;
                    }else{
                        objOutputConsultaProtocolo.possuiProtocolo = 'Nao';
                    }
                }
            }else{
                objOutputConsultaProtocolo.possuiProtocolo = 'Nao';
            }
        }else{
            objOutputConsultaProtocolo.possuiProtocolo = 'Erro';
        }
        

        lstOutputConsultaProtocolo.add(objOutputConsultaProtocolo);

        return lstOutputConsultaProtocolo;
    }

    public class InputConsultaProtocolo{
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String unidadeNegocio;
        @InvocableVariable(required = true)
        public String canal;

    }

    public class OutputConsultaProtocolo {
        @InvocableVariable
        public String possuiProtocolo;
    }
}