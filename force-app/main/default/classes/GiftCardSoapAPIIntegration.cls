public class GiftCardSoapAPIIntegration {

    //Constrói o request para a API de acordo com os parâmetros.
    public static String buildBalanceRequest(String username, String password, String terminalId, String localDateTime, String txId, String currencyId2, String pan, String pin) {
        String soapRequest = 
        '<REQUEST TYPE="BALANCE">' +
        '<USERNAME>'+username+'</USERNAME>' +
        '<PASSWORD>'+password+'</PASSWORD>' +
        '<TERMINALID>'+terminalId+'</TERMINALID>' +
        '<LOCALDATETIME>'+localDateTime+'</LOCALDATETIME>' +
        '<TXID>'+txId+'</TXID>' +
        '<CURRENCY>'+currencyId2+'</CURRENCY>' +
        '<CARD>' +
            '<PAN>'+pan+'</PAN>' +
            '<PIN>'+pin+'</PIN>' +
        '</CARD>' +
        '</REQUEST>';  
    
        return soapRequest;
    }

    public static GiftCardTO executeRequest(String cardId, String cardPassword) {
        Varejo_Api_Callout__mdt config = VarejoAPICalloutDAO.getInstance().getByLabel('Cartao Presente');

        Datetime currentDatetime = Datetime.now();
		String formattedDatetime = currentDatetime.format('yyyy-MM-dd HH:mm:ss');
		System.debug('Formatted Datetime: ' + formattedDatetime);
        
        String Username = config.username__c;
        String Password = config.password__c;
        String TerminalId = 'eee';
        String LocalDateTime = formattedDatetime;
        String Txid = 'PREAUTH2706-0121';
        STRING CurrencyId = '986';
        //Número do cartão.
        String PAN = cardId;
        //Código verificador do cartão.
        String PIN = cardPassword;

        String requestBody = buildBalanceRequest(Username, Password, TerminalId, LocalDateTime, Txid, CurrencyId, PAN, PIN);
        String endPoint = config.endPoint__c;

        HttpResponse response = execute(config.method__c, 'BALANCE', endPoint, requestBody, false, obterHeaderPadrao());
        LogIntegracaoBO.InsertLog('API cartão presente', endPoint, config.method__c, requestBody, 'vazio', String.valueOf(response.getStatusCode()), response.getBody(), 'CRF');


        if (response.getStatusCode() == 200) {
            //A resposta foi bem-sucedida.
            return handleResult(response);
        } else {
            //A resposta não foi bem-sucedida.
            String errorMessage = 'Erro na chamada SOAP: ' + response.getStatusCode() + ' ' + response.getStatus();
            System.debug(errorMessage);
            return null;
        }
    }

    public static HttpResponse execute (String method, String apiMethod, String endpoint, String body, Boolean compressed, Map<String, String> headers) {
        //Método que executa a chamada a API.
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setHeader('SOAPAction', apiMethod);
        request.setHeader('Content-Length', String.valueOf(body.length()));
        request.setTimeout(120000);
        request.setEndpoint(endpoint);

        for (String key : headers.keySet()) {
            request.setHeader(key, headers.get(key));
        }

        if(!String.isEmpty(body)) {
            request.setBody(body);
        }

        request.setCompressed(compressed);

        try{
            response = http.send(request);
        } catch(System.CalloutException e) {
            System.debug('request.getBody(): '+ request.getBody());
            System.debug('Callout error: '+ e);
        }
        return response;
    }

    public static Map<String, String> obterHeaderPadrao() {
        Map <String, String> parametros = new Map <String, String> ();
        parametros.put('Content-Type', 'text/xml; charset=UTF-8'); 
        System.debug('Headers ' + parametros);
        return parametros;
    }

    public static GiftCardTo handleResult(HttpResponse response) {
        //Método que trata o retorno da API.
        GiftCardTo requestResult = new GiftCardTo();

        //Pega o status do resultado
        String responseBody = response.getBody();
        Dom.Document doc = new Dom.Document();
        doc.load(responseBody);
        Dom.XmlNode rootNode = doc.getRootElement();
        Dom.XmlNode specificTag = rootNode.getChildElement('RESULT', null);
        String statusValue = specificTag.getText();
        Dom.Document xmlDocument = new Dom.Document();
        xmlDocument.load(response.getBody());

        if(statusValue == '0') {
            //Sucesso, adiciona a data de validade do cartão e o saldo.
            requestResult.status = '0';
            requestResult.value = getBalance(xmlDocument);
            requestResult.expDate = getExpDate(xmlDocument);
        } else if (statusValue == '23') {
            //Pin do cartão incorreto.
            requestResult.status = '23';
        } else if (StatusValue == '2') {
            //Número do cartão inválido.
            requestResult.status = '2';
        } else if (statusValue == '6') {
            //Cartão não ativado.
            requestResult.status = '6';
        } else if (statusValue == '4') {
            //Cartão vencido, adiciona o saldo e a data.
            requestResult.status = '4';
            requestResult.value = getBalance(xmlDocument);
            requestResult.expDate = getExpDate(xmlDocument);
        }
        else {
            //Outros erros.
            requestResult.status = '99';
        }
        System.debug(requestResult);
        return requestResult;
    }

    //Método recursivo para encontrar uma tag.
    private static Dom.XmlNode findTagByName(Dom.XmlNode parentNode, String tagName) {
        if (parentNode == null) {
            return null;
        }
        
        if (parentNode.getName() == tagName) {
            return parentNode;
        }
        
        for (Dom.XmlNode childNode : parentNode.getChildren()) {
            Dom.XmlNode desiredTag = findTagByName(childNode, tagName);
            if (desiredTag != null) {
                return desiredTag;
            }
        }
        
        return null;
    }

    public static String formatStringBRLMoney(String value) {
        while (value.length() < 4) {
            value = '0' + value;
        }

        Integer index = value.length() - 2;
        value = value.substring(0, index) + ',' + value.substring(index);
        return value;
    }

    public static String formatStringDateTimeToDate(String dateTimeString) {
        String[] parts = dateTimeString.split('[- :]');
        String year = parts[0];
        String month = parts[1];
        String day = parts[2];
        
        String formattedDate = day + '/' + month + '/' + year;

        return formattedDate;
    }

    public static String getBalance(Dom.Document xmlDocument) {
        Dom.XmlNode parentTag = findTagByName(xmlDocument.getRootElement(), 'BALANCE');

        if (parentTag != null) {
            //Find the nested tag within the parent tag.
            Dom.XmlNode nestedTag = findTagByName(parentTag, 'BALANCE_BEFORE');

            if (nestedTag != null) {
                //Get the value of the nested tag.
                String cardValue = nestedTag.getText();
                cardValue = formatStringBRLMoney(cardValue);
                System.debug('Value of nestedTagName: ' + cardValue);
                return cardValue;
            } else {
                //Nested tag not found.
                System.debug('Nested tag not found.');
            }
        } else {
            //Parent tag not found.
            System.debug('Parent tag not found.');
        }

        return null;
    }

    public static String getExpDate(Dom.Document xmlDocument) {
        Dom.XmlNode expDateParentTag = findTagByName(xmlDocument.getRootElement(), 'CARD');

        if (expDateParentTag != null) {
            //Find the nested tag within the parent tag.
            Dom.XmlNode nestedTag = findTagByName(expDateParentTag, 'EXPIRY_DATE');

            if (nestedTag != null) {
                //Get the value of the nested tag.
                String cardExpDate = nestedTag.getText();
                cardExpDate = formatStringDateTimeToDate(cardExpDate);
                System.debug('Value of nestedTagName: ' + cardExpDate);
                return cardExpDate;
            } else {
                //Nested tag not found.
                System.debug('Nested tag not found.');
            }
        } else {
            //Parent tag not found.
            System.debug('Parent tag not found.');
        }
        return null;
    }
}