public class IntegrationConsignado {
    public static OutputDadosContratoOriginal GetDadosContratoOriginal(String canal, String cpf, String numeroContrato, String unidadeNegocio){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetDadosContratoOriginal');
        OutputDadosContratoOriginal retorno = new OutputDadosContratoOriginal();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroContrato}', numeroContrato), 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Dados de Contrato Original', 
            config.Endpoint__c + config.Path__c.replace('{numeroContrato}', numeroContrato), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   
        
        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputDadosContratoOriginal) System.JSON.deserialize(objHttpResponse.getBody(), OutputDadosContratoOriginal.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('422')) {
            retorno = (OutputDadosContratoOriginal) System.JSON.deserialize(objHttpResponse.getBody(), OutputDadosContratoOriginal.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputPropostaRefinanciamento CriarPropostaRefinanciamento(String cpf, String canal, String unidadeNegocio, String email, String numeroContrato){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CriarPropostaRefinanciamento');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputPropostaRefinanciamento retorno = new OutputPropostaRefinanciamento();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'Content-Type' => 'application/json',
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c.replace('{cpf}', cpf).replace('{email}', email).replace('{numeroContrato}', numeroContrato), 
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Criar Proposta para Refinanciamento', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{cpf}', cpf).replace('{email}', email).replace('{numeroContrato}', numeroContrato),
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputPropostaRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputPropostaRefinanciamento.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('404') || status.equalsIgnoreCase('422')) {
            retorno = (OutputPropostaRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputPropostaRefinanciamento.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputCalcularSimulacaoRefinanciamento CalcularSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String idProposta, Boolean usarMargem, Boolean receberTroco, Integer quantidadeParcelas, Decimal valorTroco){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('CalcularSimulacaoRefinanciamento');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputCalcularSimulacaoRefinanciamento retorno = new OutputCalcularSimulacaoRefinanciamento();
        retorno.StatusAPI = 'ERROR';

        // MONTANDO ENDPOINT
        String endpoint = config.Endpoint__c + config.Path__c.replace('{idProposta}', idProposta).replace('{usarMargem}', usarMargem ? 'true' : 'false').replace('{receberTrocoMaximo}', receberTroco ? 'true' : 'false');
        if (usarMargem || receberTroco) {
            endpoint = endpoint.split('&quantidadeParcelas=')[0];
        }else if(!usarMargem && !receberTroco){
            if((quantidadeParcelas == null && valorTroco == null) || (quantidadeParcelas != null && valorTroco != null)){
                endpoint = endpoint.split('&quantidadeParcelas=')[0];
            }else if(quantidadeParcelas != null && valorTroco == null){
                endpoint = endpoint.split('&valorTroco')[0].replace('{quantidadeParcelas}', String.valueOf(quantidadeParcelas));
            }else if(quantidadeParcelas == null && valorTroco != null){
                endpoint = endpoint.replace('&quantidadeParcelas={quantidadeParcelas}', '').replace('{valorTroco}', String.valueOf(valorTroco));
            }else{
                endpoint = endpoint.split('&quantidadeParcelas=')[0];
            }
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'Content-Type' => 'application/json',
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Calcular Simulação de Refinanciamento', 
            endpoint, 
            config.Method__c, 
            config.Body__c,
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputCalcularSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalcularSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('404') || status.equalsIgnoreCase('422')) {
            retorno = (OutputCalcularSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputCalcularSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputGravarSimulacaoRefinanciamento GravarSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, BodyRequestGravarSimulacao bodyRequest){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GravarSimulacaoRefinanciamento');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputGravarSimulacaoRefinanciamento retorno = new OutputGravarSimulacaoRefinanciamento();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            System.JSON.serialize(bodyRequest), 
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Gravar Simulação de Refinanciamento', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            System.JSON.serialize(bodyRequest),
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputGravarSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputGravarSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('422') || status.equalsIgnoreCase('404')) {
            retorno = (OutputGravarSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputGravarSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputFimSimulacaoRefinanciamento FinalizarSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String idProposta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('FinalizarSimulacaoRefinanciamento');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputFimSimulacaoRefinanciamento retorno = new OutputFimSimulacaoRefinanciamento();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'Content-Type' => 'application/json',
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c.replace('{idProposta}', idProposta).replace('{cpf}', cpf),
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Finalizar Simulação de Refinanciamento', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{idProposta}', idProposta).replace('{cpf}', cpf),
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputFimSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputFimSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('422') || status.equalsIgnoreCase('404')) {
            retorno = (OutputFimSimulacaoRefinanciamento) System.JSON.deserialize(objHttpResponse.getBody(), OutputFimSimulacaoRefinanciamento.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputGetDadosBancarios GetDadosBancariosDesembolso(String cpf, String canal, String unidadeNegocio, String idProposta){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetDadosBancariosDesembolso');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputGetDadosBancarios retorno = new OutputGetDadosBancarios();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{idProposta}', idProposta), 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'Content-Type' => 'application/json',
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c
            }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Obter Dados Bancarios Desembolso', 
            config.Endpoint__c + config.Path__c.replace('{idProposta}', idProposta), 
            config.Method__c, 
            config.Body__c,
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno = (OutputGetDadosBancarios) System.JSON.deserialize(objHttpResponse.getBody(), OutputGetDadosBancarios.class);
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('404')) {
            retorno = (OutputGetDadosBancarios) System.JSON.deserialize(objHttpResponse.getBody(), OutputGetDadosBancarios.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

    public static OutputGravarDadosBancariosAlternativos GravarDadosBancariosAlternativos(String cpf, String canal, String unidadeNegocio, String idProposta, String instituicaoBancariaAlternativa, String agenciaBancariaAlternativa, String contaBancariaAlternativa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GravarDadosBancariosAlternativos');
        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = (userDRT.DRT__c == null || userDRT.DRT__c == 'X')? cpf : userDRT.DRT__c;
        OutputGravarDadosBancariosAlternativos retorno = new OutputGravarDadosBancariosAlternativos();
        retorno.StatusAPI = 'ERROR';

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            new Map<String, String> {
                'Authorization' => 'Bearer '+ TokenCSFServicos.GetToken(canal).access_token,
                'Content-Type' => 'application/json',
                'canal' => canal,
                'loginOperador' => loginOperador,
                'x-uat' => config.UAT__c == null ? '' : config.UAT__c

            }, 
            config.Body__c.replace('{idProposta}', idProposta)
                .replace('{codBanco}', instituicaoBancariaAlternativa)
                .replace('{agencia}', agenciaBancariaAlternativa)
                .replace('{conta}', contaBancariaAlternativa),
            Integer.valueof(config.Timeout__c)
        );
        String status = String.valueOf(objHttpResponse.getStatusCode());

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Gravar Dados Bancarios Alternativos', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c.replace('{idProposta}', idProposta)
                .replace('{codBanco}', instituicaoBancariaAlternativa)
                .replace('{agencia}', agenciaBancariaAlternativa)
                .replace('{conta}', contaBancariaAlternativa),
            cpf,                               
            status, 
            objHttpResponse.getBody(),
            unidadeNegocio,
            canal.capitalize()
        );   

        if(status.equalsIgnoreCase('200') || status.equalsIgnoreCase('204')){
            retorno.StatusAPI = 'OK';
        }else if (status.equalsIgnoreCase('422') || status.equalsIgnoreCase('404')) {
            retorno = (OutputGravarDadosBancariosAlternativos) System.JSON.deserialize(objHttpResponse.getBody(), OutputGravarDadosBancariosAlternativos.class);
            retorno.StatusAPI = 'ERROR MESSAGE';
        }

        return retorno;
    }

// #################### RESPONSE REFERENTE AO MÉTODO 'GetDadosContratoOriginal' #################### 
    public class OutputDadosContratoOriginal{
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String StatusAPI;
        @AuraEnabled
        public String statusContrato;
        @AuraEnabled
        public String dataLiquidacao;
        @AuraEnabled
        public Decimal valorContratado;
        @AuraEnabled
        public String dataContratacao;
        @AuraEnabled
        public Decimal valorLiberado;
        @AuraEnabled
        public Integer diasAtraso;
        @AuraEnabled
        public Decimal valorPago;
        @AuraEnabled
        public Decimal valorParcelaContratado;
        @AuraEnabled
        public Decimal valorPresenteContrato;
        @AuraEnabled
        public Integer quantidadeTotalParcelas;
        @AuraEnabled
        public Integer numeroContrato;
        @AuraEnabled
        public Integer quantidadeParcelasPagas;
        @AuraEnabled
        public String dataVencimentoPrimeiraParcela;
        @AuraEnabled
        public String dataVencimentoUltimaParcela;
        @AuraEnabled
        public Decimal taxaJurosMensal;
        @AuraEnabled
        public Decimal taxaJurosAnual;
        @AuraEnabled
        public Decimal custoEfetivoTotalMensal;
        @AuraEnabled
        public Decimal custoEfetivoTotalAnual;
        @AuraEnabled
        public Decimal iof;
    }
// #################### FIM RESPONSE 'GetDadosContratoOriginal' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'CriarPropostaRefinanciamento' #################### 
    public class OutputPropostaRefinanciamento{
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String StatusAPI;
        @AuraEnabled
        public String idProposta;
    }
// #################### FIM RESPONSE 'CriarPropostaRefinanciamento' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'CalcularSimulacaoRefinanciamento' #################### 
    public class OutputCalcularSimulacaoRefinanciamento {
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String StatusAPI;
		@AuraEnabled
        public Decimal valorSaldoDevedor;
		@AuraEnabled
        public Decimal valorParcelaAtual;
		@AuraEnabled
        public Decimal totalParcelas;
		@AuraEnabled
        public Decimal parcelaPagas;
		@AuraEnabled
        public Decimal taxa;
		@AuraEnabled
        public Decimal vlrMargem;
		@AuraEnabled
        public List<Simulacoes> simulacoes;
	}
    
	public class Simulacoes {
		@AuraEnabled
        public TaxasDetalhadas taxasDetalhadas;
		@AuraEnabled
        public Resumo resumo;
	}

	public class TaxasDetalhadas {
		@AuraEnabled
        public TaxasCobradas taxasCobradas;
		@AuraEnabled
        public DespesasVinculadas despesasVinculadas;
		@AuraEnabled
        public JurosCet jurosCet;
	}

	public class Resumo {
		@AuraEnabled
        public String mensagem;
		@AuraEnabled
        public Decimal novoValorEmprestimo;
		@AuraEnabled
        public Decimal valorEmprestimoPercentual;
		@AuraEnabled
        public Decimal parcela;
		@AuraEnabled
        public Decimal novaTaxa;
		@AuraEnabled
        public Decimal iofTotal;
		@AuraEnabled
        public Decimal custoEfetivoTotal;
		@AuraEnabled
        public Decimal valorTroco;
		@AuraEnabled
        public Decimal valorFinanciado;
		@AuraEnabled
        public Integer prazo;
	}

    public class TaxasCobradas {
		@AuraEnabled
        public Decimal valorTotalPagar;
		@AuraEnabled
        public Decimal valorTotalReceber;
		@AuraEnabled
        public Decimal valorTotalReceberPercentual;
		@AuraEnabled
        public Decimal despesasVinculadas;
		@AuraEnabled
        public Decimal despesasVinculadasPercentual;
	}

    public class DespesasVinculadas {
		// @AuraEnabled
        // public Decimal iofTotal;
		@AuraEnabled
        public Decimal iofTotalPercentual;
		@AuraEnabled
        public Decimal iofAdicional;
		@AuraEnabled
        public String iofAdicionalPercentual;
		@AuraEnabled
        public Decimal iofDiario;
		@AuraEnabled
        public String iofDiarioPercentual;
		@AuraEnabled
        public Decimal encargos;
		@AuraEnabled
        public String encargosPercentual;
		@AuraEnabled
        public String tarifas;
		@AuraEnabled
        public String seguros;
	}

	public class JurosCet {
		@AuraEnabled
        public Decimal taxaJuros;
		@AuraEnabled
        public Decimal taxaJurosAnual;
		@AuraEnabled
        public Decimal valorJurosMensal;
		@AuraEnabled
        public Decimal cetMaximoCustoEfetivoTotalAnual;
		@AuraEnabled
        public Decimal cetMaximoCustoEfetivoTotalMensal;
	}
// #################### FIM RESPONSE 'CalcularSimulacaoRefinanciamento' ####################

// #################### BODY REQUEST REFERENTE AO MÉTODO 'GravarSimulacaoRefinanciamento' ####################
    public class BodyRequestGravarSimulacao{
        public String propostaId;
        public Decimal valorTotalReceber;
        public Integer quantidadeParcelas;
        public Decimal valorParcelas;
        public Decimal valorTotalPagar;
        public Decimal cetAnualPercentual;
        public Decimal cetMensalPercentual;
        public Decimal despesasVinculadas;
        public Decimal despesasVinculadasPercentual;
        public Decimal encargos;
        public Decimal encargosPercentual;
        public Decimal valorIofAdicional;
        public Decimal iofAdicionalPercentual;
        public Decimal valorIofDiario;
        public Decimal iofDiarioPercentual;
        public Decimal seguros;
        public Decimal valorIofTotal;
        public Decimal valorJuros;
        public Decimal valorJurosMensal;
        public Decimal valorEmprestimoPercentual;
        public Decimal tarifas;
        public Decimal taxaJurosMensal;
        public Decimal taxaJurosAnual;
        public Decimal valorSaldoDevedor;
        public Decimal valorPrincipal;
        public Decimal valorTroco;
        public Decimal valorFinanciado;
    }
// #################### FIM BODY REQUEST 'GravarSimulacaoRefinanciamento' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'GravarSimulacaoRefinanciamento' ####################
    public class OutputGravarSimulacaoRefinanciamento {
        @AuraEnabled
        public String mensagem;
        @auraEnabled
        public String StatusAPI;
        @auraEnabled
        public String ufBeneficio;
        @auraEnabled
        public Decimal custoEfetivoTotalMensal;
        @auraEnabled
        public Documento documento;
        @auraEnabled
        public Integer prazo;
        @auraEnabled
        public Decimal iofAdicional;
        @auraEnabled
        public Integer nroSolicitacao;
        @auraEnabled
        public Decimal valorLiberado;
        @auraEnabled
        public Decimal valorTotal;
        @auraEnabled
        public Decimal taxaMensal;
        @auraEnabled
        public Integer codigoConvenio;
        @auraEnabled
        public String dataInicio;
        @auraEnabled
        public Decimal iofNormal;
        @auraEnabled
        public String dataUltimoVencimento;
        @auraEnabled
        public DadosContaLiberacao dadosContaLiberacao;
        @auraEnabled
        public String nomeBeneficiario;
        @auraEnabled
        public Decimal custoEfetivoTotalAnual;
        @auraEnabled
        public Integer numeroContrato;
        @auraEnabled
        public Decimal jurosAnual;
        @auraEnabled
        public Decimal valorPrincipal;
        @auraEnabled
        public Decimal iofValorTotal;
        @auraEnabled
        public String codigoBeneficio;
        @auraEnabled
        public Integer codigoCliente;
        @auraEnabled
        public Decimal jurosValorTotal;
        @auraEnabled
        public Integer codigoProduto;
        @auraEnabled
        public String dataPrimeiroVencimento;
        @auraEnabled
        public Decimal valorFinanciado;
        @auraEnabled
        public Decimal valorSaldoDevedor;
    }
    public class Documento {
        @auraEnabled 
        public String numeroDocumento;
        @auraEnabled
        public String tipoDocumento;
    }
    
    public class DadosContaLiberacao {
        @auraEnabled
        public String digitoAgencia;
        @auraEnabled
        public String digitoConta;
        @auraEnabled
        public String numeroConta;
        @auraEnabled
        public String banco;
        @auraEnabled
        public String tipoCreditoConta;
        @auraEnabled
        public String codigoAgencia;
    }
// #################### FIM RESPONSE 'GravarSimulaçãoRefinanciamento' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'FinalizarSimulacaoRefinanciamento' ####################
    public class OutputFimSimulacaoRefinanciamento{
        @AuraEnabled
        public String mensagem;
        @auraEnabled
        public String StatusAPI;
        @auraEnabled
        public String link;
    }
// #################### FIM RESPONSE 'FinalizarSimulacaoRefinanciamento' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'GetDadosBancariosDesembolso' ####################
    public class OutputGetDadosBancarios{
        @AuraEnabled
        public String mensagem;
        @AuraEnabled
        public String StatusAPI;
        @AuraEnabled
        public String conta;
        @AuraEnabled
        public String cpf;
        @AuraEnabled
        public String banco;
        @AuraEnabled
        public Integer contrato;
        @AuraEnabled
        public String nome;
        @AuraEnabled
        public String estadoSpb;
        @AuraEnabled
        public String agencia; 
    }
// #################### FIM RESPONSE 'GetDadosBancariosDesembolso' ####################

// #################### RESPONSE REFERENTE AO MÉTODO 'GravarDadosBancariosAlternativos' ####################
    public class OutputGravarDadosBancariosAlternativos{
        @AuraEnabled
        public String mensagem;
        @auraEnabled 
        public String StatusAPI;
    }
// #################### FIM RESPONSE 'GravarDadosBancariosAlternativos' ####################
}