public class IntegracaoSeguros {
    /********************************************************************************************************************************
     *    OBS:                                                                                                                      *
     *      - O parametro "List<String> listIdDeProdutos" serve para quando quiser pesquisar produtos específicos.                  *
     *          - Se quiser trazer todos os produtos disponíveis para o cliente, basta passar uma lista vazia                       *
     *          - Se quiser trazer produtos específicos, basta adicionar o(os) código(s) do(s) produto(s) dentro dessa lista        *
     *              - EX: listIdDeProdutos.add('2222');                                                                             *
    *********************************************************************************************************************************/
    public static OutputElegibilidadeProdutos ElegibilidadeProdutos(String idEmpresa, String canal, String cpf, String numeroConta, List<String> listIdDeProdutos){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ElegibilidadeSeguros');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);
        String unidadeAtendimento;
        try {
            unidadeAtendimento = [SELECT UnidadeDeAtendimento__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].UnidadeDeAtendimento__c;
        } catch(Exception e) {
            unidadeAtendimento = '';
        }

        String codCanal = '';
        System.debug('unidadeAtendimento' + unidadeAtendimento);
        if (!String.isBlank(unidadeAtendimento)) {
            try {
                CodigoCanalElegibilidade__mdt canalMeta = [
                    SELECT CodigoCanal__c
                    FROM CodigoCanalElegibilidade__mdt
                    WHERE CodigoCanal__c = :unidadeAtendimento
                    LIMIT 1
                ];
                codCanal = canalMeta.CodigoCanal__c;
            } catch (Exception e){
                codCanal = '';
            }
        }

        // MONTANDO BODY
        String body = config.Body__c.replace('{numeroConta}', numeroConta).replace('{idEmpresa}', idEmpresa).replace('{codCanal}', codCanal);
        if (listIdDeProdutos.size() == 0) {
            body = body.replace('{listProdutos}', '');
        }else{
            if (listIdDeProdutos.size() == 0) {
                body = body.replace('{listProdutos}', '');
            }else{
                String listProdutos = '';
                Integer cont = 0;
                for (String item: listIdDeProdutos) {
                    cont ++;   
                    if (cont == listIdDeProdutos.size()) {
                        listProdutos += '"' + item + '"';
                    }else{
                        listProdutos += '"' + item + '",\n';
                    }             
                }
            
                body = body.replace('{listProdutos}', listProdutos);
            }
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Elegibilidade de Seguros', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        OutputElegibilidadeProdutos retorno = new OutputElegibilidadeProdutos();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputElegibilidadeProdutos) System.JSON.deserialize(objHttpResponse.getBody(), OutputElegibilidadeProdutos.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static  OutputAdesaoSeguro adesaoProdutos(String idEmpresa, String canal, String cpf, String body){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('adesaoSeguros');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-login-type' => '2',
                'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        System.debug(objHttpResponse.getStatusCode());
        System.debug(objHttpResponse.getBody());
        

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Adesão de Seguros', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        OutputAdesaoSeguro retorno = new OutputAdesaoSeguro();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputAdesaoSeguro) System.JSON.deserialize(objHttpResponse.getBody(), OutputAdesaoSeguro.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static  OutputAdesaoSeguro adesaoProdutosWhatsApp(String idEmpresa, String canal, String cpf, String body){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AdesaoSegurosWPP');
        List<ServerToServerServices.Input> listInputToken = new List<ServerToServerServices.Input>();
        ServerToServerServices.Input inputToken = new ServerToServerServices.Input();
        inputToken.canal = canal;
        listInputToken.add(inputToken);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-login-type' => '2',
                'x-uat' => config.UAT__c == null ? ' ' : config.UAT__c
            }, 
            body, 
            Integer.valueof(config.Timeout__c)
        );

        System.debug(objHttpResponse.getStatusCode());
        System.debug(objHttpResponse.getBody());
        

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Adesão de Seguros WhatsApp', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        OutputAdesaoSeguro retorno = new OutputAdesaoSeguro();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (OutputAdesaoSeguro) System.JSON.deserialize(objHttpResponse.getBody(), OutputAdesaoSeguro.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static OutputMotivosCancelamento motivosCancelamento(String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('MotivosCancelamentoSeguros');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Motivos de cancelamento de seguros', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        OutputMotivosCancelamento output = new OutputMotivosCancelamento();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output.motivos = (List<MotivoCancelamento>) JSON.deserialize(objHttpResponse.getBody(), List<MotivoCancelamento>.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputConsultarSeguros consultarSeguros(String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ConsultarSeguros');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{cpf}', cpf).replace('{idEmpresa}', idEmpresa), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Consultar seguros', 
            config.Endpoint__c + config.Path__c.replace('{cpf}', cpf).replace('{idEmpresa}', idEmpresa), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        OutputConsultarSeguros output = new OutputConsultarSeguros();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputConsultarSeguros) JSON.deserialize(objHttpResponse.getBody(), OutputConsultarSeguros.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputHistoricoSeguro historicoCobranca( String nameAdesao, String idAdesao, String idEmpresa, String cpf, String canal){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('HistoricoCobrancaSeguros');

        String pathAtualizado = config.Path__c;
        pathAtualizado = pathAtualizado.replace('{cpf}', cpf);
        pathAtualizado = pathAtualizado.replace('{nameAdesao}', nameAdesao);
        pathAtualizado = pathAtualizado.replace('{idAdesao}', idAdesao);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + pathAtualizado, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(canal, cpf).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Historico cobrança seguros', 
            config.Endpoint__c + pathAtualizado, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );   

        OutputHistoricoSeguro output = new OutputHistoricoSeguro();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputHistoricoSeguro) JSON.deserialize(objHttpResponse.getBody(), OutputHistoricoSeguro.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }

    public static OutputCancelarSeguros cancelamentoSeguro( InputCancelamento contrato){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CancelamentoSeguros');

        String bodyAtualizado = config.Body__c;
        bodyAtualizado = bodyAtualizado.replace('{idAdesao}', contrato.idAdesao);
        bodyAtualizado = bodyAtualizado.replace('{nomeAdesao}', contrato.nomeAdesao);
        bodyAtualizado = bodyAtualizado.replace('{dataCancelamento}', contrato.dataCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{motivoID}', contrato.codMotivoCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{canalID}', contrato.codigoCanalCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{canalNome}', contrato.nomeCanalCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{DRT}', contrato.codigoUsuarioCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{userLogin}', contrato.nomeUsuarioCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{comentario}', contrato.comentarioCancelamento);
        bodyAtualizado = bodyAtualizado.replace('{cpf}', contrato.cpf);
        bodyAtualizado = bodyAtualizado.replace('{unidadeNegocio}', String.valueOf(contrato.unidadeNegocio)); 

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.getTokenByCPF(contrato.canal, contrato.cpf).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            bodyAtualizado, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Cancelamento seguros', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            bodyAtualizado, 
            contrato.cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            contrato.unidadeNegocio,
            contrato.canal.capitalize()
        );   

        OutputCancelarSeguros output = new OutputCancelarSeguros();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            output = (OutputCancelarSeguros) JSON.deserialize(objHttpResponse.getBody(), OutputCancelarSeguros.class);
            output.statusResponse =  'OK';
            return output;
        }
        output.statusResponse =  'ERROR';
        return output;
    }


    // RETORNO DO MÉTODO 'Adesão Seguros'
    public class OutputAdesaoSeguro {
        @auraEnabled
        public String mensagem;
        @auraEnabled
        public Decimal idAdesao;
        @auraEnabled
        public String statusAPI;
    }

    // RETORNO DO MÉTODO 'ElegibilidadeProdutos'
    public class OutputElegibilidadeProdutos {
        @auraEnabled
        public Integer status;
        @auraEnabled
        public String nome;
        @auraEnabled
        public String cartao;
        @auraEnabled
        public String statusAPI;
        @auraEnabled
        public List<Produtos> produtos;
    }
    
    public class Produtos {
        @auraEnabled 
        public String codigoProduto;
        @auraEnabled 
        public String nomeProduto;
        @auraEnabled 
        public String tipo;
        @auraEnabled 
        public String nomeProdutoPadronizado;
        @auraEnabled 
        public String termoAdesao;
        @auraEnabled 
        public Integer anosVigencia;
        @auraEnabled 
        public String descricao;
        @auraEnabled 
        public String seguradora;
        @auraEnabled 
        public Integer quantidadePermitida;
        @auraEnabled 
        public Configuracao configuracao;
        @auraEnabled 
        public Apresentacao apresentacao;
        @auraEnabled 
        public List<CoberturasPlano> coberturasPlano;
    }
    
    public class Configuracao {
        @auraEnabled
        public String tipoVisualizacao;
        @auraEnabled
        public Boolean extencao;
        @auraEnabled
        public Boolean confirmaEndereco;
        @auraEnabled
        public String textoPlanoDivisaoCategoria;
        @auraEnabled
        public String consultaCardEspecial;
        @auraEnabled
        public Boolean confirmaDependentes;
    }
    
    public class Apresentacao {
        @auraEnabled
        public String titulo;
        @auraEnabled
        public String descricao;
        @auraEnabled
        public String descricaoValor;
        @auraEnabled
        public String descricaoValorExemplo;
        @auraEnabled
        public String descricaoSelecaoPlano;
    }
    
    public class CoberturasPlano {
        @auraEnabled
        public String idPlano;
        @auraEnabled
        public String nomePlano;
        @auraEnabled
        public Boolean especial;
        @auraEnabled
        public String tipoCalculoValor;
        @auraEnabled
        public String tipoCobranca;
        @auraEnabled
        public String valorParcela;
        @auraEnabled
        public Integer ordenacao;
        @auraEnabled
        public Boolean estaAtivo;
        @auraEnabled
        public List<Cobertura> cobertura;
    }
    
    public class Cobertura {
        @auraEnabled
        public String titulo;
        @auraEnabled
        public String descricao;
        @auraEnabled
        public String observacao;
        @auraEnabled
        public Boolean exibeConsulta;
        @auraEnabled
        public Boolean exibeAdesao;
        @auraEnabled
        public Integer ordenacao;
    }
    
    // Output motivos de cancelamento
    public class OutputMotivosCancelamento {
        @auraEnabled
        public String statusResponse;
        @auraEnabled
        public List<MotivoCancelamento> motivos;
    }
    public class MotivoCancelamento {
        @auraEnabled
        public String descricao;
        @auraEnabled
        public Integer codigoMotivo;
        @auraEnabled
        public Integer ordem;
    }

    //Output Consultar seguros
    public class OutputConsultarSeguros {
        @auraEnabled
        public String statusResponse;
        @AuraEnabled 
        public List<AdesaoConsultaSeguros> adesoes;
    }
    public class AdesaoConsultaSeguros {
        @AuraEnabled 
        public String status;
        @AuraEnabled 
        public String nomeProduto;
        @AuraEnabled 
        public String nomePlano;
        @AuraEnabled 
        public Double valor;
        @AuraEnabled 
        public String tipoadesao;
        @AuraEnabled 
        public String dataAdesao;
        @AuraEnabled 
        public String dataInicioVigencia;
        @AuraEnabled 
        public String dataFimVigencia;
        @AuraEnabled 
        public String codCanalAdesao;
        @AuraEnabled 
        public String nomeCanalAdesao;
        @AuraEnabled 
        public String codLojaAdesao;
        @AuraEnabled 
        public String uuidContrato;
        @AuraEnabled 
        public String numeroSorte;
        @AuraEnabled 
        public String codigoOperadorVenda;
        @AuraEnabled 
        public String certificado;
        @AuraEnabled 
        public String codigoOperadorCancelamento;
        @AuraEnabled 
        public String motivoCancelamento;
        @AuraEnabled 
        public String dataCancelamento;
        @AuraEnabled 
        public String codCanalCancelamento;
        @AuraEnabled 
        public String nomeCanalCancelamento;
        @AuraEnabled 
        public String codLojaCancelamento;
        @AuraEnabled 
        public String numeroSerie;
        @AuraEnabled 
        public String idAdesaoProseg;
        @AuraEnabled 
        public String idAdesaoPdr;
    }

    //input e output de cancelamento de seguro
    public class InputCancelamento {
        public String idAdesao;
        public String nomeAdesao;
        public String dataCancelamento;
        public String codMotivoCancelamento;
        public String codigoCanalCancelamento;
        public String nomeCanalCancelamento;
        public String codigoUsuarioCancelamento;
        public String nomeUsuarioCancelamento;
        public String comentarioCancelamento;
        public String cpf;
        public String unidadeNegocio;
        public String canal;
    }

    public class OutputCancelarSeguros {
        @auraEnabled
        public String statusResponse;
        @AuraEnabled 
        public String messageId;
    }

    //output de histórico de cobrança
    public class OutputHistoricoSeguro {
        @AuraEnabled 
        public String statusResponse;
        @AuraEnabled 
        public Double valorMensal;
        @AuraEnabled 
        public Double totalPago;
        @AuraEnabled 
        public Integer parcelaAtual;
        @AuraEnabled 
        public Integer parcelasEncerradas;
        @AuraEnabled 
        public String ultimaCobranca;
        @AuraEnabled 
        public String proximaCobranca;
        @AuraEnabled 
        public List<parcelaHistorico> parcelas;
    }

    public class parcelaHistorico{
        @AuraEnabled 
        public Integer idParcela;
        @AuraEnabled 
        public Integer idCobranca;
        @AuraEnabled 
        public Integer numero;
        @AuraEnabled 
        public String data;
        @AuraEnabled 
        public Integer status;
        @AuraEnabled 
        public Double valor;
        @AuraEnabled 
        public String dataInclusao;
    }
}