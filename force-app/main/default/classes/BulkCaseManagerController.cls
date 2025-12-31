public without sharing class BulkCaseManagerController {
    
    @AuraEnabled
    public static void createBulkCases(CaseData lInputData){
      CreateCaseBatch batch = new CreateCaseBatch(lInputData);
      Database.executeBatch(batch, 1);
    }

    @AuraEnabled
    public static void updateBulkCases(List<UpdateCaseData> lLstInputs){
      UpdateCaseBatch batch = new UpdateCaseBatch(lLstInputs);
      Database.executeBatch(batch, 10);
    }

    @AuraEnabled
    public static ErrorImportData getBulkRecordDetails(Map<String, String> lMapFilters){
      ErrorImportData returnOutput = new ErrorImportData();
      returnOutput.totalItems = Database.countQuery(buildQuery(lMapFilters).get('countQuery'));
      returnOutput.records = Database.query(buildQuery(lMapFilters).get('query'));

      return returnOutput;
    }

    private static Map<String, String> buildQuery(Map<String, String> lMapFilters) {
      String query = 'SELECT Id, ErrorMessage__c, BusinessUnit__c, ImportType__c, AccountNumber__c, Subject__c, Event__c, CaseNumber__c FROM BulkRecordDetail__c';
      String countQuery = 'SELECT count() FROM BulkRecordDetail__c';
      String restrictionClause = ' ORDER BY CreatedDate DESC ' + ' LIMIT ' + lMapFilters.get('itensPerPage') + ' OFFSET ' + lMapFilters.get('startIndex');
      String whereClause = '';

      if (lMapFilters.containsKey('event')){
        if ( String.isBlank(whereClause)) {
          whereClause = ' WHERE Event__c = \'' + lMapFilters.get('event') + '\'';
        }
        else {
          whereClause += ' AND Event__c = \'' + lMapFilters.get('event') + '\'';
        }
      }
      
      if (lMapFilters.containsKey('subject')){
        if ( String.isBlank(whereClause)) {
          whereClause = ' WHERE Subject__c = \'' + lMapFilters.get('subject') + '\'';
        }
        else {
          whereClause += ' AND Subject__c = \'' + lMapFilters.get('subject') + '\'';
        }
      }
      
      if (lMapFilters.containsKey('importType')){
        if ( String.isBlank(whereClause)) {
          whereClause = ' WHERE ImportType__c = \'' + lMapFilters.get('importType') + '\'';
        }
        else {
          whereClause += ' AND ImportType__c = \'' + lMapFilters.get('importType') + '\'';
        }
      }

      return new Map<String, String> {
        'query' => query + whereClause + restrictionClause,
        'countQuery' => countQuery + whereClause
      };
    }

    @AuraEnabled
    public static Map<String, String> getImportFields(){
      Map<String, String> lMapRequiredFields = new Map<String, String>();
      List<Schema.FieldSetMember> requiredFields = Schema.SObjectType.Case.fieldSets.getMap().get('RequiredFieldsBulkCases').getFields();
      List<Schema.FieldSetMember> requirementFields = Schema.SObjectType.Case.fieldSets.getMap().get('RequirementFieldsBulkImport').getFields();

      for (Schema.FieldSetMember member : requiredFields) {
          lMapRequiredFields.put(member.getLabel(), String.valueOf(member.getSObjectField()));
      }

      for (Schema.FieldSetMember member : requirementFields) {
          lMapRequiredFields.put(member.getLabel(), String.valueOf(member.getSObjectField()));
      }

      return lMapRequiredFields;
    }

    public class CaseData {
      @AuraEnabled
      public List<Map<String, Object>> Data { get; set; }
    }

    public class ErrorImportData {
      @AuraEnabled
      public List<BulkRecordDetail__c> records { get; set; }
      @AuraEnabled
      public Integer totalItems { get; set; }
    }

    public class UpdateCaseData {
      @AuraEnabled
      public String CaseNumber { get; set; }
      @AuraEnabled
      public String ErrorMessage { get; set; }
      @AuraEnabled
      public String ClosedReason { get; set; }
    }
}