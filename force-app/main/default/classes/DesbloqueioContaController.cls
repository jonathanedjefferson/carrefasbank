public class DesbloqueioContaController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getCartaoTitular(String contaFinanceiraId){
        return AssetBO.getAssetTitular(contaFinanceiraId);
    }

    @AuraEnabled
    public static DesbloqueioConta.Output  DesbloquearConta(String cpf, String numeroConta, String idEmpresa, String canal, String area, String sistema){
        return DesbloqueioConta.DesbloquearConta(cpf, numeroConta, idEmpresa, canal, area, sistema);
    }

    @AuraEnabled
    public static Case createCaseDesbloqueioConta(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Desbloqueio', 
        'Desbloqueio de conta', 'Execução', 'Medium', canal, origem, 
        contaFinanceiraId, accountId, unidadeNegocio);
    }
}