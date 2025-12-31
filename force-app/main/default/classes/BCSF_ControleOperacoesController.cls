public without sharing class BCSF_ControleOperacoesController {

    @AuraEnabled
    public static integracaoControleOperacoes.OutputListaLojas listagemHierarquias(String cpf, String canal, String idEmpresa) {
        return integracaoControleOperacoes.listagemHierarquias(cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static integracaoControleOperacoes.OutputListaTipoEventos listagemTipoEventos(String cpf, String canal, String idEmpresa) {
        return integracaoControleOperacoes.listagemTipoEventos(cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static integracaoControleOperacoes.OutputConsultarOperacoes consultarOperacoes(String bodyJson, String cpf, String canal, String idEmpresa) {
        return integracaoControleOperacoes.consultarOperacoes(bodyJson, cpf, canal, idEmpresa);
    }

    @AuraEnabled
    public static Account getAccount(List<String> cpfList) {
        List<Account> retorno = AccountDAO.getAccountsByCPF(cpfList);
        return retorno.isEmpty() ? null : retorno[0];
    }
}