public with sharing class InterfaceConsultaProtocolos {
    
    @InvocableMethod 
    public static List<ResponseConsultaProtocolos> InterfaceConsultaProtocolos(List<RequestConsultaProtocolos> parametersRequest) {

        List<ResponseConsultaProtocolos> toReturn = new List<ResponseConsultaProtocolos>();
        ResponseConsultaProtocolos response = new ResponseConsultaProtocolos();
        response.statusRetorno = 'ERRO';

        for(RequestConsultaProtocolos request: parametersRequest){
            ContaFinanceira__c conta = ContaFinanceiraDAO.getInstance().getContaFinanceiraByNumeroConta(request.numeroConta);
            String contaFinanceiraId = conta?.Id;

            List<String> origens = request.origens?.split(',');
            List<String> status = request.status?.split(',');
            List<String> tipos = request.tipos?.split(',');
            Integer quantidade = Integer.valueOf(request.quantidade);
            Integer offset = Integer.valueOf(request.offset);
            
            List<Case> protocolosConta = CasoDAO.getInstance().getCasesLast30Days(origens, status, tipos, contaFinanceiraId, quantidade, offset);
            
            List<String> listaProtocolos = new List<String>();
            String listaIdsProtocolos = ';';
            String dataFormatada = '';
            Integer index = 0;
            for(Case caso : protocolosConta){
                if(index < quantidade - 1){
                    dataFormatada = caso.CreatedDate?.format('dd/MM');
                    listaProtocolos.add(caso.CaseNumber + ' - ' + dataFormatada);
                    listaIdsProtocolos += ';' + caso.Id;
                } else {
                    listaProtocolos.add('Mais antigos');
                }
                index++;
            }

            // Inclui opções na segunda consulta de protocolos
            if(index > 0 && offset > 0){
                listaProtocolos.add('Mais recentes');
                listaProtocolos.add('Outro protocolo');
            }

            response.statusRetorno = 'OK';
            response.numeroProcotolos = protocolosConta?.size();
            response.idsProtocolos = listaIdsProtocolos.replace(';;', '');
            response.listaProtocolos = listaProtocolos;
        }

        toReturn.add(response);
        return toReturn;
    }

    public class RequestConsultaProtocolos {
        @InvocableVariable(label='Número Conta' required=true)
        public String numeroConta;
        @InvocableVariable(label='Origens' required=true)
        public String origens;
        @InvocableVariable(label='Status' required=true)
        public String status;
        @InvocableVariable(label='Tipos' required=true)
        public String tipos;
        @InvocableVariable(label='Quantidade' required=true)
        public String quantidade;
        @InvocableVariable(label='Offset' required=true)
        public String offset;
    }
    
    public class ResponseConsultaProtocolos {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Número de protocolos')
        public Integer numeroProcotolos;
        @InvocableVariable(label='Ids Protocolos')
        public String idsProtocolos;
        @InvocableVariable
        public List<String> listaProtocolos;
    }
}