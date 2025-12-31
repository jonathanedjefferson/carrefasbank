@isTest
public with sharing class BCSF_CLS_FlowCvrtVencimentosTest {
    @isTest
    static void shouldGetVencimentos(){
        List<String> mockVencimentos = new List<String>{'{"vencimentos":[{"idFatura":13127609,"data":"2025-11-15T00:00:00"}]}'};

        List<BCSF_CLS_FlowCvrtVencimentos.Response> result = BCSF_CLS_FlowCvrtVencimentos.getVencimentos(mockVencimentos);
    }
}