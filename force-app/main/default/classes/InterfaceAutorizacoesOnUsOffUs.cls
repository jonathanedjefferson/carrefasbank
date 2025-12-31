public class InterfaceAutorizacoesOnUsOffUs {

    @invocableMethod(label='Obter Autorizacoes OnUs OffUs')
    public static List<Output> obterAutorizacoesOnUsOffUs(List<Input> inputList){

        String dataInicial  = String.valueOf(System.today().addDays(-Integer.valueOf(inputList[0].periodoTransacoesEmDias)));
        String dataFinal = String.valueOf(System.today());
        String tamanhoPagina = '50';
        String pagina = '1';
        String statusAPI;

        List<String> cartoesBloqueados = inputList[0].idCartoesBloqueadosLst.split(',');
        List<AutorizacoesOnUsOffUs.OutputAutorizacoes> retornosAPI = new List<AutorizacoesOnUsOffUs.OutputAutorizacoes>();

        for(String cartaoId : cartoesBloqueados){
            retornosAPI.add(AutorizacoesOnUsOffUs.GetAutorizacoesOnUsOffUs(inputList[0].cpf, inputList[0].numeroConta, null, inputList[0].unidadeNegocio, inputList[0].canal, cartaoId, dataInicial, dataFinal, tamanhoPagina, pagina));
        }

        List<AutorizacoesOnUsOffUs.Data> transacoesRetornadas = new List<AutorizacoesOnUsOffUs.Data>();

        for(AutorizacoesOnUsOffUs.OutputAutorizacoes retorno : retornosAPI){
            if(retorno.statusAutorizacao == 'OK'){
                if(!retorno.data.isEmpty()){
                    transacoesRetornadas.addAll(retorno.data);
                }
                statusAPI = 'OK';
            } else if(statusAPI != 'OK'){
                statusAPI = 'ERROR';
            }
        }

        List<Transacao> transacoesFiltradasLst = new List<Transacao>();

        Set<String> codigosAdicionados = new Set<String>();

        for(AutorizacoesOnUsOffUs.Data transacao : transacoesRetornadas){

            if(transacao.estabelecimento != null && transacao.meioPagamento != 'Cartão' && transacao.meioPagamento != 'Contactless'){

                if(codigosAdicionados.contains(transacao.codigo)){
                    continue;
                }

                Transacao itemTransacao = new Transacao();
                
                itemTransacao.dateTimeTransacao = Datetime.valueOf((transacao.data.replace('T', ' ')));
                itemTransacao.data = transacao.data;
                itemTransacao.valor = transacao.valor;
                itemTransacao.estabelecimento = transacao.estabelecimento;
                transacoesFiltradasLst.add(itemTransacao);

                if(transacao.codigo != null){
                    codigosAdicionados.add(transacao.codigo);
                } 

            }

        }

        transacoesFiltradasLst.sort();

        Output output = new Output();
        output.statusAPI = statusAPI;

        List<Output> outputLst = new List<Output>();

        for (Integer i = 0; i < Math.min(transacoesFiltradasLst.size(), 10); i++) {
            switch on i {
                when 0 { output.transacao1 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 1 { output.transacao2 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 2 { output.transacao3 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 3 { output.transacao4 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 4 { output.transacao5 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 5 { output.transacao6 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 6 { output.transacao7 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 7 { output.transacao8 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 8 { output.transacao9 = formatarTransacao(transacoesFiltradasLst[i]); }
                when 9 { output.transacao10 = formatarTransacao(transacoesFiltradasLst[i]); }
                when else {}
            }
        }

        outputLst.add(output);

        return outputLst;

    }

    public static String formatarTransacao(Transacao transacao){
        List<String> dataEHora = transacao.data.split('T');

        String dataFormatada = Util.formatDateDDMMYYYY(Date.valueOf(dataEHora[0]), '/');

        String hora = dataEHora[1].substring(0,5);

        String valor = String.valueOf(Decimal.valueOf(transacao.valor).setScale(2));

        return transacao.estabelecimento + ' no valor de: R$ ' + valor + ' no dia ' + dataFormatada + ' às ' + hora;
    
    }

    public class Transacao implements Comparable {
        Datetime dateTimeTransacao;
        String data;
        Double valor;
        String estabelecimento;

        public Integer compareTo(Object instance) {
            Transacao that = (Transacao) instance;
            if (this.dateTimeTransacao < that.dateTimeTransacao) return 1;
            if (this.dateTimeTransacao > that.dateTimeTransacao) return -1;
            return 0; 
        }
    }

    public class Input{
        @InvocableVariable
        public String cpf;
        @InvocableVariable
        public String numeroConta;
        @InvocableVariable
        public String unidadeNegocio;
        @InvocableVariable
        public String canal;
        @InvocableVariable
        public String numeroCartaoSerno;
        @InvocableVariable
        public Integer periodoTransacoesEmDias;
        @InvocableVariable
        public String idCartoesBloqueadosLst;
    }

    public class Output{
        @InvocableVariable
        public String transacao1;
        @InvocableVariable
        public String transacao2;
        @InvocableVariable
        public String transacao3;
        @InvocableVariable
        public String transacao4;
        @InvocableVariable
        public String transacao5;
        @InvocableVariable
        public String transacao6;
        @InvocableVariable
        public String transacao7;
        @InvocableVariable
        public String transacao8;
        @InvocableVariable
        public String transacao9;
        @InvocableVariable
        public String transacao10;
        @InvocableVariable(description='OK, ERROR')
        public String statusAPI;
    }
    
}