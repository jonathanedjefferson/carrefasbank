@IsTest
global class IdentificarSocioTest {
    @IsTest
    static void testGetInfoSocio() {
        Test.setMock(HttpCalloutMock.class, new IdentificarSocioMock());
        IdentificarSocio.getInfoSocio('53058919816');
    }

    global class IdentificarSocioMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBody('{"uniqueid": 2047852,"firstname": "Atualiza","cpf": "03849924122","lastname": "Atualizadttttttt","renovationdate": "2024-05-01","favoritestore": 6546,"store": "4932","status": "Ativo","aka": "Pedro Neves","fullnumber": "10555100810295410","photo": "","birthdate": "2000-10-10","email": "atualiza@gmail.com","phone": "11999999999","cep": "06210050","streetname": "Rua Ana Zozi Toni","number": "82","complement": "apt 111","neighbour": "Presidente Altino","city": "Osasco","state": "SP","autorenovation": false,"trialpass": false,"memberid": 7333591}');
            return response;
        }
    }
}