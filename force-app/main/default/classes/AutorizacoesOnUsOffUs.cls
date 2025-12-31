public class AutorizacoesOnUsOffUs {
    public static OutputAutorizacoes GetAutorizacoesOnUsOffUs(String CPF, String NumeroConta, String Token, String unidadeNegocio, String canal, String numeroCartaoSerno, String dataInicial, String dataFinal, string tamanhoPagina, String pagina) {

        OutputAutorizacoes listaRetorno = new OutputAutorizacoes();

        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetAutorizacoes');

        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        String returnDate;
        String Paginacao;

        returnDate = '?data-inicial=' + Util.formatDateString(dataInicial, '-', '-')  + '&data-final=' + Util.formatDateString(dataFinal, '-', '-');

        Paginacao = '&TamanhoPagina=' + tamanhoPagina + '&Pagina=' + Pagina;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + 
            config.Path__c.replace('{numero-conta}',NumeroConta).replace('{numero-cartao-serno}', numeroCartaoSerno) + returnDate + Paginacao, 
            config.Method__c, 
            new Map<String, String> {
                'cpf' => CPF,
                'Authorization' => 'Bearer '+ + ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            },
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        String statusCode = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Autorizações On-Us e Off-Us', 
            config.Endpoint__c + config.Path__c.replace('{numero-conta}',NumeroConta).replace('{numero-cartao-serno}', numeroCartaoSerno) + returnDate + Paginacao, 
            config.Method__c, 
            config.Body__c, 
            CPF, 
            statusCode, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        OutputAutorizacoes rt = new OutputAutorizacoes();
        if(statusCode.equals('200') || statusCode.equals('204')){
            listaRetorno = (OutputAutorizacoes) System.JSON.deserialize(objHttpResponse.getBody(), OutputAutorizacoes.class);
            listaRetorno.statusAutorizacao = 'OK';
        }else if (statusCode.equals('500')) {
            listaRetorno.statusAutorizacao = 'SEM LANCAMENTOS';
        }else{
            listaRetorno.statusAutorizacao = 'ERROR';
        }

        return listaRetorno;
    }

    public static OutputCartoesAutorizacoes ListCartoes(String canal, String area, String cpf, String numeroConta, String idEmpresa) {
        OutputCartoesAutorizacoes output = new OutputCartoesAutorizacoes();
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListCartoesParaReemissao');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ ServerToServerServices.GetTokenServerToServer(listInputToken).get(0).access_token,
                'canal' => canal,
                'area' => area,
                'cpf' => cpf,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Cartões transação On-Us e Off-Us', 
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
            output = (OutputCartoesAutorizacoes) System.JSON.deserialize(objHttpResponse.getBody(), OutputCartoesAutorizacoes.class); 
            output.StatusAPI = 'OK';
        return output;
        }
        output.StatusAPI = 'ERROR';
        return output;
    }

    public class OutputAutorizacoes{
        @AuraEnabled
        public Integer tamanhoPagina;
        @AuraEnabled
        public Integer pagina;
        @AuraEnabled
        public Integer totalItens;
        @AuraEnabled
        public List<Data> data;
        @AuraEnabled
        public String statusAutorizacao;

        public OutputAutorizacoes(){
            this.data = new List<Data>();
        }
    }

    public class Data{
        @AuraEnabled
        public String data;
        @AuraEnabled
        public String codigo;
        @AuraEnabled
        public Double valor;
        @AuraEnabled
        public Integer quantidadeParcelas;
        @AuraEnabled
        public Double valorParcelado;
        @AuraEnabled
        public String codigoResposta;
        @AuraEnabled
        public String detalheResposta;
        @AuraEnabled
        public String estabelecimento;
        @AuraEnabled
        public String codigoRamoAtividade;
        @AuraEnabled
        public String ramoAtividade;
        @AuraEnabled
        public String cidade;
        @AuraEnabled
        public String codigoPais;
        @AuraEnabled
        public String pais;
        @AuraEnabled
        public String tipoTransacao;
        @AuraEnabled
        public Integer codigoRecusa;
        @AuraEnabled
        public String traducaoRecusa;
        @AuraEnabled
        public String codigoEntrada;
        @AuraEnabled
        public String meioPagamento;
        @AuraEnabled
        public String detalheEntrada;
        @AuraEnabled
        public String statusAutorizacao;
        @AuraEnabled
        public String traducaoStatusAutorizacao;
        @AuraEnabled
        public String numeroCartao;
        @AuraEnabled
        public String numeroCartaoSerno;
    }

        // RESPONSE REFERENTE AO MÉTODO 'ListStatus'
        public class OutputCartoesAutorizacoes {
            @AuraEnabled
            public List<CartoesElegiveis> cartoesElegiveis;
            @AuraEnabled
            public List<Status> status;   
            @AuraEnabled  
            public String StatusAPI;
        }
       
        public class Status {
            @AuraEnabled
            public String nome;
            @AuraEnabled
            public String descricao;
        }
    
        public class CartoesElegiveis {
            @AuraEnabled
            public String numeroCartaoOfuscado;
            @AuraEnabled
            public String ehVirtual;
            @AuraEnabled
            public String numeroCartaoSerno; 
            @AuraEnabled
            public String status;
            @AuraEnabled
            public Boolean ehPrimario;
            @AuraEnabled
            public String nomeCartao;
            @AuraEnabled
            public String nomePortador;
            @AuraEnabled
            public String numeroCartaoCompleto;
            @AuraEnabled 
            public Boolean precisaAlterarStatus;
        }
}