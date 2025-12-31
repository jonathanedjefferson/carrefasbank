public without sharing class BCSF_CadastroCelularSeguroController {

    @AuraEnabled
    public static ContaFinanceira__c getContaFinanceira(String idContaFinanceira) {
        return BCSF_CadastroCelularSeguroDAO.getInstance().getContaFinanceira(idContaFinanceira);
    }

    @AuraEnabled
    public static Boolean gravarCelularSeguro(String cpf,  String numeroCelular, String numeroConta, String idEmpresa, String canal) {
        return IntegracaoCelularSeguro.gravarCelularSeguro(cpf, numeroCelular, numeroConta, idEmpresa, canal);
    }

    @AuraEnabled
    public static Case criarCaso(String telefone, String telefoneAntigo, String contaFinanceiraId, String accountId, String cenario, String unidadeNegocio, String cpf, String origem, String canal) {
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        Case cs = new Case();
        cs.OwnerId = 

        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.CPFContato__c = cpf;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio; 
        cs.Origin = origem;
        cs.CanalEntrada__c = canal;
        cs.CriarCasoPorComponente__c = true;
        cs.Priority = 'Medium';
        cs.Assunto__c = 'Cartão';
        cs.Telefone__c = telefone;
        cs.TelefoneParaCadastro__c = telefoneAntigo;
        cs.OwnerId = cenario != 'cenario2' && cenario != 'cenario3' ? UserInfo.getUserId() : BCSF_CadastroCelularSeguroDAO.getInstance().getQueue('Queue', 'BackofficePrevencaoFraudes').id;
        cs.Evento__c = cenario == 'cenario1' ? 'Informação sobre celular seguro' : 'Cadastro de celular seguro';
        cs.Status = cenario == 'cenario2' || cenario == 'cenario3' ? 'New' :'Closed';
        cs.Type = cenario == 'cenario1' ? 'Informação' : 'Execução';
        
        if(cenario == 'cenario2' || cenario == 'cenario3' ){
            cs.motivo__c = cenario == 'cenario2'? 'Não aceitou ir até a loja mais próxima' : 'Não possui loja próxima';
            cs.Type = 'Solicitação';
        }
        insert cs;

        return BCSF_CadastroCelularSeguroDAO.getInstance().getCase(cs.id);
    }

    @AuraEnabled
    public static void atualizarCaso(String caseId, String fraude, String alteracao, String aprovado, String resolucao) {

        Case cs = new Case();
        cs.Id = caseId;
        cs.Fraude__c = fraude;
        cs.HouveAlteracaoCadastral__c = alteracao;
        cs.Resolucao__c = resolucao;
        cs.Aprovado__c = aprovado;
        cs.Status = 'Closed';
        
        update cs;
    }

    @AuraEnabled
    public static PerfisCadastroCelularSeguro__mdt getAcessoPerfil(String label) {
        return BCSF_CadastroCelularSeguroDAO.getInstance().getAcessoPerfil(label);
    }

    @AuraEnabled
    public static Boolean usuarioPossuiPermissao(List<String> permissoesPermitidas) {
        List<PermissionSetAssignment> permissoesUsuario = BCSF_CadastroCelularSeguroDAO.getInstance().usuarioPossuiPermissao(permissoesPermitidas);
        return !permissoesUsuario.isEmpty();
    }
}