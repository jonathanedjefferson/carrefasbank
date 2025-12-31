public with sharing class CreditoPessoalController {
    
    @AuraEnabled
    public static CreditoPessoalTO.ConsultaContratos consultarContratos(String canal, String cpf, String unidadeNegocio, String numeroConta) {
        return CreditoPessoal.consultarContratos(canal, cpf, unidadeNegocio, numeroConta);
    }

    @AuraEnabled
    public static CreditoPessoalTO.ConsultaProposta consultarProposta(String canal, String cpf, String unidadeNegocio, Long idProposta) {
        return CreditoPessoal.consultarProposta(canal, cpf, unidadeNegocio, idProposta);
    }

    @AuraEnabled
    public static CreditoPessoalTO.EnvioTermo enviarTermoAdesao(String canal, String cpf, String unidadeNegocio, Long idProposta, String emailCliente) {
        return CreditoPessoal.enviarTermoAdesao(canal, cpf, unidadeNegocio, idProposta, emailCliente);
    }

    @AuraEnabled
    public static CreditoPessoalTO.ConsultaBancos obterBancos(String canal, String cpf, String unidadeNegocio) {
        return CreditoPessoal.obterBancos(canal, cpf, unidadeNegocio);
    }

    @AuraEnabled
    public static CreditoPessoalTO.AlteracaoDadosBancarios alterarDadosBancarios(String canal, String cpf, String unidadeNegocio, String numeroConta, Long idProposta, CreditoPessoalTO.DadosBancarios dadosBancarios, CreditoPessoalTO.ContratoRejeitado contratoRejeitado) {
        return CreditoPessoal.alterarDadosBancarios(canal, cpf, unidadeNegocio, numeroConta, idProposta, dadosBancarios, contratoRejeitado);
    }

    @AuraEnabled
    public static CreditoPessoalTO.ConsultaCliente consultarCliente(String canal, String cpf, String unidadeNegocio, String numeroConta) {
        return CreditoPessoal.consultarCliente(canal, cpf, unidadeNegocio, numeroConta);
    }

    @AuraEnabled
    public static CreditoPessoalTO.DadosSimulacao iniciarProposta(String canal, String cpf, String unidadeNegocio, String numeroConta, String valorPreAprovado, String valorSolicitado, String origem) {
        CreditoPessoalTO.DadosSimulacao toReturn = new CreditoPessoalTO.DadosSimulacao();
        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        if(token == null || token.access_token == null){
            toReturn.statusAPI = 'ERROR';
        } else {
            CreditoPessoalTO.IniciarProposta resultIniciarProposta = CreditoPessoal.iniciarProposta(canal, cpf, unidadeNegocio, numeroConta, valorPreAprovado, valorSolicitado, origem, token);
            
            if(resultIniciarProposta != null && resultIniciarProposta.statusAPI == 'OK'){
                CreditoPessoalTO.ConsultaElegibilidadeCliente resultConsultaElegibilidade = 
                    CreditoPessoal.consultarElegibilidadeCliente(canal, cpf, unidadeNegocio, numeroConta, resultIniciarProposta.idProposta, token);

                if(resultConsultaElegibilidade != null && resultConsultaElegibilidade.statusAPI == 'OK'){ 
                    if(resultConsultaElegibilidade.resultado){
                        toReturn = efetuarSimulacao(canal, cpf, unidadeNegocio, numeroConta, resultIniciarProposta.idProposta, valorPreAprovado, token); 
                    } else {
                        toReturn.statusAPI = 'NAO_ELEGIVEL';
                    }
                } else {
                    toReturn.statusAPI = 'ERROR';
                }
                
            } else {
                toReturn.statusAPI = 'ERROR';
            }
        }

        return toReturn;
    }

    @AuraEnabled
    public static CreditoPessoalTO.DadosSimulacao efetuarSimulacao(String canal, String cpf, String unidadeNegocio, String numeroConta, String idProposta, String valorSolicitado, TokenCSFServicos.ResponseToken token) {
        CreditoPessoalTO.DadosSimulacao toReturn = new CreditoPessoalTO.DadosSimulacao();

        CreditoPessoalTO.EfetuarSimulacao resultEfetuarSimulacao;
        if(token == null){
            resultEfetuarSimulacao = CreditoPessoal.efetuarSimulacao(canal, cpf, unidadeNegocio, numeroConta, idProposta, valorSolicitado);
        } else {
            resultEfetuarSimulacao = CreditoPessoal.efetuarSimulacaoInicial(canal, cpf, unidadeNegocio, numeroConta, idProposta, valorSolicitado, token);
        }

        if(resultEfetuarSimulacao.statusAPI == 'OK'){
            List<CreditoPessoalTO.PlanoParcelamento> planosComSeguro = new List<CreditoPessoalTO.PlanoParcelamento>();
            List<CreditoPessoalTO.PlanoParcelamento> planosSemSeguro = new List<CreditoPessoalTO.PlanoParcelamento>();
            if(resultEfetuarSimulacao.planos != null && resultEfetuarSimulacao.planos.size() > 0){
                Boolean setMaiorParcelamentoComSeguro = true;
                Boolean setMaiorParcelamentoSemSeguro = true;
                for(CreditoPessoalTO.PlanoParcelamento plano : resultEfetuarSimulacao.planos){
                    if(plano.cetAnual != null){
                        plano.cetAnualFormatado = plano.cetAnual + '';
                        plano.cetAnualFormatado = plano.cetAnualFormatado.replace('.', ',');
                    }
                    if(plano.valorParcela != null){
                        plano.valorParcelaFormatado = 'R$ ' + StringUtils.getCurrencyFormat(plano.valorParcela);
                    }
                    if(plano.juros != null){
                        plano.jurosFormatado = StringUtils.getPorcentFormat(plano.juros);
                    }
                    if(plano.valorSeguro == 0){
                        plano.isSelected = setMaiorParcelamentoSemSeguro;
                        setMaiorParcelamentoSemSeguro = false;
                        planosSemSeguro.add(plano);
                    } else {
                        plano.isSelected = setMaiorParcelamentoComSeguro;
                        setMaiorParcelamentoComSeguro = false;
                        planosComSeguro.add(plano);
                    }
                }
            }

            toReturn.statusAPI = 'OK';
            toReturn.planosComSeguro = planosComSeguro;
            toReturn.planosSemSeguro = planosSemSeguro;
            toReturn.quantidadeParcelasMaxima = resultEfetuarSimulacao.quantidadeParcelasMaxima;
            toReturn.quantidadeParcelasMinima = resultEfetuarSimulacao.quantidadeParcelasMinima;
            toReturn.idProposta = idProposta;
        } else {
            toReturn.statusAPI = 'ERROR';
        }

        return toReturn;
    }

    @AuraEnabled
    public static CreditoPessoalTO.SalvarSimulacao salvarSimulacao(String canal, String cpf, String unidadeNegocio, String numeroConta, String idProposta, String valorSolicitado, String planoSimulacao) {
        return CreditoPessoal.salvarSimulacao(canal, cpf, unidadeNegocio, numeroConta, idProposta, valorSolicitado, planoSimulacao);
    }

    @AuraEnabled
    public static CreditoPessoalTO.SalvarDadosBancarios salvarDadosBancarios(String canal, String cpf, String unidadeNegocio, String numeroConta, String idProposta, String dadosBancarios) {
        CreditoPessoalTO.SalvarDadosBancarios toReturn = new CreditoPessoalTO.SalvarDadosBancarios();

        TokenCSFServicos.ResponseToken token = TokenCSFServicos.GetTokenV2(canal);
        if(token == null || token.access_token == null){
            toReturn.statusAPI = 'ERROR';
        } else {
            CreditoPessoalTO.ValidarDadosBancarios resultValidarDadosBancarios = CreditoPessoal.validarDadosBancarios(canal, cpf, unidadeNegocio, numeroConta, dadosBancarios, token);
            if(resultValidarDadosBancarios != null && resultValidarDadosBancarios.statusAPI == 'OK'){
                toReturn.valido = resultValidarDadosBancarios.valido;
                if(!toReturn.valido){
                    return toReturn;
                }
                dadosBancarios = dadosBancarios.replace('codigoBanco', 'codBanco').replace('conta', 'numeroConta');
                toReturn = CreditoPessoal.salvarDadosBancarios(canal, cpf, unidadeNegocio, numeroConta, idProposta, dadosBancarios, token);
                toReturn.valido = true;
            } else {
                toReturn.statusAPI = resultValidarDadosBancarios.statusAPI;
            }
        }
        
        return toReturn;
    }

    @AuraEnabled
    public static CreditoPessoalTO.Contratacao contratacao(String canal, String cpf, String unidadeNegocio, String numeroConta, 
        String idProposta, String plano, String dadosBancarios, String origemAdesao) {
        return CreditoPessoal.contratacao(canal, cpf, unidadeNegocio, numeroConta, idProposta, plano, dadosBancarios, origemAdesao);
    }

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira obterContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static Case criarCaso(Map<String, Object> inputs){
        return CreditoPessoalBO.criarCaso(inputs);
    }
    
    @AuraEnabled
    public static List<ChaveLigaDesligaBO.ChaveTO> obterChaveLigaDesliga(String prefix){
        return ChaveLigaDesligaBO.getChaveLigaDesligaLike(prefix);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getAssetTitular(String idContaFinanceira) {
        return AssetBO.getAssetTitular(idContaFinanceira);
    }

    @AuraEnabled
    public static CreditoPessoalTO.Cancelamento cancelamento(String idProposta, String cpf, String unidadeNegocio, String canal) {
        return CreditoPessoal.cancelamento(idProposta, cpf, unidadeNegocio, canal);
    }

}