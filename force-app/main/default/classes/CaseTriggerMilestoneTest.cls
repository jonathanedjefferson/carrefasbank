@isTest
public class CaseTriggerMilestoneTest {
    @isTest
    public static void MilestoneTest() {
        SlaProcess sla = [SELECT Id, Name, IsVersionDefault, IsActive FROM SlaProcess WHERE Name = 'BCSF_FluxoCobranca' AND IsActive = true AND IsVersionDefault = true];

        Account acc = new Account(
            Name = 'Acc Teste',
            CPF__c = '1111111111'
        );
        insert acc;

        Entitlement entitlements = new Entitlement(
            Name = 'Fluxo Cobrança',
            AccountId = acc.Id,
            StartDate = Date.Today(),
            EndDate = date.parse('25/02/2123'),
            SlaProcessId = sla.Id
        );
        insert entitlements;


        Id rtCase = [
            SELECT ID
            FROM RecordType
            WHERE DeveloperName = 'BCSF_PosVenda'
        ].Id;

        Case cs = new Case(
            RecordTypeId = rtCase,
            Origin = 'SAC',
            CanalEntrada__c = 'Voz',
            Assunto__c = 'Reclamação de Canais de atendimento',
            Evento__c = 'Reclamação de Cobrança',
            Type = 'Solicitação',
            Description = 'Descrição'
        );
        insert cs;

        Test.StartTest();
        cs.AtendimentoRealizadoPelaCobranca__c = 'Não';
        update cs;
        Test.StopTest();

        System.AssertEquals(1, [SELECT COUNT() FROM CaseMilestone WHERE CaseId = :cs.Id AND CompletionDate != null]);
    }
}