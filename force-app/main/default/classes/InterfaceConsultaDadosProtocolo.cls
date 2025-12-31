public with sharing class InterfaceConsultaDadosProtocolo {
    
    @InvocableMethod 
    public static List<ResponseConsultaDadosProtocolo> consultaDadosProtocolo(List<RequestConsultaDadosProtocolo> parametersRequest) {

        List<ResponseConsultaDadosProtocolo> toReturn = new List<ResponseConsultaDadosProtocolo>();
        ResponseConsultaDadosProtocolo response = new ResponseConsultaDadosProtocolo();
        response.statusRetorno = 'OK';

        for(RequestConsultaDadosProtocolo request: parametersRequest){

            List<String> protocolos = request.listaProtocolos;
            List<String> idsProtocolos = request.idsProtocolos?.split(';');
            String protocoloSelecionado = request.protocolo;

            Integer index = 0;
            for(String opcaoProtocolo : protocolos){
                if(opcaoProtocolo == protocoloSelecionado){
                    break;
                }
                index++;
            }

            String idProtocolo = idsProtocolos?.get(index);
            Case protocolo = CasoDAO.getInstance().getCase(idProtocolo);

            if(protocolo != null){
                response.statusRetorno = 'OK';
                response.numeroProcotolo = protocolo.CaseNumber;
                response.evento = protocolo.Evento__c;
                response.assunto = protocolo.Assunto__c;
                response.status = protocolo.Status;
                if(response.status == 'New' || response.status == 'Closed'){
                    response.status = 'Concluído';
                }
                response.dataCriacao = protocolo.CreatedDate?.format('dd/MM/yyyy');
                response.dataFechamento = protocolo.ClosedDate?.format('dd/MM/yyyy');
                response.prazoConclusao = protocolo.PrazoConclusao__c?.format('dd/MM/yyyy');
            }
        }

        toReturn.add(response);
        return toReturn;
    }

    public class RequestConsultaDadosProtocolo {
        @InvocableVariable
        public List<String> listaProtocolos;
        @InvocableVariable(label='Ids Protocolos')
        public String idsProtocolos;
        @InvocableVariable(label='Protocolo selecionado')
        public String protocolo;
    }
    
    public class ResponseConsultaDadosProtocolo {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Número Protocolo')
        public String numeroProcotolo;
        @InvocableVariable(label='Evento')
        public String evento;
        @InvocableVariable(label='Assunto')
        public String assunto;
        @InvocableVariable(label='Status')
        public String status;
        @InvocableVariable(label='Data Criação')
        public String dataCriacao;
        @InvocableVariable(label='Data Fechamento')
        public String dataFechamento;
        @InvocableVariable(label='Prazo Conclusão')
        public String prazoConclusao;
    }
}