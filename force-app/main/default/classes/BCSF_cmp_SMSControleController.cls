public without sharing class BCSF_cmp_SMSControleController {
    
    @AuraEnabled()
    public static ContaFinanceira__c getContaFinanceira(String IdConta) {
        return ContaFinanceiraDAO.getInstance().getDadosContaFinanceira(IdConta);
    }

    @AuraEnabled()
    public static Asset getCartao(String IdConta) {
        return AssetDAO.getInstance().getAssetTitular(IdConta);
    }

    @AuraEnabled()
    public static IntegracaoSMSControleTotal.OutputConsultarContrato consultarContratos(String input) {
        IntegracaoSMSControleTotal.InputClass inputObj = (IntegracaoSMSControleTotal.InputClass) System.JSON.deserialize(input, IntegracaoSMSControleTotal.InputClass.class);
        return IntegracaoSMSControleTotal.consultarContratos(inputObj);
    }

    @AuraEnabled()
    public static String adesaoContrato(String input) {
        IntegracaoSMSControleTotal.InputClass inputObj = (IntegracaoSMSControleTotal.InputClass) System.JSON.deserialize(input, IntegracaoSMSControleTotal.InputClass.class);
        return IntegracaoSMSControleTotal.adesaoContrato(inputObj);
    }

    @AuraEnabled()
    public static Boolean cancelarContrato(String input) {
        IntegracaoSMSControleTotal.InputClass inputObj = (IntegracaoSMSControleTotal.InputClass) System.JSON.deserialize(input, IntegracaoSMSControleTotal.InputClass.class);
        return IntegracaoSMSControleTotal.cancelarContrato(inputObj);
    }

    @AuraEnabled()
    public static IntegracaoSMSControleTotal.OutputMotivos motivosCancelamento(String cpfCliente, String canal, String idEmpresa) {
        return IntegracaoSMSControleTotal.motivosCancelamento(cpfCliente, canal, idEmpresa);
    }
    
    @AuraEnabled
    public static Case criarCaso(String telefone, String contaFinanceiraId, String accountId, String evento, String unidadeNegocio, String cpf, String origem, String canal, String descricao, String motivoCancelar) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Case cs = new Case();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio; 
        cs.Origin = origem;
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';
        cs.Assunto__c = 'SMS Controle Total';
        cs.Evento__c = evento;
        cs.Status = 'Closed';
        cs.Type = 'Execução';
        cs.OwnerId = UserInfo.getUserId();
        cs.MotivoCancelamento__c = motivoCancelar;
        cs.description = descricao;
        cs.CPFContato__c = cpf;
        cs.Telefone__c = telefone;
        cs.CriarCasoPorComponente__c = true;

        return CasoDAO.getInstance().insertCase(cs);
    }

}