public with sharing class FlowConsultarJanelaEntregaTO {
    @AuraEnabled @InvocableVariable
	public String dateStart;
    @AuraEnabled @InvocableVariable
	public String dateEnd;
    @AuraEnabled @InvocableVariable
    public Integer statusCode;
}