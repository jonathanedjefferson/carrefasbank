public without sharing class AlteracaoCadastralController {
    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira GetContaFinanceira(String idContaFinanceira) {
        return ContaFinanceiraBO.getContaFinanceira(idContaFinanceira);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getAssetTitular(String idContaFinanceira) {
        return AssetBO.getAssetTitular(idContaFinanceira);
    }
    
    @AuraEnabled
    public static Boolean AlterarDadosCadastrais(String cpf, String idEmpresa, String canal, String numeroConta, String area, String sistema, String bodyRequest) {
        IntegrationAlteracaoCadastral.BodyRequestAlterarDadosCadastrais request = (IntegrationAlteracaoCadastral.BodyRequestAlterarDadosCadastrais) System.JSON.deserialize(bodyRequest, IntegrationAlteracaoCadastral.BodyRequestAlterarDadosCadastrais.class);
        return IntegrationAlteracaoCadastral.AlterarDadosCadastrais(cpf, idEmpresa, canal, numeroConta, area, sistema, request);
    }
    
    @AuraEnabled
    public static Case CriarCaso(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio, String assunto, String evento, String status) {
        System.debug('canal -> ' + canal);
        System.debug('origem -> ' + origem);
        System.debug('contaFinanceiraId -> ' + contaFinanceiraId);
        System.debug('accountId -> ' + accountId);
        System.debug('unidadeNegocio -> ' + unidadeNegocio);
        System.debug('assunto -> ' + assunto);
        System.debug('evento -> ' + evento);
        System.debug('status -> ' + status);

        RecordType recordTypeId = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        System.debug('recordTypeId -> ' + recordTypeId);
        String ownerId = UserInfo.getUserId();
        String tipo = 'Execução';

        if (evento.contains('CPF') || (assunto == 'Prevenção a Fraude' && evento == 'Cliente Perfil Diferenciado')) {
            ownerId = [SELECT Id FROM Group WHERE Type = 'queue' AND DeveloperName = 'PrevencaoFraude' LIMIT 1].Id;
            tipo = 'Solicitação';
        }
        if (evento.contains('CPF') || (assunto == 'Alteração de Dados Cadastrais' && evento == 'Cliente Perfil Diferenciado')) {
            ownerId = [SELECT Id FROM Group WHERE Type = 'queue' AND DeveloperName = 'BackofficePrevencaoFraudes' LIMIT 1].Id;
            tipo = 'Solicitação';
        }
        Case cs = CasoDAO.getInstance().createCase(ownerId, recordTypeId.Id, status, assunto, evento, tipo, 'Medium', canal, origem, contaFinanceiraId, accountId, unidadeNegocio);
        return CasoDAO.getInstance().getCase(cs.Id);
    }

    @AuraEnabled
    public static IntegrationEndereco.OutputEndereco GetEnderecoByCEP(String cpf, String idEmpresa, String canal, String cep) {
        return IntegrationEndereco.GetEnderecoByCEP(cpf, idEmpresa, canal, cep);
    }

    @AuraEnabled
    public static void CriarAvaliacaoAlteracao(String avaliacaoJson) {
        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO avaliacao = (AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO) System.JSON.deserialize(avaliacaoJson, AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO.class);
        AvaliacaoAlteracaoCadastralBO.CriarAvaliacaoAlteracao(avaliacao);
    }
    
    @AuraEnabled
    public static AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO GetAvaliacaoAlteracaoCadastral(String caseId) {
        return AvaliacaoAlteracaoCadastralBO.ObterDadosAlteracaoCadastral(caseId);
    }
    
    @AuraEnabled
    public static void UpdateCaseAvaliacao(String accId, String cfId, String caseId, String description, String avaliacaoid, String statusAv, Boolean incidenciaFraude, Boolean falouLGPD, Boolean protIndevido, Boolean mudouCPF, String avaliacaoJson) {
        AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO avaliacao = (AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO) System.JSON.deserialize(avaliacaoJson, AvaliacaoAlteracaoCadastralBO.AvaliacaoAlteracaoCadastralTO.class);
        Case cs = new Case();
        cs.Id = caseId;
        cs.Description = description;
        cs.Status = 'closed';
        cs.AvaliacaoAlteracaoCadastral__c = avaliacaoid;
        
        AvaliacaoAlteracaoCadastral__c av = new AvaliacaoAlteracaoCadastral__c();
        av.Id = avaliacaoid;
        av.StatusSolicitacao__c = statusAv;
        av.IncidenciaFraude__c = incidenciaFraude;
        av.FalouLGPD__c = falouLGPD;
        av.ProtocoloIndevido__c = protIndevido;
        av.Descricao__c = description;

        if (mudouCPF && statusAv == 'Aprovado') {
            Account acc = new Account();
            acc.Id = accId;
            acc.CPF__c = avaliacao.CPF;
            update acc;
        }else if (!mudouCPF && statusAv == 'Aprovado') {
            ContaFinanceira__c cf = new ContaFinanceira__c();
            cf.Id = cfId;
            if(avaliacao.Complemento != '--'){
                cf.Complemento__c = avaliacao.Complemento;
            }
            if(avaliacao.Cidade != '--'){
                cf.Cidade__c = avaliacao.Cidade;
            }
            if(avaliacao.Email != '--'){
                cf.Email__c = avaliacao.Email;
            }
            if(avaliacao.CEP != '--'){
                cf.CEP__c = avaliacao.CEP;
            }
            if(avaliacao.NumeroCasa != '--'){
                cf.Numero__c = String.valueOf(avaliacao.NumeroCasa);
            }
            if(avaliacao.Bairro != '--'){
                cf.Bairro__c = avaliacao.Bairro;
            }
            if(avaliacao.UF != '--'){
                cf.Estado__c = avaliacao.UF;
            }
            update cf;
        }
        
        update av;
        update cs;
    }
}