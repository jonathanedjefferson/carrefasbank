global with sharing class BCSF_CLS_CalcTempo_BackJur extends BCSF_CLS_CalculaTempoMiles{
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        this.fetchCaseInfos(caseId);
        this.fetchMilestoneInfos(milestoneTypeId);
        this.fetchAssuntoAtendimentoInfos();

        return this.calcSLA(this.AssuntoAtendimentoInfos.get('PrazoAtendimentoBackofficeJuridico__c'));
    }
}