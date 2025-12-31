public with sharing class BCSF_AtivarInativarCartaoBO {
    public static Case createCase(String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String canal, String Tipo){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        Case cs = new Case();
        cs.OwnerId = UserInfo.getUserId();
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = Tipo == 'Ativar' ? 'Desbloqueio' : 'Bloqueio';
        cs.Evento__c = Tipo == 'Ativar' ? 'Ativação de cartão de crédito': 'Inativação de cartão de crédito';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canal;
        cs.Priority = 'Medium';

        insert cs;
        
        return CaseDAO.getInstance().getById(cs.Id);
    }

    public static List<IdentificaCockpit.Contrato> ListarCartoes(String numeroConta, String idEmpresa, String cpf, String canal){
        IdentificaCockpit.ResponseAPIContaFinanceira conta = IdentificaCockpit.identificaNumeroConta(numeroConta, idEmpresa, cpf, canal);
        System.debug(conta);
        List<IdentificaCockpit.Contrato> listContratos = null;
        if (conta != null){
            listContratos = conta.data.clientePorConta.contaCartao.contratos;
        }
        return listContratos;
    }
}