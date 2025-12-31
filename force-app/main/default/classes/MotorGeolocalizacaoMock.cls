@isTest
global with sharing class MotorGeolocalizacaoMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = '[{"category":"carrefour","type":"Bairro","address":{"street":"AvenidaInterlagos","number":"5800","neighborhood":"EstradaRioBranco","zipCode":"04777-000","city":"SãoPaulo","hasGasStation":false,"hasDrugStore":true,"distanceKm":3.67,"googleMapsLink":"http://maps.google.com/maps?saddr=Current%20Location&daddr=-23.695568,-46.699966","whatsappText":"BAIRROCarrefourBairroInterlagosLocalizadonaAvenidaInterlagosNúmero:5800Bairro:EstradaRioBrancoCidade:SãoPauloEstalojacontacom*DROGARIA*Horáriodeatendimentodesegundaasábado:07:00-22:00DomingoeFeriados:07:00-22:00Cliqueaquielevaremosvocêatélá:ttps://goo.gl/maps/62ekU462gMTJ5Fur8"}}]';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}