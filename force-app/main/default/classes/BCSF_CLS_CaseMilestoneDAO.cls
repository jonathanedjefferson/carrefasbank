public without sharing class BCSF_CLS_CaseMilestoneDAO {

    public static List<CaseMilestone> fetchCase_Milestones(Set<Id> caseIdSet){
        return [
            SELECT 
                Id 
            FROM CaseMilestone 
            WHERE CaseId IN :caseIdSet AND MilestoneType.Name != 'Prazo de Conclusão' AND isCompleted = false
        ];
    }

    public static List<CaseMilestone> fetchOpened_CaseMilestones(Set<Id> caseIdSet){
        return [
            SELECT 
                Id,
            	IsViolated,
                MilestoneType.Name,
                TimeRemainingInMins,
                CaseId
            FROM CaseMilestone 
            WHERE CaseId IN :caseIdSet AND isCompleted = false
        ];
    }

    public static List<CaseMilestone> fetchCaseMilestone_PrazoConclusao(Set<Id> caseIdSet){
        return [
            SELECT 
                Id,
                MilestoneType.Name,
                CaseId
            FROM CaseMilestone 
            WHERE CaseId IN :caseIdSet AND isCompleted = false AND MilestoneType.Name = 'Prazo de Conclusão'
        ];
    }
}