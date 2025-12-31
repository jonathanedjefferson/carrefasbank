global with sharing class BCSF_CLS_CalcTempo_Ouvidoria extends BCSF_CLS_CalculaTempoMiles{
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        this.fetchCaseInfos(caseId);
        this.fetchMilestoneInfos(milestoneTypeId);
        this.fetchAssuntoAtendimentoInfos();

        return this.calcSLA(this.AssuntoAtendimentoInfos.get('PrazoAtendimentoOuvidoria__c'));
    }
}