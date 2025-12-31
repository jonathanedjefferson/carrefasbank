@isTest
global with sharing class ConsultarChaveNFTest {
    @isTest
    public static void test() {
        Test.setMock(HttpCalloutMock.class, new ConsultarChaveNFMock());
        ConsultarChaveNF.makeAPIRequest('12345');
    }

    global with sharing class ConsultarChaveNFMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = '{' +
            '"affiliatedId" : "",' +
            '"callCenterOperatorUserName" : "",' +
            '"callCenterOperatorEmail" : "",' +
            '"consignments" : [ {' +
              '"consignmentCode" : "5333698790001",' +
              '"consignmentState" : "DELIVERED",' +
              '"cubageWeight" : 0.283,' +
              '"delivery" : {' +
                '"carrierName" : "",' +
                '"carrierCnpj" : "corr",' +
                '"estimate" : "4bd",' +
                '"estimateDate" : "2023-08-18T17:18:35.570Z[UTC]",' +
                '"modality" : "MARKETPLACE",' +
                '"receiverDocument" : "53058919816",' +
                '"receiverName" : "Ayame Gomes",' +
                '"shippingAddress" : {' +
                  '"addressType" : "residential",' +
                  '"postalCode" : "36047-100",' +
                  '"state" : "MG",' +
                  '"neighborhood" : "Bandeirantes",' +
                  '"complement" : "Apartamento 101 Bloco G",' +
                  '"number" : "565",' +
                  '"country" : "BRA",' +
                  '"street" : "Rua Aurora Tristão",' +
                  '"city" : "Juiz de Fora",' +
                  '"externalAddressId" : "5023839776580"' +
                '},' +
                '"store" : "",' +
                '"selectedSla" : "normal-22-33",' +
                '"trackingCode" : "4854329"' +
              '},' +
              '"invoiceAddress" : {' +
                '"addressType" : "residential",' +
                '"postalCode" : "36047-100",' +
                '"state" : "MG",' +
                '"neighborhood" : "Bandeirantes",' +
                '"complement" : "Apartamento 101 Bloco G",' +
                '"number" : "565",' +
                '"country" : "BRA",' +
                '"street" : "Rua Aurora Tristão",' +
                '"city" : "Juiz de Fora",' +
                '"externalAddressId" : "5023839776580"' +
              '},' +
              '"invoices" : [ {' +
                '"number" : "4854329",' +
                '"serial" : "0",' +
                '"creationDate" : "1969-12-31T07:00Z[UTC]",' +
                '"key" : "31230833041260131501550000048543291120029537",' +
                '"amount" : 871.33,' +
                '"type" : "Output",' +
                '"invoiceUrl" : ""' +
              '} ],' +
              '"items" : [ {' +
                '"basePrice" : 849.0,' +
                '"categories" : [ {' +
                  '"id" : 18,' +
                  '"name" : "Eletrodomésticos"' +
                '}, {' +
                  '"id" : 380,' +
                  '"name" : "Fogões"' +
                '} ],' +
                '"discount" : 0.0,' +
                '"ean" : "7897180507565",' +
                '"freightPrice" : 22.33,' +
                '"gift" : false,' +
                '"height" : 94.7,' +
                '"imageUrl" : "https://carrefourbr.vteximg.com.br/arquivos/ids/80902429-120-120/4be5ff0c0dc342b885561b2c28715304.jpg?v=638009112007870000",' +
                '"detailUrl" : "/fogao-4-bocas-new-fastcook-com-grades-duplas-atlas-mp928575299/p",' +
                '"length" : 60.3,' +
                '"name" : "Fogão 4 Bocas New Fastcook Com Grades Duplas Atlas",' +
                '"price" : 849.0,' +
                '"quantity" : 1,' +
                '"sellerSku" : "709",' +
                '"sellerName" : "26365",' +
                '"type" : "NORMAL",' +
                '"vtexItemId" : "321404225",' +
                '"weight" : 21500.0,' +
                '"width" : 49.6,' +
                '"disruptionQuantity" : 0,' +
                '"availableQuantity" : 1,' +
                '"id" : "0760dc36-1c5f-43e9-8625-e7653884fb20",' +
                '"refId" : "MP928575299"' +
              '} ],' +
              '"realWeight" : 21.5,' +
              '"totalDiscounts" : 0.0,' +
              '"totalFreight" : 22.33,' +
              '"totalItemValue" : 849.0,' +
              '"totalValue" : 871.33,' +
              '"type" : "MARKETPLACE_IN",' +
              '"links" : {' +
                '"returnConsignment" : {' +
                  '"href" : "/v1/orders/533369879/consignments/5333698790001/return",' +
                  '"rel" : "consignment",' +
                  '"type" : "PUT"' +
                '}' +
              '},' +
              '"status" : {' +
                '"status" : "ERS",' +
                '"creationTime" : "2023-08-16T14:15:55.625Z[UTC]",' +
                '"description" : "Entrega Realizada pelo Parceiro",' +
                '"color" : "GREEN"' +
              '},' +
              '"consignmentStatus" : "ERS",' +
              '"isCarrefourEnvios" : false' +
            '} ],' +
            '"creationDate" : "2023-08-13T17:17:45.500Z[UTC]",' +
            '"customerDocument" : "53058919816",' +
            '"customerDocumentType" : "cpf",' +
            '"customerEmail" : "ayamegomes@gmail.com",' +
            '"customerExternalEmail" : "ayamegomes@gmail.com-234801297129b.ct.vtex.com.br",' +
            '"customerFirstName" : "Ayame",' +
            '"customerLastName" : "Gomes",' +
            '"customerPhone" : "+5512992056397",' +
            '"marketplaceOrderId" : "",' +
            '"orderCode" : "533369879",' +
            '"orderGroup" : "1353933369879",' +
            '"orderOrigin" : "carrefourbr",' +
            '"payments" : [ {' +
              '"paymentId" : "A942FBFD5DDC4582B36F1BE376DF6F9B",' +
              '"paymentMethod" : "CREDIT_CARD",' +
              '"paymentValue" : 871.33,' +
              '"lastDigits" : "2721",' +
              '"installments" : 10,' +
              '"paymentSystemName" : "Visa",' +
              '"nsu" : "1692752519",' +
              '"transactionId" : "EEBAB222C3C346A6AE139A7FA7A285A0",' +
              '"group" : "creditCard",' +
              '"tid" : "ch_4zZXPnbTRTBPOQ9J",' +
              '"paymentStatus" : "Pagamento Confirmado",' +
              '"paymentStatusUpdateDate" : "2023-08-13T17:18:42.610Z[UTC]"' +
            '} ],' +
            '"principalCode" : "1353933369879-01",' +
            '"sellerId" : "26365",' +
            '"sellerName" : "Casas Bahia",' +
            '"links" : { },' +
            '"totalValue" : 871.33,' +
            '"totalItemValue" : 849.0,' +
            '"totalDiscounts" : 0.0,' +
            '"totalFreight" : 22.33,' +
            '"totalChanges" : 0,' +
            '"salesChannel" : "CARREFOUR",' +
            '"originApplication" : "VTEX"' +
          '}';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}
}