trigger CaseTriggerAttMilestone on Case (before update) {
    Case cs = Trigger.new[0];
    Case csOld = Trigger.old[0];

    CaseMilestone csMl = new CaseMilestone();
    if ((cs.Evento__c == 'Reclamação de Cobrança' && cs.Assunto__c == 'Reclamação de Canais de atendimento' && cs.AtendimentoRealizadoPelaCobranca__c != csOld.AtendimentoRealizadoPelaCobranca__c) ||
        (cs.Evento__c == 'Solicitações Via e-mail' && cs.Assunto__c == 'Correspondência de Cobrança' && cs.Resolucao__c != csOld.Resolucao__c) ||
        (cs.Evento__c == 'Alteração de dados cadastrais CPF' && cs.Assunto__c == 'Cartão' && cs.Status == 'Closed') ||
        (cs.Evento__c == 'Cliente Perfil Diferenciado' && cs.Assunto__c == 'Alteração de Dados Cadastrais' && cs.Status == 'Closed')) {
        csMl = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId = :cs.Id AND CompletionDate = null LIMIT 1];
        
        csMl.CompletionDate = System.now();
        update csMl;
    }
}