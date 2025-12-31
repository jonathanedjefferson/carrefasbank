public with sharing class GenesysSacController {
    
    public static Map<String, Id> handleScreenPop(Map<String, Object> payload) {
        Map<String, Id> result = new Map<String, Id>();
        
        Map<String, Object> interaction = (Map<String, Object>) payload.get('interaction');
        Map<String, Object> attributes  = interaction != null
            ? (Map<String, Object>) interaction.get('attributes') : null;
        
        String protocoloUra = attributes != null
            ? (String) attributes.get('Participant.PROTOCOLO_URA_SAC') : null;
        
        String interactionId = interaction != null
            ? (String) interaction.get('id') : null;
        
        String participantId = attributes != null
            ? (String) attributes.get('Participant.ID') : null;
        
        String cpf = attributes != null
            ? (String) attributes.get('Participant.CPF_VALIDADO') : null;
        
        Id accountId;
        if (String.isNotBlank(cpf)) {
            List<Account> accs = AccountDAO.getAccountsByCPF(new List<String>{ cpf });
            if (!accs.isEmpty()) {
                accountId = accs[0].Id;
            }
        }
        
        if (String.isNotBlank(protocoloUra)) {
            Case existingCase = CaseDAO.getInstance().getByCaseNumber(protocoloUra);
            if (existingCase != null) {
                Map<String, Object> updates = new Map<String, Object>();
                System.debug(accountId);
                if (String.isNotBlank(interactionId)) {
                    updates.put('ConversationId__c', interactionId);
                }
                if (accountId != null && existingCase.AccountId != accountId) {
                    updates.put('AccountId', accountId);
                }
                if (String.isNotBlank(cpf) && existingCase.CPFContato__c != cpf) {
                    updates.put('CPFContato__c', cpf);
                }
                
                if (!updates.isEmpty()) {
                    try {
                        CaseDAO.getInstance().updateCaseFields(existingCase.Id, updates);
                    } catch (DmlException e) {
                        System.debug(LoggingLevel.ERROR,
                        'GenesysSacController: falha ao atualizar caso existente: ' + e.getMessage());
                    }
                }
                result.put('caseId', existingCase.Id);
                return result;
            }
        }
        
        Case cs = CaseDAO.getInstance().createBCSFSacCase(cpf, accountId, interactionId);
        
        result.put('caseId', cs.Id);
        if (accountId != null) result.put('accountId', accountId);
        return result;
    }
    
    public static String handleScreenPopoOuvidoria(Map<String, Object> payload) {
        Map<String, Object> interaction = (Map<String, Object>) payload.get('interaction');
        String targetContaId ;
        Map<String, Object> attributes  = interaction != null
            ? (Map<String, Object>) interaction.get('attributes') : null;
        
        String contaValidada = attributes != null
            ?(String)attributes.get('Participant.CSF_TP_ACESSENHA'): null;
        
        String numeroConta = attributes != null
            ?(String)attributes.get('Participant.CSF_NU_CONTA') : null;
        
        String cpf = attributes != null
            ?(String)attributes.get('Participant.CSF_NU_CPFTITULAR') : null;
        System.debug('Atributes => '+ attributes);
        
        System.debug('contaValidada => '+ contaValidada);
        
            
        Account  contaResult = ConsultaCPFNoIDCcontroller.identificaCockpitAccount(cpf, 'Ouvidoria');
        System.debug('Conta result '+contaResult);
        ContaFinanceira__c cfResult = null;
        
        if(contaResult != null && String.isBlank(numeroConta)){
            cfResult = IdentificaCockpitController.identificaContaFinanceira(contaResult.id,contaValidada);
            System.debug('cfResult => '+ cfResult);
            targetContaId = String.valueOf(cfResult.Id);
        }else if(contaResult != null && !String.isBlank(numeroConta)){
            cfResult = IdentificaCockpitController.identificaContaFinanceira(contaResult.id,numeroConta,contaValidada);
            System.debug('cfResult => '+ cfResult);
            targetContaId = String.valueOf(cfResult.Id);
        }
        return targetContaId;
    }
}