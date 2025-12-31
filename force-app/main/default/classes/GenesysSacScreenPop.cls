global with sharing class GenesysSacScreenPop implements purecloud.CTIExtension.ScreenPop {
    global String onScreenPop(String data) {
        Map<String, Object> resp = new Map<String, Object>();
        try {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(data);
            Map<String, Object> interaction = (Map<String, Object>) payload.get('interaction');
            String calledNumber = interaction != null ? (String) interaction.get('calledNumber') : null;
            System.debug('data '+ JSON.serialize(data));
            Set<String> sacTelefones = getUraSACPhones();
            Set<String> ouvidoriaTelefones = getUraOuvidoriaPhones();
            Set<String> todosTelefonesUra = new Set<String>();
            todosTelefonesUra.addAll(sacTelefones);
            todosTelefonesUra.addAll(ouvidoriaTelefones);
            String canal;
            
            if (String.isBlank(calledNumber) || todosTelefonesUra.isEmpty() || !todosTelefonesUra.contains(calledNumber)) {
                resp.put('defaultScreenPop', true);
                return JSON.serialize(resp);
            }
            canal = ouvidoriaTelefones.contains(calledNumber) ? 'Ouvidoria': 'SAC';
            switch on canal{
                when 'Ouvidoria'{
                    String result = GenesysSacController.handleScreenPopoOuvidoria(payload);
                    if (!String.isBlank(result)) {
                        resp.put('url', result);
                    } else {
                        resp.put('defaultScreenPop', true);
                    }
                    return JSON.serialize(resp);
                }
                when 'SAC'{
                    Map<String, Id> result = GenesysSacController.handleScreenPop(payload);
                    if (result != null && result.containsKey('caseId')) {
                        resp.put('url', String.valueOf(result.get('caseId')));
                    } else {
                        resp.put('defaultScreenPop', true);
                    }
                }  when else {
                    System.debug('Canal desconhecido');
                }
            }
        } catch (Exception e) {
            System.debug('GenesysSacScreenPop ERROR: ' + e.getMessage());
            resp.put('defaultScreenPop', true);
        }
        return JSON.serialize(resp);
    }
    private static Set<String> getUraSACPhones() {
        Set<String> phones = new Set<String>();
        UraSAC__c cs = UraSAC__c.getOrgDefaults();
        if (cs != null && !String.isBlank(cs.Telefone__c)) {
            for (String fone : cs.Telefone__c.split(';')) {
                if (!String.isBlank(fone)) {
                    phones.add(fone.trim());
                }
            }
        }
        return phones;
    }
    private static Set<String> getUraOuvidoriaPhones() {
        Set<String> phones = new Set<String>();
        String telefones = UraOuvidoriaPhonesDAO.getInstance().getUraOuvidoriaPhones();
        if (!String.isBlank(telefones)) {
            for (String fone : telefones.split(';')) {
                if (!String.isBlank(fone)) {
                    phones.add(fone.trim());
                }
            }
        }
        return phones;
    }
}