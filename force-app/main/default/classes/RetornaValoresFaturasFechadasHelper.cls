public class RetornaValoresFaturasFechadasHelper {
    @invocableMethod(label='Retorna Valores Escolhidos - Faturas Fechadas')
    public static List<OutputValores> RetornaValores(List<InputValores> inputs){
        List<OutputValores> listRetorno = new List<OutputValores>();
        OutputValores objRetorno = new OutputValores();
        List<String> listIdFatura = new List<String>();
        List<String> listData = new List<String>();
        List<String> listdataFormatado = new List<String>();
        

        for (InputValores item: inputs) {
            listIdFatura.addAll(item.StringListIdFatura.split(','));
            listData.addAll(item.StringListData.split(','));
            listdataFormatado.addAll(item.StringListDataFormatado.split(','));
            
            if (item.codigoBarras == '2') {

                Integer cont = 0;
                for (String itemString: listdataFormatado) {
                    if (itemString.equals(item.dataFormatadaEscolhida)) {
                        objRetorno.idFatura = Integer.valueOf(listIdFatura[cont]);
                        objRetorno.data = listData[cont];
                        objRetorno.dataFormatado = listdataFormatado[cont];
                        objRetorno.posicaoEscolhida = cont;

                        listRetorno.add(objRetorno);
                        return listRetorno;
                    }
                    cont++;
                }
            }else if (item.codigoBarras == '1') {
                objRetorno.idFatura = Integer.valueOf(listIdFatura[1]);
                objRetorno.data = listData[1];
                objRetorno.dataFormatado = listdataFormatado[1];
                objRetorno.posicaoEscolhida = 0;
                
                listRetorno.add(objRetorno);
                return listRetorno;
            }
        }
        return listRetorno;
    }

    public class InputValores{
        @InvocableVariable(required = true)
        public String StringListIdFatura;
        @InvocableVariable(required = true)
        public String StringListData;
        @InvocableVariable(required = true)
        public String StringListDataFormatado;
        @InvocableVariable(required = true)
        public String dataFormatadaEscolhida;
        @InvocableVariable(required = true)
        public String codigoBarras;
    }

    public class OutputValores{
        @InvocableVariable
        public Integer idFatura;
        @InvocableVariable
        public String data;
        @InvocableVariable
        public String dataFormatado;
        @InvocableVariable
        public Integer posicaoEscolhida;
    }
}