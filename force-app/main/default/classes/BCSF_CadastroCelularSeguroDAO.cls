public without sharing class BCSF_CadastroCelularSeguroDAO {

    private static final BCSF_CadastroCelularSeguroDAO instance = new BCSF_CadastroCelularSeguroDAO();

    public static BCSF_CadastroCelularSeguroDAO getInstance() { return instance; }

    public Case getCase(String caseId) {
        List<Case> lst = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
        return lst.isEmpty() ? null : lst[0];
    }

    public ContaFinanceira__c getContaFinanceira(String idContaFinanceira) {
        List<ContaFinanceira__c> lst = [SELECT 
                                            Id,
                                            NomeCliente__c,
                                            NomeCliente__r.Name,
                                            NumeroConta__c, 
                                            UnidadeNegocio__c, 
                                            StatusConta__c,
                                            Telefone__c,
                                            Produto__c,
                                            CelularSeguro__c,
                                            NomeCliente__r.CPF__c
                                        FROM 
                                            ContaFinanceira__c WHERE id =: idContaFinanceira];
        return lst.isEmpty() ? null : lst[0];
    }

    public PerfisCadastroCelularSeguro__mdt getAcessoPerfil(String label) {
        return [
            SELECT  
                Label,
                DeveloperName,
                Acesso__c,
                PermissionSets__c
            FROM 
                PerfisCadastroCelularSeguro__mdt
            WHERE
            Label =: label
        ];
    }

    public Group getQueue(String tipo, String developerName){
        return [
            SELECT 
                Id, 
                Name, 
                DeveloperName, 
                Type 
            FROM 
                Group 
            WHERE 
                Type = :tipo AND 
                DeveloperName = :developerName
        ];
    }

    public user getUser(String userId){
        return [SELECT DRT__c, AreaPrincipal__c FROM user WHERE Id =: userId];
    }

    public List<PermissionSetAssignment> usuarioPossuiPermissao(List<String> permissoesPermitidas) {
        return [
                SELECT 
                    PermissionSet.Name 
                FROM 
                    PermissionSetAssignment 
                WHERE AssigneeId = :UserInfo.getUserId()
                AND PermissionSet.Name IN :permissoesPermitidas
            ];
    }
}