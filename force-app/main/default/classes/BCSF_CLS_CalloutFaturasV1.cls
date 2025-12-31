public class BCSF_CLS_CalloutFaturasV1 {

    public static String buscarFaturaAberta(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterFaturaAbertaV1');
        String  response;

        String endpoint =  config.Endpoint__c + config.Path__c.replace('{conta}', numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpfCliente,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Obter Fatura Aberta', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );  

        if(objHttpResponse.getStatusCode() == 200){
            response =  objHttpResponse.getBody();
        }

        return response;
    }

    public static String buscarFaturaFechada(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){  
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterFaturasFechadasV1');
        String  response;

        String endpoint =  config.Endpoint__c + config.Path__c.replace('{conta}', numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpfCliente,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Obter Faturas Fechadas', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );

        if(objHttpResponse.getStatusCode() == 200){
            response = objHttpResponse.getBody();
        }

        return response;

    }

    public static List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> buscarDetalhesFatura(String numeroConta, String dataVencimento, String cpfCliente, String unidadeNegocio, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterDetalhesFaturasV1');
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = new List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>();

        String endpoint =  config.Endpoint__c + config.Path__c.replace('{conta}', numeroConta).replace('{mes-ano}', dataVencimento);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpfCliente,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Obter Detalhes Fatura Fechada', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );

        if(objHttpResponse.getStatusCode() == 200){
            List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada> response = new List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>();
            response = (List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>) JSON.deserialize(objHttpResponse.getBody(), List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>.class);

            for(BCSF_CLS_CalloutFaturasTO.FaturaDetalhada lancamento : response){
                BCSF_CLS_CalloutFaturasTO.DetalhesFatura detalhes = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
                    detalhes.numeroCartao = lancamento.numeroCartao;
                    detalhes.dataTransacao = lancamento.data;
                    detalhes.descricao = lancamento.descricaoLancamento.descricao;
                    detalhes.descricaoGrupo = lancamento.descricaoGrupo;
                    detalhes.valor = lancamento.valor.valor;
                    detalhes.faturaIndisponivel = false;
                    detalhes.reasonCode = lancamento.descricaoLancamento.reasonCode;
                    detalhes.idTransacao = lancamento.descricaoLancamento.idLancamento;
                    detalhes.dataProcessamento = lancamento.descricaoLancamento.postingDate;
                    detalhes.tipoLancamento = lancamento.descricaoLancamento.tipoPagamento;
                    detalhes.moeda = lancamento.valor.moeda;
                    detalhes.chaveParticaoTransacao = lancamento.chaveParticaoTransacao;     
                    detalhes.agrupamentoLancamentos = lancamento.agrupamentoLancamentos;

                    retorno.add(detalhes);
            }
        } else if(objHttpResponse.getStatusCode() == 404){
                BCSF_CLS_CalloutFaturasTO.DetalhesFatura detalhes = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
                detalhes.faturaIndisponivel = true;
                    
                retorno.add(detalhes);
        }

        return !retorno.isEmpty() ? retorno : null;
    }

     public static List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> buscarDetalhesFaturaAberta(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterDetalhesFaturaAbertaV1');
        List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> retorno = new List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura>();

        String endpoint =  config.Endpoint__c + config.Path__c.replace('{conta}', numeroConta);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpfCliente,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );

        LogIntegracaoBO.InsertLog(
            'Obter Detalhes Fatura Aberta', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpfCliente, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );

        if(objHttpResponse.getStatusCode() == 200){
            List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada> response = new List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>();
            response = (List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>) JSON.deserialize(objHttpResponse.getBody(), List<BCSF_CLS_CalloutFaturasTO.FaturaDetalhada>.class);

            for(BCSF_CLS_CalloutFaturasTO.FaturaDetalhada lancamentos : response){
                BCSF_CLS_CalloutFaturasTO.DetalhesFatura detalhes = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
                    detalhes.numeroCartao = lancamentos.numeroCartao;
                    detalhes.dataTransacao = lancamentos.data;
                    detalhes.descricao = lancamentos.descricaoLancamento.descricao;
                    detalhes.descricaoGrupo = lancamentos.descricaoGrupo;
                    detalhes.valor = lancamentos.valor.valor;
                    detalhes.faturaIndisponivel = false;
                    detalhes.reasonCode = lancamentos.descricaoLancamento.reasonCode;
                    detalhes.idTransacao = lancamentos.descricaoLancamento.idLancamento;
                    detalhes.dataProcessamento = lancamentos.descricaoLancamento.postingDate;
                    detalhes.tipoLancamento = lancamentos.descricaoLancamento.tipoPagamento;
                    detalhes.moeda = lancamentos.valor.moeda;
                    detalhes.chaveParticaoTransacao = lancamentos.chaveParticaoTransacao;     
                    detalhes.agrupamentoLancamentos = lancamentos.agrupamentoLancamentos;

                    retorno.add(detalhes);
            }
        } else if(objHttpResponse.getStatusCode() == 404){
                BCSF_CLS_CalloutFaturasTO.DetalhesFatura detalhes = new BCSF_CLS_CalloutFaturasTO.DetalhesFatura();
                detalhes.faturaIndisponivel = true;
                    
                retorno.add(detalhes);
        }

        return !retorno.isEmpty() ? retorno : null;
    }


    public static outputDownloadFatura getFatura(String numeroConta, String idEmpresa, String idFatura, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DownloadFaturaSemCriptografia');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{idFatura}', idFatura), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal,
                'LoginOperador' => loginOperador
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'PDF Fatura', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{idFatura}', idFatura), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            '',
            idEmpresa,
            canal.capitalize()
        );   

        outputDownloadFatura output = new outputDownloadFatura();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (outputDownloadFatura) JSON.deserialize(objHttpResponse.getBody(), outputDownloadFatura.class);
            output.statusReponse =  'OK';
            return output;
        }
        output.statusReponse =  'ERROR';
        return output;
    }

    public static outputDownloadFatura getFaturaEncripted(String numeroConta, String idEmpresa, String idFatura, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DownloadFaturaComCriptografia');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{idFatura}', idFatura), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'PDF Fatura Encriptado', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta).replace('{idFatura}', idFatura), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            '',
            idEmpresa,
            canal.capitalize()
        );   

        outputDownloadFatura output = new outputDownloadFatura();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (outputDownloadFatura) JSON.deserialize(objHttpResponse.getBody(), outputDownloadFatura.class);
            output.statusReponse =  'OK';
            return output;
        }
        output.statusReponse =  'ERROR';
        return output;
    }

    public static List<OutputUltimosVencimentosFechados> UltimosVencimentosFechados(String numeroConta, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('UltimosVencimentosFechados');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'cpf' => cpf,
                'id_empresa' => idEmpresa,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Últimos Vencimentos Fechados', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            return (List<OutputUltimosVencimentosFechados>) JSON.deserialize(objHttpResponse.getBody(), List<OutputUltimosVencimentosFechados>.class);
        }

        List<OutputUltimosVencimentosFechados> listRetorno = new List<OutputUltimosVencimentosFechados>();
        OutputUltimosVencimentosFechados outp = new OutputUltimosVencimentosFechados();
        outp.StatusOK = status == '422' ? 'SEM FATURAS' : 'ERROR';
        listRetorno.add(outp);
        return listRetorno;
    }

    public static OutPutGetExtratoCompacto getExtratoCompacto( String numeroConta,String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ObterExtratoCompacto');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'id_empresa' => idEmpresa,
                'cpf' => cpf,
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c,
                'canal' => canal
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter extrato compacto', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        OutPutGetExtratoCompacto output = new OutPutGetExtratoCompacto();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutPutGetExtratoCompacto) JSON.deserialize(objHttpResponse.getBody(), OutPutGetExtratoCompacto.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }
    
    public class OutputUltimosVencimentosFechados {
        @AuraEnabled
        public Integer idFatura;
        @AuraEnabled
        public String data;
        @AuraEnabled
        public String dataFormatado;
        @AuraEnabled 
        public String StatusOK;
    }

    public class outputDownloadFatura {
        @AuraEnabled
        public String conteudo;
        @AuraEnabled
        public String statusReponse;
    }

    public class OutPutGetExtratoCompacto {
        @AuraEnabled
        public String dataVencimento;
        @AuraEnabled
        public String dataUltimoPagamento;
        @AuraEnabled
        public String valorUltimoPagamento;
        @AuraEnabled
        public Decimal limiteComprasCarrefour;
        @AuraEnabled
        public Integer melhorDiaCompra;
        @AuraEnabled
        public Decimal saldoDevedorNestaData;
        @AuraEnabled
        public Decimal saldoDisponivelCompras;
        @AuraEnabled
        public ValoresLimites valoresLimites;
        @AuraEnabled 
        public String statusResponse;
    }

    public class ValoresLimites {
        @AuraEnabled
        public Decimal limiteSaque;
        @AuraEnabled
        public Decimal limiteDisponivelSaque;
        @AuraEnabled
        public Decimal debitoTotal;
        @AuraEnabled
        public String dataAlteracaoLimite;
        @AuraEnabled
        public String formaDePagamento;
        @AuraEnabled
        public String dataReeimpressaoFatura;
        @AuraEnabled
        public Decimal limiteAutorizacao;
        @AuraEnabled
        public Decimal saldoRemanescente;
        @AuraEnabled
        public String dataUltimoPagamento;
        @AuraEnabled
        public SaldoVencidoAtualizado saldoVencidoAtualizado;
    }

    public class SaldoVencidoAtualizado {
        @AuraEnabled
        public Decimal saldoPagamento;
        @AuraEnabled
        public Decimal encargoDeAtraso;
        @AuraEnabled
        public Decimal mora;
        @AuraEnabled
        public Decimal multa;
        @AuraEnabled
        public Decimal saldoAtual;
        @AuraEnabled
        public Decimal pagamentoRealizado;
    }

}