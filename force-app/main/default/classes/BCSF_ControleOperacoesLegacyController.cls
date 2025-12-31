public without sharing class BCSF_ControleOperacoesLegacyController {

    @AuraEnabled
    public static IntegracaoControleOperacoesLegacy.OutputListaLojas listagemHierarquias(String cpf, String canal, String idEmpresa) {
        return IntegracaoControleOperacoesLegacy.listagemHierarquias(cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoControleOperacoesLegacy.OutputListaTipoEventos listagemTipoEventos(String cpf, String canal, String idEmpresa) {
        return IntegracaoControleOperacoesLegacy.listagemTipoEventos(cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static IntegracaoControleOperacoesLegacy.OutputConsultarOperacoes consultarOperacoes(String bodyJson, String cpf, String canal, String idEmpresa) {
        return IntegracaoControleOperacoesLegacy.consultarOperacoes(bodyJson, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static Account getAccount(List<String> cpfList) {
        List<Account> retorno = AccountDAO.getAccountsByCPF(cpfList);
        return retorno.isEmpty() ? null : retorno[0];
    }
}