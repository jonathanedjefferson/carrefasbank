public without sharing class DesbloqueioSenhaCartaoController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static List<DesbloqueioSenhaCartao.CartoesDesbloqueioSenha> GetListaCartaoDesbloqueioSenha(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema){
        DesbloqueioSenhaCartao.OutputListarCartaoDesbloqueioSenha toReturn = DesbloqueioSenhaCartao.ListarCartaoDesbloqueioSenha(cpf, numeroConta, idEmpresa, canal, area, sistema);
        return toReturn.cartoesDesbloqueioSenha;
    }

    @AuraEnabled
    public static List<DesbloqueioSenhaCartao.SenhaCartaoDesbloqueada> DesbloquearSenhaCartao(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema, List<String> listaCartoesSerno){
        DesbloqueioSenhaCartao.OutputDesbloquearSenhaCartao toReturn = DesbloqueioSenhaCartao.DesbloquearSenhaCartao(cpf, numeroConta, idEmpresa, canal, area, sistema, listaCartoesSerno);
        return toReturn.senhaCartaoDesbloqueada;
    }

    @AuraEnabled
    public static Case createCaseDesbloqueioSenhaCartao(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Senha', 
        'Desbloqueio de senha', 'Execução', 'Medium', canal, origem, 
        contaFinanceiraId, accountId, unidadeNegocio);
    }
}