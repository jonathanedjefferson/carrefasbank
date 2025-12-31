@isTest
public with sharing class BCSF_CLS_CaseMilestoneDAOTest {
    
    @isTest
    static void shouldFetchCase_Milestones(){
        Set<Id> caseIdSet = new Set<Id>();
        
        BCSF_CLS_CaseMilestoneDAO.fetchCase_Milestones(caseIdSet);
        BCSF_CLS_CaseMilestoneDAO.fetchOpened_CaseMilestones(caseIdSet);
        BCSF_CLS_CaseMilestoneDAO.fetchCaseMilestone_PrazoConclusao(caseIdSet);
    }
}