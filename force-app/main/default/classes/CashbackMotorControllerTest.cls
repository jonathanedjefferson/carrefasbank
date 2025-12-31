@IsTest
public class CashbackMotorControllerTest {

    @IsTest
    static void getOffers_200_Ok_deveRetornarOfertas() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockMotorCashback');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackMotorController.LwcOffer> ofertas =
            CashbackMotorController.getOffers('123', '', '', null);
        Test.stopTest();

        System.assert(ofertas != null, 'Lista não pode ser nula');
        System.assert(ofertas.size() > 0, 'Deveria retornar ao menos 1 oferta');
    }

    @IsTest
    static void getOffers_200_FiltragemPorData_antiga_deveZerar() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(200, 'MockMotorCashback');
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackMotorController.LwcOffer> ofertas =
            CashbackMotorController.getOffers('123', '', '', '1900-01-01');
        Test.stopTest();

        System.assert(ofertas != null, 'Lista não pode ser nula');
        System.assertEquals(0, ofertas.size(), 'Com data muito antiga, não deveria retornar ofertas');
    }

    @IsTest
    static void getOffers_500_Erro_deveNaoExplodirERetornarVazio() {
        MultiHttpCalloutMock objMultiHttpCalloutMock = new MultiHttpCalloutMock();
        objMultiHttpCalloutMock.addResponse(500);
        Test.setMock(HttpCalloutMock.class, objMultiHttpCalloutMock);

        Test.startTest();
        List<CashbackMotorController.LwcOffer> ofertas =
            CashbackMotorController.getOffers('ERR', '', '', null);
        Test.stopTest();

        System.assert(ofertas != null, 'Lista não pode ser nula mesmo em erro');
        System.assertEquals(0, ofertas.size(), 'Em erro (500), deve retornar lista vazia');
    }

    // ⚠️ Usa dados reais de Custom Metadata já implantados na org
    @IsTest(SeeAllData=true)
    static void getFilterOptions_deveLerCustomMetadataEVoltarOpcoes() {
        List<CashbackFiltroOpcao__mdt> ativos = [
            SELECT MasterLabel, Grupo__c, ValorAPI__c, Ativo__c, Ordem__c
            FROM CashbackFiltroOpcao__mdt
            WHERE Ativo__c = true
            ORDER BY Grupo__c, Ordem__c, MasterLabel
            LIMIT 1
        ];

        Test.startTest();
        Object filtros = CashbackMotorController.getFilterOptions();
        Test.stopTest();

        System.assertNotEquals(null, filtros, 'Retorno não pode ser nulo');

        if (!ativos.isEmpty()) {
            CashbackFiltroOpcao__mdt sample = ativos[0];
            String payload = JSON.serialize(filtros);
            System.assert(payload.contains(String.valueOf(sample.Grupo__c)),
                'Deveria conter o grupo do CMT ativo');
            System.assert(payload.contains(String.valueOf(sample.ValorAPI__c)),
                'Deveria conter o ValorAPI__c do CMT ativo');
        } else {
            System.assert(true, 'Sem CMT ativo na org; valida apenas que não quebrou.');
        }
    }
}