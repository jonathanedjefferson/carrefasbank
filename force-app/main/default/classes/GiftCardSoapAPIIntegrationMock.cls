@isTest
global with sharing class GiftCardSoapAPIIntegrationMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String body = 
        '<?xml version="1.0" encoding="UTF-8" ?>' + 
        '<RESPONSE TYPE="BALANCE">' +
            '<RESULT>0</RESULT>' +
            '<RESULTTEXT>transaction successful</RESULTTEXT>' +
            '<TERMINALID>eee</TERMINALID>' +
            '<TXID>PREAUTH2706-0121</TXID>' +
            '<HOSTTXID>000002735227</HOSTTXID>' +
            '<LOCALDATETIME>2023-06-05 13:30:38</LOCALDATETIME>' +
            '<SERVERDATETIME>2023-06-06 16:44:39</SERVERDATETIME>' +
            '<CARD>' +
                '<PAN>6361698121000000928</PAN>' +
                '<EXPIRY_YEAR>2023</EXPIRY_YEAR>' +
                '<EXPIRY_MONTH>12</EXPIRY_MONTH>' +
                '<EXPIRY_DATE>2023-12-02 17:08:20</EXPIRY_DATE>' +
            '</CARD>' +
            '<BALANCE>' +
                '<CURRENCY STANDARD="1">' +
                    '<ISOCODE>986</ISOCODE>' +
                    '<NAME>Brazilian real</NAME>' +
                    '<FRACTION>2</FRACTION>' +
                    '<BALANCE>5000</BALANCE>' +
                    '<BALANCE_BEFORE>5000</BALANCE_BEFORE>' +
                    '<RESERVED>0</RESERVED>' +
                    '<RESERVED_BEFORE>0</RESERVED_BEFORE>' +
                '</CURRENCY>' +
            '</BALANCE>' +
        '</RESPONSE>';

        HttpResponse response = new HttpResponse();
        response.setBody(body);
        response.setStatusCode(200);
        return response;
    }
}