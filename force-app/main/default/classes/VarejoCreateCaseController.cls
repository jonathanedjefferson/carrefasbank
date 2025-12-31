public without sharing class VarejoCreateCaseController {
    @AuraEnabled
    public static String CreateCaseTDCA(String messagingId, String channel, String orderNumber, String consignmentCode, String document, String emailClient, String customerName, String telephone, String description, String brand, String bot, String protocolo, String opcao) {
        
        List<DadosAberturaProtocoloVarejo__mdt> dadosProtocolo = getDadosAberturaProtocolo(bot, protocolo, opcao);
        if (dadosProtocolo.size() > 0) {
            String preferenceContact        = dadosProtocolo[0].PreferenciaContato__c       != null ? dadosProtocolo[0].PreferenciaContato__c   : '';
            String origin                   = dadosProtocolo[0].Origem__c                   != null ? dadosProtocolo[0].Origem__c               : '';
            String typeorder                = dadosProtocolo[0].Tipo__c                     != null ? dadosProtocolo[0].Tipo__c                 : '';
            String subjectReasonContact     = dadosProtocolo[0].Assunto__c                  != null ? dadosProtocolo[0].Assunto__c              : '';
            String event                    = dadosProtocolo[0].Evento__c                   != null ? dadosProtocolo[0].Evento__c               : '';
            String store                    = dadosProtocolo[0].Store__c                    != null ? dadosProtocolo[0].Store__c                : '';
            channel                         = channel                                       != null ? channel                                   : '';
            brand                           = brand                                         != null ? brand                                     : '';
            orderNumber                     = orderNumber                                   != null ? orderNumber                               : '';
            consignmentCode                 = consignmentCode                               != null ? consignmentCode                           : '';
            document                        = document                                      != null ? document                                  : '';
            emailClient                     = emailClient                                   != null ? emailClient                               : '';
            customerName                    = customerName                                  != null ? customerName                              : '';
            telephone                       = telephone                                     != null ? telephone                                 : '';
            description                     = description                                   != null ? description                               : '';            

            List<ContentDocumentLink> listDoc = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :messagingId];
            List<ContentVersion> listVersion = new List<ContentVersion>();

            if(listDoc.size() > 0) listVersion = [SELECT Id, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :listDoc[0].ContentDocumentId];

            if(listVersion.size() > 0){
                APICaseCreationWithDocument.CaseResponse response = APICaseCreationWithDocument.createCase(brand, preferenceContact, orderNumber, consignmentCode, origin, channel, typeorder, subjectReasonContact, event, document, emailClient, customerName, telephone, description, store, listVersion[0].Id, listVersion[0].FileExtension);
                
                if (response != null) {
                    delete new ContentDocument(Id = listDoc[0].ContentDocumentId);
                    
                    MessagingSession messaging = new MessagingSession();
                    messaging.Id = messagingId;
                    messaging.VarejoCaseId__c = response.id;
                    if (!Test.isRunningTest()) {
                        update messaging;
                    }
                }
                return response != null ? response.Id : 'ERROR';

            }else{
                APICaseCreation.CaseResponse response = APICaseCreation.createCase(brand, preferenceContact, orderNumber, consignmentCode, origin, channel, typeorder, subjectReasonContact, event, document, emailClient, customerName, telephone, description, store);
    
                if (response != null) {
                    MessagingSession messaging = new MessagingSession();
                    messaging.Id = messagingId;
                    messaging.VarejoCaseId__c = response.id;
                    if (!Test.isRunningTest()) {
                        update messaging;
                    }
                }
                return response != null ? response.Id : 'ERROR';
            } 

        }

        return 'ERROR';
    }

    @AuraEnabled
    public static String getStaticRessource(){
        StaticResource sr= [SELECT Id, Body FROM StaticResource WHERE Name = 'VarejoInformations'];

        String allcontents = sr.body.toString();

        return allcontents;
    }

    public static List<DadosAberturaProtocoloVarejo__mdt> getDadosAberturaProtocolo(String bot, String protocolo, String opcao){
        List<DadosAberturaProtocoloVarejo__mdt> dadosAbertura = [
            SELECT 
                Id, 
                Bot__c, 
                Protocolo__c, 
                Opcao__c, 
                Formato__c, 
                Marca__c, 
                BU__c, 
                Tipo__c, 
                Assunto__c, 
                Evento__c, 
                CheckList__c, 
                Store__c, 
                Origem__c, 
                PreferenciaContato__c
            FROM 
                DadosAberturaProtocoloVarejo__mdt
            WHERE 
                Bot__c = :bot AND
                Protocolo__c = :protocolo AND
                Opcao__c = :opcao
        ];

        return dadosAbertura;
    }
}