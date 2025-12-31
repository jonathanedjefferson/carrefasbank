public class UltimosPagamentos {
    @invocableMethod(label='Get Ultimos Pagamentos')
    public static List<OutputUltimosPagamentos> GetUltimosPagamentos(List<InputUltimosPagamentos> input) {
        List<UltimosPagamentos.OutputUltimosPagamentos> listRetorno = new List<UltimosPagamentos.OutputUltimosPagamentos>();
        UltimosPagamentos.OutputUltimosPagamentos objFaturasForBot = new UltimosPagamentos.OutputUltimosPagamentos();

        List<UltimosLancamentos.OutputFaturasAbertas> listFaturas = new List<UltimosLancamentos.OutputFaturasAbertas>();
        for (InputUltimosPagamentos item: input) {
            listFaturas.addAll(UltimosLancamentos.GetFaturasAbertas(item.CPF, item.NumeroConta, item.Token, item.unidadeNegocio, item.canal));
        }

        if (listFaturas[0].StatusAPI.equalsIgnoreCase('OK')) {
            // TRATATIVA DOS VALORES
            List<String> ListDate = new List<String>();
            String ResultadoTipoPagamento;
            String ResultadoDescricao;
            Boolean ContemPagamento;
            
            for (UltimosLancamentos.OutputFaturasAbertas item: listFaturas) {
                item.valor.valor = item.valor.valor * -1;
                for (UltimosLancamentos.OutputFaturasAbertas item2: listFaturas) {
                    if (item.descricao != null || item2.descricaoGrupo != null) {
                        if (item.descricao == item2.descricaoGrupo) {
                            item.valor.valor += item2.valor.valor;
                        }
                    }
                }
                ListDate.add(item.data);
            }

            // DEIXANDO EM ORDEM DECRESCENTE
            ListDate.sort();
            List<String> ListDateOrdernado = new List<String>();
            for (Integer i=ListDate.size()-1; i>=0; i--) {
                ListDateOrdernado.add(ListDate[i]);
            }

            Set<UltimosLancamentos.OutputFaturasAbertas> listOrdenada = new Set<UltimosLancamentos.OutputFaturasAbertas>();
            for (String itemData: ListDateOrdernado) {
                for (UltimosLancamentos.OutputFaturasAbertas itemObj: listFaturas) {
                    if (itemData == itemObj.data) {
                        if(itemObj.descricaoLancamento.tipoPagamento != null && itemObj.descricaoLancamento.descricao != null ){
                            ResultadoTipoPagamento = itemObj.descricaoLancamento.tipoPagamento;
                            ResultadoTipoPagamento = ResultadoTipoPagamento.toUpperCase();
                            ResultadoDescricao = itemObj.descricaoLancamento.descricao;
                            ContemPagamento = ResultadoDescricao.toUpperCase().contains('PAGAMENTO');
        
                            if(ResultadoTipoPagamento.equals('PAGAMENTO') && ContemPagamento){
                                listOrdenada.add(itemObj);
                             }
                        }
                    }
                }
            }

            if(listOrdenada.isEmpty()){
                listFaturas[0].StatusAPI = 'SEM LANCAMENTOS';
                objFaturasForBot.numeroDeFaturasRetornadas = 0;
            }

            // MONTANDO RETORNO
            for (UltimosLancamentos.OutputFaturasAbertas item: listOrdenada) {
                Date dt = Date.valueOf(item.data);

                String lancamentoFormatado = dt.DAY() + '/' + dt.MONTH() + ': ' + item.descricao + ' ' + item.valor.moeda + ' '+ Decimal.valueOf(item.valor.valor).setScale(2);
                if (objFaturasForBot.ListUltimos5Lancamentos.size() < 5) {
                    objFaturasForBot.ListUltimos5Lancamentos.add(lancamentoFormatado);
                    objFaturasForBot.StringUltimos5Lancamentos += lancamentoFormatado+'\n';
                }else{
                    objFaturasForBot.StringDemaisLancamentos += lancamentoFormatado+'\n';
                    objFaturasForBot.ListDemaisLancamentos.add(lancamentoFormatado);
                }
                // objFaturasForBot.StringTodosLancamentos += lancamentoFormatado+'\n';
                objFaturasForBot.StringTodosLancamentos += lancamentoFormatado;

                if(objFaturasForBot.ListTodosLancamentos.size() < listOrdenada.size() -1){
                    objFaturasForBot.StringTodosLancamentos += '\n\n';
                }
                objFaturasForBot.ListTodosLancamentos.add(lancamentoFormatado);
            }
            objFaturasForBot.numeroDeFaturasRetornadas = listFaturas.size();
        } else if (listFaturas[0].StatusAPI.equalsIgnoreCase('SEM LANCAMENTOS')) {
            objFaturasForBot.numeroDeFaturasRetornadas = 0;
        }

        objFaturasForBot.StatusAPI = listFaturas[0].StatusAPI;
        listRetorno.add(objFaturasForBot);

        return listRetorno;
    }

    public class InputUltimosPagamentos{
        @InvocableVariable(required = true)
        public String CPF;
        @InvocableVariable(required = true)
        public String NumeroConta;
        @InvocableVariable(required = true)
        public String Token;
        @InvocableVariable(required = true)
        public String unidadeNegocio;
        @InvocableVariable(required = true)
        public String canal;
    }

    public class OutputUltimosPagamentos {
        @InvocableVariable
        public String StringTodosLancamentos;
        @InvocableVariable
        public String StringUltimos5Lancamentos;
        @InvocableVariable
        public String StringDemaisLancamentos;
        @InvocableVariable
        public List<String> ListUltimos5Lancamentos;
        @InvocableVariable
        public List<String> ListTodosLancamentos;
        @InvocableVariable
        public List<String> ListDemaisLancamentos;
        @InvocableVariable
        public Integer numeroDeFaturasRetornadas;
        @InvocableVariable
        public String StatusAPI;

        public OutputUltimosPagamentos(){
            this.StringUltimos5Lancamentos = '';
            this.StringTodosLancamentos = '';
            this.StringDemaisLancamentos = '';
            this.ListUltimos5Lancamentos = new List<String>();
            this.ListTodosLancamentos = new List<String>();
            this.ListDemaisLancamentos = new List<String>();
        }
    }

}