public class BCSF_CLS_CalloutFaturasController {

    @AuraEnabled
    public static String buscarFaturaAberta(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){
        return BCSF_CLS_CalloutFaturasV1.buscarFaturaAberta(numeroConta, cpfCliente, unidadeNegocio, canal);
    }

    @AuraEnabled
    public static String buscarFaturaFechada(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){  
        return BCSF_CLS_CalloutFaturasV1.buscarFaturaFechada(numeroConta, cpfCliente, unidadeNegocio, canal);
    }

    @AuraEnabled
    public static List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> buscarDetalhesFatura(String numeroConta, String dataVencimento, String cpfCliente, String unidadeNegocio, String canal){
        return BCSF_CLS_CalloutFaturasV1.buscarDetalhesFatura(numeroConta, dataVencimento, cpfCliente, unidadeNegocio, canal);
    }

    @AuraEnabled
    public static List<BCSF_CLS_CalloutFaturasTO.DetalhesFatura> buscarDetalhesFaturaAberta(String numeroConta, String cpfCliente, String unidadeNegocio, String canal){
        return BCSF_CLS_CalloutFaturasV1.buscarDetalhesFaturaAberta(numeroConta, cpfCliente, unidadeNegocio, canal);
    }

    @AuraEnabled
    public static Case criaOuVinculaCaso(String detalhesEstornoJson, String faturasSelecionadasJson){
        return BCSF_CLS_CalloutFaturasBO.criaOuVinculaCaso(detalhesEstornoJson, faturasSelecionadasJson);
    }

    @AuraEnabled
    public static Boolean verificaAlcada(String areaPrincipal){
        return BCSF_CLS_CalloutFaturasBO.verificaAlcada(areaPrincipal);
    }

    @AuraEnabled
    public static List<ChaveLigaDesligaBO.ChaveTO> getAllButtonsFatura(){
        return ChaveLigaDesligaBO.getChaveLigaDesligaLike('buttonFaturas_%');
    }

    @AuraEnabled
    public static BCSF_CLS_CalloutFaturasV1.outputDownloadFatura downloadFatura(String numeroConta, String unidadeNegocio,String idFatura, String cpfCliente, String canal){  
        return BCSF_CLS_CalloutFaturasV1.getFatura(numeroConta, unidadeNegocio, idFatura, cpfCliente, canal);
    }

    @AuraEnabled
    public static BCSF_CLS_CalloutFaturasV1.outputDownloadFatura downloadFaturaEncripted(String numeroConta, String unidadeNegocio,String idFatura, String cpfCliente, String canal){  
        return BCSF_CLS_CalloutFaturasV1.getFaturaEncripted(numeroConta, unidadeNegocio, idFatura, cpfCliente, canal);
    }

    @AuraEnabled
    public static List<BCSF_CLS_CalloutFaturasV1.OutputUltimosVencimentosFechados> getListaFaturas(String numeroConta, String unidadeNegocio, String cpfCliente, String canal){
        return BCSF_CLS_CalloutFaturasV1.UltimosVencimentosFechados(numeroConta, unidadeNegocio, cpfCliente, canal);
    }

    @AuraEnabled
    public static BCSF_CLS_CalloutFaturasV1.OutPutGetExtratoCompacto getExtratoCompacto(String numeroConta, String unidadeNegocio, String cpf, String canal){
        return BCSF_CLS_CalloutFaturasV1.getExtratoCompacto(numeroConta, unidadeNegocio, cpf, canal);
    }

    @AuraEnabled
    public static AcordoDivida.OutputConsultarSituacaoAcordo consultarSituacaoAcordo(String unidadeNegocio, String cpf, String canal){
        return AcordoDivida.ConsultarSituacaoAcordo(cpf, unidadeNegocio, canal);
    }
}