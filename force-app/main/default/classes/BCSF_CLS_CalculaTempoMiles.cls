global abstract class BCSF_CLS_CalculaTempoMiles implements Support.MilestoneTriggerTimeCalculator {

    protected Id Atendimento_RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BCSF_RT_CAS_Atendimento').getRecordTypeId();
    protected Case TargetCase;
    protected String CaseOwnerType;
    protected MilestoneType MilestoneTypeInfo;
    protected SObject AssuntoAtendimentoInfos;

    protected virtual void fetchCaseInfos(String caseId){
        this.TargetCase = [
            SELECT 
                Id,
                AreaPrincipal__c, 
                AssuntoAtendimento__c, 
                IsClosed, 
                RecordTypeId, 
                DataRegulatoria__c, 
                DataProrrogada__c, 
                OwnerId, 
                CreatedDate
            FROM Case
            WHERE Id =: caseId
            LIMIT 1
        ];

        this.CaseOwnerType= this.TargetCase.OwnerId.getSObjectType().getDescribe().getName();
    }

    protected virtual void fetchMilestoneInfos(String milestoneTypeId){
        this.MilestoneTypeInfo = [
            SELECT Id, Name, CreatedDate 
            FROM MilestoneType 
            WHERE Id =: milestoneTypeId
            LIMIT 1
        ];
    }

    protected List<CaseMilestone> fetchCaseMilestone(){
        return [
            SELECT 
                Id, 
                TimeRemainingInMins,
                TargetResponseInMins,
                StartDate
            FROM CaseMilestone
            WHERE CaseId =: this.TargetCase.Id
                AND MilestoneTypeId =: this.MilestoneTypeInfo.Id
                AND isCompleted =: false
            LIMIT 1
        ];
    }

    protected void fetchAssuntoAtendimentoInfos(){
        this.AssuntoAtendimentoInfos = [
            SELECT Id, PrazoAtendimentoCustomer__c,
            PrazoAtendimentoBackofficeClientes__c, 
            PrazoAtendimentoBackofficeJuridico__c,
            PrazoAtendimentoCanaisCriticos__c, 
            PrazoAtendimentoOuvidoria__c, 
            PrazoAtendimentoProcon__c, 
            PrazoConclusao2__c 
            FROM AssuntoAtendimento__c
            WHERE Assunto__c = 'Encargos, Tarifas e Anuidade'
            LIMIT 1
        ];
    }

    protected Integer calcSLA(Object contextSLA){
        if(String.valueOf(this.TargetCase.DataRegulatoria__c) == null){
            // SLA zerado quando não houver um valor cadastrado para o campo
            if(contextSLA == null) return 0;

            return this.TargetCase.DataProrrogada__c ? this.calculaTempoProrrogado() : (60 * 9 * Integer.valueOf(contextSLA));
        } else {
            return this.TargetCase.DataProrrogada__c ? this.calculaTempoProrrogado() : this.genericCalculation();
        }
    }

    protected Integer calculaTempoProrrogado(){
        List<CaseMilestone> cmList = fetchCaseMilestone();

        if(cmList.isEmpty()) return 10 * 9 * 60;

        Integer actualResponse = Integer.valueOf(cmList[0].TargetResponseInMins);
        
        return (actualResponse + 10 * 9 * 60);
    }

    protected Integer genericCalculation(){
        BusinessHours bh = fetchBusinessHours('BCSF Atendimento');

        List<CaseMilestone> caseMilesList = fetchCaseMilestone();
        Datetime startDate = caseMilesList.isEmpty() ? System.Datetime.now() : caseMilesList[0].StartDate;
        Datetime dateTimeEnd = this.TargetCase.DataRegulatoria__c;
        dateTimeEnd = dateTimeEnd.addHours(21);

        Long diifInMilliseconds = BusinessHours.diff(bh.Id, startDate, dateTimeEnd);
        Long minutes = diifInMilliseconds / 60000;

        return Integer.valueOf(minutes);
    }

    protected virtual BusinessHours fetchBusinessHours(String name){
        return [
            SELECT
                Id
            FROM BusinessHours 
            WHERE Name =: name
            LIMIT 1
        ][0];
    }
}