trigger BCSF_CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete) {
    
    BCSF_CLS_CaseTriggerHandler HANDLER = BCSF_CLS_CaseTriggerHandler.getInstance(Trigger.newMap, Trigger.new, Trigger.oldMap, Trigger.old);
    
        
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            HANDLER.beforeInsert();
        }

        if(Trigger.isAfter){
            HANDLER.afterInsert();
        }
    }

    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            HANDLER.beforeUpdate();
        }

        if(Trigger.isAfter){
            HANDLER.afterUpdate();
        }
    }

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            HANDLER.beforeDelete();
        }

        if(Trigger.isAfter){
            HANDLER.afterDelete();
        }
    }
}