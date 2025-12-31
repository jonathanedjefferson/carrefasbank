public without sharing class BCSF_SegundaViaFaturaController {
    @AuraEnabled
    public static List<BCSF_SegundaViaFaturaBO.OutputUltimosVencimentosFechados> getListaFaturas(String numeroConta, String idEmpresa, String cpf, String canal){
        return BCSF_SegundaViaFaturaBO.getListaFaturas(numeroConta, idEmpresa, cpf, canal);
    }
    @AuraEnabled
    public static Boolean enviarFaturas(String idEmpresa, String sistema, String canal, String area, String cpf, String numeroConta, String email, List<List<String>> listFaturas){
        Map<String, String> MapIdDateFaturas = new Map<String, String>();

        for (List<String> lista : listFaturas) {
            MapIdDateFaturas.put(lista[0], lista[1]);
        }

        return IntegracoesFaturas.EnvioMultiplasFaturasPorEmail(idEmpresa, sistema, canal, area, cpf, numeroConta, email, MapIdDateFaturas);
    }
    @AuraEnabled
    public static Case createCase(String contaFinanceiraId, String accountId, String unidadeNegocio, String origem, String canalEntrada, String motivo, String motivoDescricao){
        return BCSF_SegundaViaFaturaBO.createCase(contaFinanceiraId, accountId, unidadeNegocio, origem, canalEntrada, motivo, motivoDescricao);
    }
}