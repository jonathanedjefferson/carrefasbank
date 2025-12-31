public without sharing class BCSF_CLS_CaseTriggerHandler {

private Map<Id, Case> NewMap;
private Map<Id, Case> OldMap;
private List<Case> NewList;
private List<Case> OldList;
private Map<String, Schema.RecordTypeInfo> CaseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();

private BCSF_CLS_CaseTriggerHandler(Map<Id, Case> newMap, List<Case> newList, Map<Id, Case> oldMap, List<Case> oldList){
    this.NewMap = newMap;
    this.NewList = newList;
    this.OldMap = oldMap;
    this.oldList = oldList;
}

public static BCSF_CLS_CaseTriggerHandler getInstance(Map<Id, Case> newMap, List<Case> newList, Map<Id, Case> oldMap, List<Case> oldList){
    return new BCSF_CLS_CaseTriggerHandler(newMap, newList, oldMap, oldList);
}

public void beforeInsert(){
}

public void afterInsert(){
    this.prepareAsync( filterCasesWithAtendimentoRT(this.NewList));
    CaseCustomerAssignmentService service = new CaseCustomerAssignmentService(this.NewList);
    service.evaluateAccountAssignmentNeed();
}

public void beforeUpdate(){
    this.changeAreaProprietarioIfNecessary();

    if (Trigger.new != null) {
        Case cs = [SELECT Resolucao__c, Evento__c,Assunto__c, Status FROM Case WHERE Id =:Trigger.new[0].Id];
        Case csOld = [SELECT Resolucao__c, Evento__c,Assunto__c,Status FROM Case WHERE Id =:Trigger.old[0].Id];
        User us = [SELECT Id, UserRole.DeveloperName FROM User WHERE Id =:UserInfo.getUserId()];
        
        if (cs.Assunto__c == 'Correspondência de Cobrança' && 
        cs.Evento__c == 'Solicitações Via e-mail' && 
        cs.Resolucao__c == csOld.Resolucao__c &&
        cs.Status == 'Em tratativa' &&
        (us.UserRole.DeveloperName == 'BCSFBackOfficeCobrancaAtento' || Test.IsRunningTest())
        ) {
            List<ContentVersion> listFiles = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId =:cs.Id];
            
            if (listFiles.size() == 0) {
                Trigger.new[0].addError('É necessário anexar um arquivo antes de salvar a resolução');
            }
        }
        
        this.verificarSePodeAceitarCaso();
    }
}

public void afterUpdate(){
    Group gr = new Group();
    String idOwner = this.OldList[0].OwnerId;
    if (idOwner.startsWith('00G')) {
        gr = [SELECT Name FROM Group WHERE Id = :this.OldList[0].OwnerId LIMIT 1];
    }
    
    if (gr.Name != 'Backoffice Prevenção a Fraudes') {
        this.updateMilestones();
    }
    this.prepareAsync( filterCasesWithAtendimentoRT(this.NewList));
}

public void beforeDelete(){
    Profile objProfile = ProfileDAO.getInstance().getProfileById(UserInfo.getProfileId());

    if(objProfile != null && objProfile.Name != 'System Administrator' && objProfile.Name != 'Administrador do sistema' && objProfile.Name != 'BCSF_PF_Admin'){
        Trigger.new[0].addError('Não é permitido realizar a exclusão do caso.');
    }

}

public void afterDelete(){

}

private List<Case> filterCasesWithAtendimentoRT(List<Case> caseList){
    List<Case> filteredList = new List<Case>();
    
    for(Case cas : caseList){
        if(cas.RecordTypeId == this.CaseRecordTypes.get('BCSF_RT_CAS_Atendimento').getRecordTypeId()) filteredList.add(cas);
    }

    return filteredList;
}

@TestVisible
private void changeAreaProprietarioIfNecessary(){
    this.changeAreaProprietario(filterCasesThatOwnerHasChaged());
}

private List<Case> filterCasesThatOwnerHasChaged(){
    Id recordType_Atendimento = this.CaseRecordTypes.get('BCSF_RT_CAS_Atendimento').getRecordTypeId();
    List<Case> caseList = new List<Case>();

    for(Case caso : this.NewList){
        if(caso.OwnerId != this.OldMap.get(caso.Id).OwnerId && caso.RecordTypeId == recordType_Atendimento) caseList.add(caso);
        }

    return caseList;
}

private void changeAreaProprietario(List<Case> filteredCaseList){
    Set<Id> idSet = new Set<Id>();

    for(Case caso : filteredCaseList){
        idSet.add(caso.OwnerId);
    }

    Map<Id, User> userById = new Map<Id, User>([
        SELECT
            ID,
            toLabel(AreaPrincipal__c)
        FROM User
        WHERE ID IN: idSet
    ]);

    Map<Id, Group> groupById = new Map<Id, Group>([
        SELECT
            ID,
            Name
        FROM Group
        WHERE ID IN: idSet
    ]);

    for(Case caso : filteredCaseList){
        String nomeArea = userById.containsKey(caso.OwnerId) ? userById.get(caso.OwnerId).AreaPrincipal__c : groupById.get(caso.OwnerId).Name;
        caso.AreaProprietario__c = nomeArea;
    }
}

@TestVisible
private void updateMilestones(){
    Set<CaseMilestone> caseMileSet = new Set<CaseMilestone>();
    List<CaseMilestone> caseMileList = new List<CaseMilestone>();

    caseMileSet.addAll(BCSF_CLS_CaseMilestoneDAO.fetchCase_Milestones( getCaseIdSet( filterCasesThatAreaProprietarioHasChanged())));
    caseMileSet.addAll(BCSF_CLS_CaseMilestoneDAO.fetchOpened_CaseMilestones( getCaseIdSet( filterCasesThatHasClosed())));

    caseMileList.addAll(caseMileSet);

    if(caseMileList != null && !caseMileList.isEmpty()){
        for(CaseMilestone cm : caseMileList){
            cm.CompletionDate = System.Datetime.now();
        }

        Database.update(caseMileList);
    }
}

private List<Case> filterCasesThatAreaProprietarioHasChanged(){
    List<Case> filteredCaseList = new List<Case>();

    for(Case caso : this.NewList){
        if(caso.AreaProprietario__c != this.OldMap.get(caso.Id).AreaProprietario__c) filteredCaseList.add(caso);
    }

    return filteredCaseList;
}

private List<Case> filterCasesThatHasClosed(){
    List<Case> filteredCaseList = new List<Case>();

    for(Case caso : this.NewList){
        if(caso.IsClosed && !this.OldMap.get(caso.Id).IsClosed) filteredCaseList.add(caso);
    }
    
    return filteredCaseList;
}

private static Set<Id> getCaseIdSet(List<Case> caseList){
    Set<Id> caseIdSet = new Set<Id>();

    for(Case caso : caseList){
        caseIdSet.add(caso.Id);
    }

    return caseIdSet;
}

private BusinessHours fetchBusinessHours(String name){
    return [
        SELECT
            Id
        FROM BusinessHours 
        WHERE Name =: name
        LIMIT 1
    ][0];
}

private void prepareAsync(List<Case> caseList){
    if(caseList.isEmpty() || System.isFuture() || System.isBatch()) return;

    updateFarolAsync(System.JSON.serialize(caseList));
}

@future
private static void updateFarolAsync(String jsonCaseList){
    updateFarol((List<Case>) System.JSON.deserialize(jsonCaseList, List<Case>.class));
}

private static void updateFarol(List<Case> caseList){
    List<CaseMilestone> caseMileList = BCSF_CLS_CaseMilestoneDAO.fetchOpened_CaseMilestones(getCaseIdSet(caseList));
    Map<Id, Case> caseMap = new Map<Id, Case>(caseList);
    Set<Id> caseIdSet = new Set<Id>();

    for(CaseMilestone caseMile : caseMileList){
            String formatedTimeRemaining = caseMile.TimeRemainingInMins.split(':')[0];  

            if(Integer.valueOf(formatedTimeRemaining) > 1080) continue;

            If(caseMile.IsViolated){
                if(caseMile.MilestoneType.Name == 'Prazo de Conclusão'){
                caseMap.get(caseMile.CaseId).ControleFarolAtendimento__c = 'Vermelho';
                } else{
                    caseMap.get(caseMile.CaseId).ControleFarolAtendimentoArea__c = 'Vermelho';
                }
            }else{
                if(caseMile.MilestoneType.Name == 'Prazo de Conclusão'){
                caseMap.get(caseMile.CaseId).ControleFarolAtendimento__c = 'Amarelo';
                } else{
                    caseMap.get(caseMile.CaseId).ControleFarolAtendimentoArea__c = 'Amarelo';
                }
            }          

            caseIdSet.add(caseMile.CaseId);
        }


    if(!caseIdSet.isEmpty()){
        List<Case> casesToUpdate = new List<Case>();

        for(Id caseId : caseIdSet){
            Case cas = new Case(
                Id = caseId,
                ControleFarolAtendimento__c = caseMap.get(caseId).ControleFarolAtendimento__c,
                ControleFarolAtendimentoArea__c = caseMap.get(caseId).ControleFarolAtendimentoArea__c
            );
            
            casesToUpdate.add(cas);
        }

        Database.Update(casesToUpdate);
    }
}

private void verificarSePodeAceitarCaso(){
    String oldOwner = this.OldList[0].OwnerId;
    String newOwner = this.NewList[0].OwnerId;
    if (oldOwner.startsWith('00G') && !newOwner.startsWith('00G') && oldOwner != newOwner) {
        Group fila = [SELECT Id, Name FROM Group WHERE Id = :this.OldList[0].OwnerId LIMIT 1];

        // Create a set to store the IDs of users in the Fraud Queue Set<Id> 
        Set<Id> filaRoleIds = new Set<Id>();
        Set<Id> filaUserIds = new Set<Id>();
        Set<Id> filaRelatedIds = new Set<Id>();

        // Query the members of the Fraud Queue
            for (GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :fila.Id]) {
                filaRoleIds.add(member.UserOrGroupId);
                filaUserIds.add(member.UserOrGroupId);
                }

            System.debug('roleID--> '+filaRoleIds);
            for(group member : [SELECT id, relatedId FROM group WHERE id=:filaRoleIds]) { 
                filaRelatedIds.add(member.relatedId); 
            }
            System.debug('roleRelatedID--> '+filaRelatedIds);
            for(user member: [SELECT Id, name FROM User WHERE UserRoleId= :filaRelatedIds]){
                    filaUserIds.add(member.Id); } System.debug('user--> '+filaUserIds);
        
        // Loop through the cases being updated
        for (Case caseRecord : this.NewList) {
            // Check if the Case is being assigned to someone outside the Fraud Queue
            if (caseRecord.OwnerId != fila.Id && this.OldMap.get(caseRecord.Id).OwnerId == fila.Id) {
                if (!filaUserIds.contains(UserInfo.getUserId())) {
                    // Prevent the update and throw an exception
                    caseRecord.addError('Apenas usuários na fila ' + fila.Name + ' podem aceitar este caso.');
                }
            }
        }
    }
}

}