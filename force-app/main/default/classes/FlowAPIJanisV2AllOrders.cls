public with sharing class FlowAPIJanisV2AllOrders {
    @InvocableMethod(label='APIJanis V2 All Orders')
    public static List<Output> chamarAPI(List<Input> lstEntrada) {
        List<Output> listaOutputs = new List<Output>();
        for(Input item: lstEntrada) {
            if(item.orderCode != null) {
                item.orderCode = item.orderCode.replace('#', '');
            }
            List<APIJanisV2TO.Retorno> resultados = APIJanisV2TOAllOrders.makeAPIRequest(item.orderCode, item.email);
            List<RetornoJanisWrapper> retornos = new List<RetornoJanisWrapper>();

            for (APIJanisV2TO.Retorno resultado : resultados) {
                RetornoJanisWrapper retorno = new RetornoJanisWrapper();
                retorno.type = resultado.type;
                retorno.status = resultado.status;
                retorno.estimateDate = resultado.estimateDate;
                retorno.modality = resultado.modality;
                retorno.orderCode = resultado.orderCode;
                retorno.orderDate = resultado.orderDate;
                retorno.statusCode = resultado.statusCode;
                retorno.orderFound = resultado.orderFound;
                retorno.howManyOrders = resultado.howManyOrders;
                retorno.carrierName = resultado.carrierName;
                retornos.add(retorno);
            }
            Output novoOutput = new Output();
            novoOutput.lstRetornos = retornos;
            listaOutputs.add(novoOutput);
        }
        System.debug('listaOutputs:: ' + listaOutputs);
        return listaOutputs;
    }

    public class Input {
        @InvocableVariable(label='orderCode' required=false)
        public String orderCode;
        @InvocableVariable(label='email' required=true)
        public String email;

    }

    public class Output{
        @InvocableVariable(label='lisOrders' required=false)
        public List<RetornoJanisWrapper> lstRetornos;
    }

    
}