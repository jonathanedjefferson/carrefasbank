public with sharing class bcsf_cmp_SegurosDAO {
    private static final bcsf_cmp_SegurosDAO instance = new bcsf_cmp_SegurosDAO();

    public static bcsf_cmp_SegurosDAO getInstance() { return instance; }

    public Knowledge__kav getArtigos(String title) {
        List<Knowledge__kav> retorno = [SELECT 
                                        id, 
                                        Title, 
                                        Summary, 
                                        PublishStatus,
                                        Perguntas__c,
                                        Resposta__c,
                                        LastModifiedDate
                                    FROM 
                                        Knowledge__kav
                                    WHERE
                                        PublishStatus = 'Online' AND
                                        Title =: title
                                    ];

        return retorno.isEmpty() ? null : retorno[0];
    }

    public Account getAccount(String accountId) {
        List<Account> retorno = [SELECT 
                                        id, 
                                        Sexo__c, 
                                        DataNascimento__c, 
                                        NomeMae__c
                                    FROM 
                                        Account
                                    WHERE
                                        id =: accountId
                                    ];

        return retorno.isEmpty() ? null : retorno[0];
    }

    public Case getCase(String caseId) {
        List<Case> lst = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
        return lst.isEmpty() ? null : lst[0];
    }
}