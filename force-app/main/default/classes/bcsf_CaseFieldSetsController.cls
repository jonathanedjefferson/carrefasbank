public class bcsf_CaseFieldSetsController {
    @AuraEnabled
    public static List<FieldSet> getFieldSet(String fieldSetName) {
        List<FieldSet> lstFieldSet = new List<FieldSet>();
        List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Case.fieldSets.getMap();
        
        for(Schema.FieldSet key : FsMap.values()) {
            if(key.getLabel() == fieldSetName) {
                fieldSetMembers = key.getFields();
            }
        }

        for(Schema.FieldSetMember fsm : fieldSetMembers) {
            FieldSet f = new FieldSet();
            f.fieldApiName = fsm.getFieldPath();
            f.objectApiName = 'Case';

            lstFieldSet.add(f);
        }

        return lstFieldSet;
    }
    
    public class FieldSet {
        @AuraEnabled public string fieldApiName {get;set;}
        @AuraEnabled public string objectApiName {get;set;}
    }    
}