@isTest
public with sharing class OfertaSeguroWhatsAppTest {
    public static testmethod void constructTest() { //5 of 5 line covered
        OfertaSeguro.ProdutoTO produto = New OfertaSeguro.ProdutoTO();
        produto.anosVigencia = 5;
        produto.codigoProduto = '1883';
        produto.descricao = 'Reembolso das despesas com o funeral em caso de morte acidental.';
        produto.nomeProduto = 'Seguro Acidente Pessoal com Sorteio CSF - Zurich';
        produto.seguradora= 'ZURICH';
        
        OfertaSeguro.coberturaTO cobertura = new OfertaSeguro.coberturaTO();
        cobertura.descricao = 'Reembolso de gastos com o funeral em até R$ 5.000,00. O valor é pago a quem comprovar que arcou com as despesas do funeral do segurado.';
        cobertura.observacao = '';
        cobertura.titulo = 'Morte acidental';

        OfertaSeguro.coberturasPlanoTO cobeturasplano = new OfertaSeguro.coberturasPlanoTO();
        cobeturasplano.idPlano = '2229';
        cobeturasplano.nomePlano = 'Plano 2';
        cobeturasplano.valorParcela = 'R$ 5,49';

        OfertaSeguro.ElegibilidadeTO elegibilidade = new OfertaSeguro.ElegibilidadeTO(); 
        elegibilidade.nome = 'Antonio Ferraz Rocha';
        elegibilidade.status= 1;

    }

    @istest
    public static void OfertaSeguroTest() {
        Test.setMock(HttpCalloutMock.class, new OfertaSeguroMock());
        string numeroConta = '37000119869';
        Integer idEmpresa = 1;
        string tokenLogado = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiJiOWM4MDcwZi00ZDg2LTRiZGEtOTdmZi1lODBhZmIyYmM1YTMiLCJleHAiOjE2ODYwMDMxMjgsIm5iZiI6MCwiaWF0IjoxNjg2MDAxMzI4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6OTg2OTM2NzgzNjEgIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicHdhX2NhcnRhb19jYXJyZWZvdXIiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI2MTExZjMyMy1hNjMwLTQzOGItYjI2Ni00ZmEzMDg1MWM5ZTIiLCJhY3IiOiIxIiwic2NvcGUiOiJjc2ZfcGxhdGFmb3JtYV9kaWdpdGFpcyBwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJhY2NvdW50X25hbWUiOiIiLCJjcGYiOiI5ODY5MzY3ODM2MSAiLCJ0aXBvX2NsaWVudGUiOiIxIiwiaWRfZW1wcmVzYSI6IjEiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiI5ODY5MzY3ODM2MSAiLCJlbWFpbCI6Ijk4NjkzNjc4MzYxICJ9.HolW81I6ioVr9fIKry4FMVF8CyadOvd6OYaiYcCtUMGmLgkgy08U_ZIhjracWdubBcbmwaYVZmjvubaeIKgDVim8YXgqllwmJrcE1lkcHzQICxnwqy0NlhJtEa3S8CsFlIunVMiZdDQOle2AGFbf8StHw2rIedipbjBxFFttfpQX5ErCMkFGKdv5JEazfgcNlFMXKQp_T4gByfMfQNARwiwkOvgpgLYndJETuWcH5yQ9AFonNkkSKVejaeFaeDNYo1lvSq9W0kJ4u3BB2ITwuID33j77DX0oS1oJywsVWh9n-FygJzdmpR1_t9WW9NMVpNJUawjKRtBtMP9Qm8-CYA';

        OfertaSeguroWhatsApp.RequestSeguro requestController = new OfertaSeguroWhatsApp.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.cpf = '40988877765';
        requestController.canal = 'Whatsapp';


        Test.startTest();
         OfertaSeguro.ElegibilidadeTO response = OfertaSeguro.getElegibilidade(numeroConta, idEmpresa, null, tokenLogado, 'Whatsapp', '40988877765');
         List<OfertaSeguroWhatsApp.ResponseElegibilidade> responseController = OfertaSeguroWhatsApp.OfertaSeguro(new List<OfertaSeguroWhatsApp.RequestSeguro>{requestController});
         Test.stopTest();
        System.AssertNotEquals(response,Null);
        System.AssertNotEquals(responseController,Null);
    }

    @istest
    public static void OfertaSeguroErroAPI() {
        Test.setMock(HttpCalloutMock.class, new OfertaSeguroErroAPIMock());
        string numeroConta = '37000119869';
        Integer idEmpresa = 1;
        string tokenLogado = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiJiOWM4MDcwZi00ZDg2LTRiZGEtOTdmZi1lODBhZmIyYmM1YTMiLCJleHAiOjE2ODYwMDMxMjgsIm5iZiI6MCwiaWF0IjoxNjg2MDAxMzI4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6OTg2OTM2NzgzNjEgIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicHdhX2NhcnRhb19jYXJyZWZvdXIiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI2MTExZjMyMy1hNjMwLTQzOGItYjI2Ni00ZmEzMDg1MWM5ZTIiLCJhY3IiOiIxIiwic2NvcGUiOiJjc2ZfcGxhdGFmb3JtYV9kaWdpdGFpcyBwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJhY2NvdW50X25hbWUiOiIiLCJjcGYiOiI5ODY5MzY3ODM2MSAiLCJ0aXBvX2NsaWVudGUiOiIxIiwiaWRfZW1wcmVzYSI6IjEiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiI5ODY5MzY3ODM2MSAiLCJlbWFpbCI6Ijk4NjkzNjc4MzYxICJ9.HolW81I6ioVr9fIKry4FMVF8CyadOvd6OYaiYcCtUMGmLgkgy08U_ZIhjracWdubBcbmwaYVZmjvubaeIKgDVim8YXgqllwmJrcE1lkcHzQICxnwqy0NlhJtEa3S8CsFlIunVMiZdDQOle2AGFbf8StHw2rIedipbjBxFFttfpQX5ErCMkFGKdv5JEazfgcNlFMXKQp_T4gByfMfQNARwiwkOvgpgLYndJETuWcH5yQ9AFonNkkSKVejaeFaeDNYo1lvSq9W0kJ4u3BB2ITwuID33j77DX0oS1oJywsVWh9n-FygJzdmpR1_t9WW9NMVpNJUawjKRtBtMP9Qm8-CYA';

        OfertaSeguroWhatsApp.RequestSeguro requestController = new OfertaSeguroWhatsApp.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.cpf = '40988877765';
        requestController.canal = 'Whatsapp';


        Test.startTest();
         OfertaSeguro.ElegibilidadeTO response = OfertaSeguro.getElegibilidade(numeroConta, idEmpresa, null, tokenLogado, 'Whatsapp', '40988877765');
         List<OfertaSeguroWhatsApp.ResponseElegibilidade> responseController = OfertaSeguroWhatsApp.OfertaSeguro(new List<OfertaSeguroWhatsApp.RequestSeguro>{requestController});
         Test.stopTest();
         Assert.areEqual('ERRO',responseController[0].elegivel);
    }

    @istest
    public static void OfertaSeguroNaoElegivel() {
        Test.setMock(HttpCalloutMock.class, new OfertaSeguroNaoElegivelMock());
        string numeroConta = '37000119869';
        Integer idEmpresa = 1;
        string tokenLogado = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiJiOWM4MDcwZi00ZDg2LTRiZGEtOTdmZi1lODBhZmIyYmM1YTMiLCJleHAiOjE2ODYwMDMxMjgsIm5iZiI6MCwiaWF0IjoxNjg2MDAxMzI4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6OTg2OTM2NzgzNjEgIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoicHdhX2NhcnRhb19jYXJyZWZvdXIiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI2MTExZjMyMy1hNjMwLTQzOGItYjI2Ni00ZmEzMDg1MWM5ZTIiLCJhY3IiOiIxIiwic2NvcGUiOiJjc2ZfcGxhdGFmb3JtYV9kaWdpdGFpcyBwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJhY2NvdW50X25hbWUiOiIiLCJjcGYiOiI5ODY5MzY3ODM2MSAiLCJ0aXBvX2NsaWVudGUiOiIxIiwiaWRfZW1wcmVzYSI6IjEiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiI5ODY5MzY3ODM2MSAiLCJlbWFpbCI6Ijk4NjkzNjc4MzYxICJ9.HolW81I6ioVr9fIKry4FMVF8CyadOvd6OYaiYcCtUMGmLgkgy08U_ZIhjracWdubBcbmwaYVZmjvubaeIKgDVim8YXgqllwmJrcE1lkcHzQICxnwqy0NlhJtEa3S8CsFlIunVMiZdDQOle2AGFbf8StHw2rIedipbjBxFFttfpQX5ErCMkFGKdv5JEazfgcNlFMXKQp_T4gByfMfQNARwiwkOvgpgLYndJETuWcH5yQ9AFonNkkSKVejaeFaeDNYo1lvSq9W0kJ4u3BB2ITwuID33j77DX0oS1oJywsVWh9n-FygJzdmpR1_t9WW9NMVpNJUawjKRtBtMP9Qm8-CYA';

        OfertaSeguroWhatsApp.RequestSeguro requestController = new OfertaSeguroWhatsApp.RequestSeguro();
        requestController.idEmpresa = idEmpresa;
        requestController.numeroConta = numeroConta;
        requestController.cpf = '40988877765';
        requestController.canal = 'Whatsapp';


        Test.startTest();
         OfertaSeguro.ElegibilidadeTO response = OfertaSeguro.getElegibilidade(numeroConta, idEmpresa, null, tokenLogado, 'Whatsapp', '40988877765');
         List<OfertaSeguroWhatsApp.ResponseElegibilidade> responseController = OfertaSeguroWhatsApp.OfertaSeguro(new List<OfertaSeguroWhatsApp.RequestSeguro>{requestController});
         Test.stopTest();
        Assert.areEqual('NAO ELEGIVEL',responseController[0].elegivel);
    }
}