public with sharing class CashbackMotorTO {
    @AuraEnabled public Promotion promotion;
    @AuraEnabled public Rule rule;
    @AuraEnabled public Acceleration acceleration;

    public class Promotion {
        @AuraEnabled public Integer id;
        @AuraEnabled public String businessUnit;
        @AuraEnabled public List<String> channelType;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public String status;
    }

    public class Rule {
        @AuraEnabled public Integer id;
        @AuraEnabled public List<String> paymentMethod;
        @AuraEnabled public String cashbackType;
        @AuraEnabled public Decimal cashbackValue;
        @AuraEnabled public Integer daysToRelease;
        @AuraEnabled public Datetime accumulationStartDate;
        @AuraEnabled public Datetime accumulationEndDate;
        @AuraEnabled public Datetime realEndDate;
        @AuraEnabled public Decimal minimumPurchaseAmount;
        @AuraEnabled public Decimal minimumCashinAmount;
    }

    public class Acceleration {
        @AuraEnabled public List<String> paymentMethod;
        @AuraEnabled public Decimal cashbackValue;
    }
}