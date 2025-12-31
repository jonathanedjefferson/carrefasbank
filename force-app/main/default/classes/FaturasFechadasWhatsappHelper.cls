public with sharing class FaturasFechadasWhatsappHelper {
    @invocableMethod(label='Ultimos Vencimentos Fechados Whatsapp')
    public static List<FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados> UltimosVencimentosFechados(List<InputVencimentosFechados> inputs){
        List<IntegracoesFaturas.OutputUltimosVencimentosFechados> retorno = new List<IntegracoesFaturas.OutputUltimosVencimentosFechados>();

        List<FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados> retornoFinal = new List<FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados>();
        FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados objFinal = new FaturasFechadasWhatsappHelper.OutputUltimosVencimentosFechados();

        for (InputVencimentosFechados item: inputs) {
            retorno.addAll(IntegracoesFaturas.UltimosVencimentosFechados(item.numeroConta, item.idEmpresa, item.cpf, item.canal));
        }

        Integer controle = 0;
        for (IntegracoesFaturas.OutputUltimosVencimentosFechados item: retorno) {
            if (item.StatusOK == null || item.StatusOK == 'OK') {
                List<String> listData = item.data.split('-');
                item.data = listData[1] + '-' + listData[0];

                switch on listData[1]{
                    when '01' {
                        item.dataFormatado = 'Janeiro/' + listData[0];
                    }
                    when '02' {
                        item.dataFormatado = 'Fevereiro/' + listData[0];
                    }
                    when '03' {
                        item.dataFormatado = 'Março/' + listData[0];
                    }
                    when '04' {
                        item.dataFormatado = 'Abril/' + listData[0];
                    }
                    when '05' {
                        item.dataFormatado = 'Maio/' + listData[0];
                    }
                    when '06' {
                        item.dataFormatado = 'Junho/' + listData[0];
                    }
                    when '07' {
                        item.dataFormatado = 'Julho/' + listData[0];
                    }
                    when '08' {
                        item.dataFormatado = 'Agosto/' + listData[0];
                    }
                    when '09' {
                        item.dataFormatado = 'Setembro/' + listData[0];
                    }
                    when '10' {
                        item.dataFormatado = 'Outubro/' + listData[0];
                    }
                    when '11' {
                        item.dataFormatado = 'Novembro/' + listData[0];
                    }
                    when else {
                        item.dataFormatado = 'Dezembro/' + listData[0];
                    }
                }

                objFinal.StringListIdFatura += ',' + item.idFatura;
                objFinal.StringListData += ',' + item.data;
                objFinal.StringListDataFormatado += ',' + item.dataFormatado;
                objFinal.listdataFormatado.add(item.dataFormatado);

                objFinal.StatusOK = 'OK';
            }else{
                objFinal.StatusOK = item.StatusOK;
            }

            controle ++;

            if(controle == 9){
                break;
            }
        }
        objFinal.listdataFormatado.add('Outros');
        retornoFinal.add(objFinal);

        return retornoFinal;
    }


    public class InputVencimentosFechados{
        @InvocableVariable(required = true)
        public String numeroConta;
        @InvocableVariable(required = true)
        public String idEmpresa;
        @InvocableVariable(required = true)
        public String cpf;
        @InvocableVariable(required = true)
        public String canal; 
    }



    // RESPONSE REFERENTE AO MÉTODO 'UltimosVencimentosFechados'
    public class OutputUltimosVencimentosFechados {
        @InvocableVariable
        public String StringListIdFatura;
        @InvocableVariable
        public String StringListData;
        @InvocableVariable
        public String StringListDataFormatado;
        @InvocableVariable
        public String StatusOK;
        @InvocableVariable
        public List<String> listdataFormatado;

        public OutputUltimosVencimentosFechados(){
            this.listdataFormatado = new List<String>();
        }
    }
}