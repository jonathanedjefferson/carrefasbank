public class ContactlessController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static List<AssetBO.AssetTO> getCartaoesContactlessEnabled(String recordId){
        return AssetBO.getAllAssetsByStatus(recordId, 'NORM');
    }

    @AuraEnabled
    public static Contactless.Output  ContactlessBuscarStatus(String cpf, String numeroConta, String idCartao, String idEmpresa, String canal, String area, String sistema){
        Contactless.Output toReturn = Contactless.ContactlessBuscarStatus(cpf, numeroConta, idCartao, idEmpresa, canal, area, sistema);
        return toReturn;
    }

    @AuraEnabled
    public static Contactless.Output ContactlessAlterarStatus(String cpf, String numeroConta, String idCartao, String primeirosDigitosCartao, String ultimosDigitosCartao, String status, String idEmpresa, String canal, String area, String sistema){
        Contactless.Output toReturn = Contactless.ContactlessAlterarStatus(cpf, numeroConta, idCartao, primeirosDigitosCartao, ultimosDigitosCartao, status, idEmpresa, canal, area, sistema);
        return toReturn;
    }

    @AuraEnabled
    public static Case createCaseAlterarStatusContactless(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String evento){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        // Contactless = Pagamento por aproximação. Esse evento foi renomeado.
        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Contactless', 
        evento, 'Execução', 'Medium', canal, origem, 
        contaFinanceiraId, accountId, unidadeNegocio);
    }
    
}