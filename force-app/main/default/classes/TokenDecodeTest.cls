@isTest
public class TokenDecodeTest {
    @isTest
    public static void DecodeTokenTest() {
        TokenDecode.Input input = new TokenDecode.Input();
        input.Token = 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJ0aFZhbmJ3c1ZaOENEODdYY2Fabng4TGZ4cTJZTjI4a0tWMVF1dGJJaFRRIn0.eyJqdGkiOiIyODIyYjYyOS05MDZkLTRjNmUtYTI2Mi0wOTcyMTNkNjMxODMiLCJleHAiOjE2NzIwNTg5MTgsIm5iZiI6MCwiaWF0IjoxNjcyMDU3MTE4LCJpc3MiOiJodHRwczovL2tleWNsb2FrLWhvbS5jc2ZjcHYud2NvcnAuY2FycmVmb3VyLmNvbS9hdXRoL3JlYWxtcy9DU0YtQ2FuYWlzLURpZ2l0YWlzIiwic3ViIjoiZjo5ZjBkZDVhNi1lOGQ2LTQ1YTUtOGY2OC1lMTE2MjZjODU3ZjA6OTY2NjM4MzcwNTIiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwd2FfY2FydGFvX2NhcnJlZm91ciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjhlZDQzN2NhLTI4OWYtNDJjNy04YjI1LTQyMzAzODMwYjE3OCIsImFjciI6IjEiLCJzY29wZSI6ImNzZl9wbGF0YWZvcm1hX2RpZ2l0YWlzIHByb2ZpbGUgZW1haWwiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImFjY291bnRfbmFtZSI6IiIsImNwZiI6Ijk2NjYzODM3MDUyIiwidGlwb19jbGllbnRlIjoiMSIsImlkX2VtcHJlc2EiOiIxIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiOTY2NjM4MzcwNTIiLCJlbWFpbCI6Ijk2NjYzODM3MDUyIn0.kKDYpqvq73mptKlGqQQVSxP8FFTVoXqkUJs3spWKn2fbEfBvcdlawQfRZqZh9dBkTBixsoLi3U836QWcoQ2bV3v8mQKB2VXGhoCqzoJnxUC3oeafx8j5vKwlFc2GloL93t8BnCJ7Iv1dUNJz9eJTIrNGC1IozLiConKte689O-ZcJyGrFCoZlQZ6v81VTW7u9gkRUQwmnMp9bMQrxD8R8rGCQUccakuuHJmu0HeX_XcAn86sAQoD96p-tPrP9AcFdxpdk2v1dcZLGFm4qrKlRYWWWsd-zArsqgzlfQKI5j1VsAPoDuXgSgnaGeUwpySxaCBBDP8C_aZSgwq2OQnBVg';

        List<TokenDecode.Input> listToken = new List<TokenDecode.Input>();
        listToken.add(input);

        Test.StartTest();
        List<TokenDecode.Output> output = TokenDecode.DecodeToken(listToken);
        Test.StopTest();

        System.AssertEquals(output[0].jti, '2822b629-906d-4c6e-a262-097213d63183');
        System.AssertEquals(output[0].exp, 1672058918);
        System.AssertEquals(output[0].nbf, 0);
        System.AssertEquals(output[0].iat, 1672057118);
        System.AssertEquals(output[0].iss, 'https://keycloak-hom.csfcpv.wcorp.carrefour.com/auth/realms/CSF-Canais-Digitais');
        System.AssertEquals(output[0].sub, 'f:9f0dd5a6-e8d6-45a5-8f68-e11626c857f0:96663837052');
        System.AssertEquals(output[0].typ, 'Bearer');
        System.AssertEquals(output[0].azp, 'pwa_cartao_carrefour');
        System.AssertEquals(output[0].auth_time, 0);
        System.AssertEquals(output[0].session_state, '8ed437ca-289f-42c7-8b25-42303830b178');
        System.AssertEquals(output[0].acr, '1');
        System.AssertEquals(output[0].scope, 'csf_plataforma_digitais profile email');
        System.AssertEquals(output[0].email_verified, false);
        System.AssertEquals(output[0].account_name, '');
        System.AssertEquals(output[0].cpf, '96663837052');
        System.AssertEquals(output[0].tipo_cliente, '1');
        System.AssertEquals(output[0].id_empresa, '1');
        System.AssertEquals(output[0].preferred_username, '96663837052');
        System.AssertEquals(output[0].email, '96663837052');
    }
}