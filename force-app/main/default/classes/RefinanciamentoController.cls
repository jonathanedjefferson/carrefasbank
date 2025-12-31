public without sharing class RefinanciamentoController {
    @AuraEnabled
    public static RefinanciamentoBO.ContaFinanceiraTO GetContaFinanceira(String contaFinanceiraId){
        return RefinanciamentoBO.tratarContaFinanceira(contaFinanceiraId);
    }
    
    @AuraEnabled
    public static IntegrationConsignado.OutputDadosContratoOriginal GetDadosContratoOriginal(String canal, String cpf, String numeroContrato, String unidadeNegocio){
        return IntegrationConsignado.GetDadosContratoOriginal(canal, cpf, numeroContrato, unidadeNegocio);
    }
    
    @AuraEnabled
    public static IntegrationConsignado.OutputPropostaRefinanciamento CriarPropostaRefinanciamento(String cpf, String canal, String unidadeNegocio, String email, String numeroContrato){
        return IntegrationConsignado.CriarPropostaRefinanciamento(cpf, canal, unidadeNegocio, email, numeroContrato);
    }
    
    @AuraEnabled
    public static RefinanciamentoBO.OutputCalcularSimulacaoRefinanciamento CalcularSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String idProposta, Boolean usarMargem, Boolean receberTroco, Integer quantidadeParcelas, Decimal valorTroco){
        return RefinanciamentoBO.CalcularSimulacaoRefinanciamento(cpf, canal, unidadeNegocio, idProposta, usarMargem, receberTroco, quantidadeParcelas, valorTroco);
    }

    @AuraEnabled
    public static IntegrationConsignado.OutputGravarSimulacaoRefinanciamento GravarSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String bodyRequestJson){
        IntegrationConsignado.BodyRequestGravarSimulacao bodyRequest = (IntegrationConsignado.BodyRequestGravarSimulacao) System.JSON.deserialize(bodyRequestJson, IntegrationConsignado.BodyRequestGravarSimulacao.class);
        return IntegrationConsignado.GravarSimulacaoRefinanciamento(cpf, canal, unidadeNegocio, bodyRequest);
    }
    
    @AuraEnabled
    public static IntegrationConsignado.OutputFimSimulacaoRefinanciamento FinalizarSimulacaoRefinanciamento(String cpf, String canal, String unidadeNegocio, String idProposta){
        return IntegrationConsignado.FinalizarSimulacaoRefinanciamento(cpf, canal, unidadeNegocio, idProposta);
    }
    
    @AuraEnabled
    public static IntegrationConsignado.OutputGetDadosBancarios GetDadosBancariosDesembolso(String cpf, String canal, String unidadeNegocio, String idProposta){
        return IntegrationConsignado.GetDadosBancariosDesembolso(cpf, canal, unidadeNegocio, idProposta);
    }
    
    @AuraEnabled
    public static IntegrationConsignado.OutputGravarDadosBancariosAlternativos GravarDadosBancariosAlternativos(String cpf, String canal, String unidadeNegocio, String idProposta, String instituicaoBancariaAlternativa, String agenciaBancariaAlternativa, String contaBancariaAlternativa){
        return IntegrationConsignado.GravarDadosBancariosAlternativos(cpf, canal, unidadeNegocio, idProposta, instituicaoBancariaAlternativa, agenciaBancariaAlternativa, contaBancariaAlternativa);
    }

    @AuraEnabled
    public static case CriarCaso(String contaFinanceiraId, String accountId, String unidadeNegocio,  String origem, String canal){
        return RefinanciamentoBO.CriarCaso(contaFinanceiraId, accountId, unidadeNegocio, origem, canal);
    }

    @AuraEnabled
    public static Consignado__c CriarConsignado(String contaFinanceiraId, String accountId, String caseId,  String unidadeNegocio, String inputInfoConsignado, String telefone){
        return RefinanciamentoBO.CriarConsignado(contaFinanceiraId, accountId, caseId,  unidadeNegocio, inputInfoConsignado, telefone);
    }
}