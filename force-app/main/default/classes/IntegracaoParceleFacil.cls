public class IntegracaoParceleFacil {
    public static  IntegracaoParceleFacilTO.OutputTokenServico tokenServices(String cpfUser, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('TokenServicosParcele');

        user userDRT = BCSF_CancelamentoContaDAO.getInstance().getUser(String.valueOf(UserInfo.getUserId()));
        String loginOperador = userDRT.DRT__c == null? 'X' : userDRT.DRT__c;

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/x-www-form-urlencoded',
                'cpf' => cpfUser,
                'operador' => loginOperador,
                'perfilOperador' => loginOperador,
                'Cookie' => 'visid_incap_2400284=oTuPntTUTa6x8cYD1PFns3D01GUAAAAAQUIPAAAAAABq9WQPBQPQaPWai4cFVxNm',
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Token Serviços Parcele Fácil', 
            config.Endpoint__c + config.Path__c, 
            config.Method__c, 
            config.Body__c,  
            cpfUser, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal.capitalize()
        );

        IntegracaoParceleFacilTO.OutputTokenServico retorno = new IntegracaoParceleFacilTO.OutputTokenServico();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204'){
            retorno = (IntegracaoParceleFacilTO.OutputTokenServico) System.JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputTokenServico.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputModalidades modalidadeParcele(String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ModalidadeParcele');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Modalidades Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputModalidades retorno = new IntegracaoParceleFacilTO.OutputModalidades();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputModalidades) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputModalidades.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputSimulacao simularFaturaFechada(String dataEntrada, String valorEntrada, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SimularFaturaFechParcele');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);

        if(!String.isBlank(valorEntrada)){
            endpoint += '?ValorEntrada=' + valorEntrada;
        }

        if(!String.isBlank(dataEntrada)){
            endpoint += String.isBlank(valorEntrada) ? '?DataEntrada=' +  dataEntrada: '&DataEntrada=' + dataEntrada;
        }

        if(String.isBlank(valorEntrada) && String.isBlank(dataEntrada)){
            endpoint += '?ComJurosEncargos=true';
        }else{
            endpoint += '&ComJurosEncargos=true';
        }


        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
            }, 
            config.Body__c, 
            Integer.valueof(config.Timeout__c)
        );
        

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Simular parcelamento fatura fechada', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            '',
            idEmpresa,
            canal
        );
            
        IntegracaoParceleFacilTO.OutputSimulacao retorno = new IntegracaoParceleFacilTO.OutputSimulacao();
        retorno = (IntegracaoParceleFacilTO.OutputSimulacao) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputSimulacao.class);
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputSimulacao simularSaldoTotal(String dataEntrada, String valorEntrada, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SimularSaldoTotalParcele');
        
        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);

        if(!String.isBlank(valorEntrada)){
            endpoint += '?ValorEntrada=' + valorEntrada;
        }

        if(!String.isBlank(dataEntrada)){
            endpoint += String.isBlank(valorEntrada) ? '?DataEntrada=' +  dataEntrada: '&DataEntrada=' + dataEntrada;
        }

        if(String.isBlank(valorEntrada) && String.isBlank(dataEntrada)){
            endpoint += '?ComJurosEncargos=true';
        }else{
            endpoint += '&ComJurosEncargos=true';
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Simular parcelamento saldo total', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            '',
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputSimulacao retorno = new IntegracaoParceleFacilTO.OutputSimulacao();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputSimulacao) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputSimulacao.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputSimulacao simularSaldoParcial(List<IntegracaoParceleFacilTO.Transacao> transacoes,String dataEntrada, String valorEntrada, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('SimularSaldoParcialParcele');

        String endpoint = config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta);

        if(!String.isBlank(valorEntrada)){
            endpoint += '?ValorEntrada=' + valorEntrada;
        }

        if(!String.isBlank(dataEntrada)){
            endpoint += String.isBlank(valorEntrada) ? '?DataEntrada=' +  dataEntrada: '&DataEntrada=' + dataEntrada;
        }

        if(String.isBlank(valorEntrada) && String.isBlank(dataEntrada)){
            endpoint += '?ComJurosEncargos=true';
        }else{
            endpoint += '&ComJurosEncargos=true';
        }
        
        config.Body__c = config.Body__c.replace('{transacoes}', JSON.serialize(transacoes));

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            endpoint, 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'ValorEntrada' => valorEntrada,
                'DataEntrada' => dataEntrada,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
        );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Simular parcelamento saldo parcial', 
            endpoint, 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            '',
            idEmpresa,
            canal
        );
            
        IntegracaoParceleFacilTO.OutputSimulacao retorno = new IntegracaoParceleFacilTO.OutputSimulacao();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputSimulacao) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputSimulacao.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputContratar contratarSaldoTotal(IntegracaoParceleFacilTO.FormaPagamento formaPagamento, integracaoParceleFacilTO.Valor valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContratarSaldoTotalParcele');

        String entrada = String.isBlank(JSON.serialize(valorEntrada)) ? '' : JSON.serialize(valorEntrada);

        config.Body__c = config.Body__c.replace('{valorEntrada}', entrada);
        config.Body__c = config.Body__c.replace('{dataPagamento}', dataPagamento);
        config.Body__c = config.Body__c.replace('{formaPagamento}', JSON.serialize(formaPagamento));
        config.Body__c = config.Body__c.replace('{tipoPagamento}', tipoPagamento);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
            );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Contratar parcelamento saldo total', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputContratar retorno = new IntegracaoParceleFacilTO.OutputContratar();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputContratar) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputContratar.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputContratar contratarFaturaFechada(IntegracaoParceleFacilTO.FormaPagamento formaPagamento, integracaoParceleFacilTO.Valor valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContratarFaturaFechadaParcele');

        String entrada = String.isBlank(JSON.serialize(valorEntrada)) ? '' : JSON.serialize(valorEntrada);
        
        config.Body__c = config.Body__c.replace('{valorEntrada}', entrada);
        config.Body__c = config.Body__c.replace('{dataPagamento}', dataPagamento);
        config.Body__c = config.Body__c.replace('{formaPagamento}', JSON.serialize(formaPagamento));
        config.Body__c = config.Body__c.replace('{tipoPagamento}', tipoPagamento);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
            );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Contratar parcelamento fatura fechada', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputContratar retorno = new IntegracaoParceleFacilTO.OutputContratar();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputContratar) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputContratar.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputContratar contratarSaldoParcial(IntegracaoParceleFacilTO.FormaPagamento formaPagamento, List<IntegracaoParceleFacilTO.Transacao> transacoes, integracaoParceleFacilTO.Valor valorEntrada, String dataPagamento,String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ContratarSaldoParcialParcele');

        String entrada = String.isBlank(JSON.serialize(valorEntrada)) ? '' : JSON.serialize(valorEntrada);

        config.Body__c = config.Body__c.replace('{transacoes}', JSON.serialize(transacoes));
        config.Body__c = config.Body__c.replace('{valorEntrada}', entrada);
        config.Body__c = config.Body__c.replace('{dataPagamento}', dataPagamento);
        config.Body__c = config.Body__c.replace('{formaPagamento}', JSON.serialize(formaPagamento));
        config.Body__c = config.Body__c.replace('{tipoPagamento}', tipoPagamento);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
            config.Body__c,
            Integer.valueof(config.Timeout__c)
            );

        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Contratar parcelamento saldo parcial', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputContratar retorno = new IntegracaoParceleFacilTO.OutputContratar();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputContratar) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputContratar.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputDefault enviarEmail(String parceleId, String email, String tipoPagamento ,String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('EnviarEmailParcele');

        if(tipoPagamento == 'default'){
            Map<String, String> bodyFormat = (Map<String, String>) JSON.deserialize(config.Body__c, Map<String, String>.class);
            bodyFormat.remove('tipoPagamento');
            config.Body__c = JSON.serialize(bodyFormat);
            config.Body__c = config.Body__c.replace('{email}', email);
            config.Body__c = config.Body__c.replace('{parceleId}', parceleId);
        }else{
            config.Body__c = config.Body__c.replace('{email}', email);
            config.Body__c = config.Body__c.replace('{parceleId}', parceleId);
            config.Body__c = config.Body__c.replace('"{tipoPagamento}"', tipoPagamento);
        }

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Enviar E-mail Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputDefault retorno = new IntegracaoParceleFacilTO.OutputDefault();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            retorno.statusCode = status;
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        retorno.statusCode = status;
        return retorno;
    }
    
    public static IntegracaoParceleFacilTO.OutputListarPerfis listarPerfis(String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarPerfisParcele');
        
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Perfis Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputListarPerfis retorno = new IntegracaoParceleFacilTO.OutputListarPerfis();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputListarPerfis) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputListarPerfis.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputDefault alterarPerfil(String nomePerfil, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('AlterarPerfilParcele');
        
        config.Body__c = config.Body__c.replace('{perfil}', nomePerfil);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Alterar perfil Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputDefault retorno = new IntegracaoParceleFacilTO.OutputDefault();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.StatusAPI = 'OK';
            retorno.statusCode = status;
            return retorno;
        }
        IntegracaoParceleFacilTO.OutputError mensagemError = (IntegracaoParceleFacilTO.OutputError) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputError.class);
        retorno.statusAPI = 'ERROR';
        retorno.statusCode = status;
        retorno.codigoErro = mensagemError.codigoErro;
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputPagamentoEntrada pagamentoEntrada(IntegracaoParceleFacilTO.InputPagamentoEntrada pagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('PagamentoEntradaParcele');
        
        String body = JSON.serialize(pagamento);
        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                body, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Pagamento Entrada Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            body, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputPagamentoEntrada retorno = new IntegracaoParceleFacilTO.OutputPagamentoEntrada();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (IntegracaoParceleFacilTO.OutputPagamentoEntrada) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputPagamentoEntrada.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static Blob downloadContrato(String parceleId, String tipoPagamento, String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('DownloadContratoParcele');

        config.Body__c = config.Body__c.replace('{parceleId}', parceleId);
        config.Body__c = config.Body__c.replace('{tipoPagamento}', tipoPagamento);

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Download Contrato Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            null,
            idEmpresa,
            canal
            );
            
        Blob retorno;
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = objHttpResponse.getBodyAsBlob();
            return retorno;
        }
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputGetPerfil getPerfil(String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('GetPerfilParcele');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Get perfil Parcele Fácil', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputGetPerfil retorno = new IntegracaoParceleFacilTO.OutputGetPerfil();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        retorno = (IntegracaoParceleFacilTO.OutputGetPerfil) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputGetPerfil.class);
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputListarParcelePendente listarParcelePendente(String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarParcelePendentes');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Parcele Pendentes', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputListarParcelePendente retorno = new IntegracaoParceleFacilTO.OutputListarParcelePendente();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (IntegracaoParceleFacilTO.OutputListarParcelePendente) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputListarParcelePendente.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }

    public static IntegracaoParceleFacilTO.OutputListarContratados listarParceleContratados(String numeroConta, String cpf, String canal, String idEmpresa){
        CarrefourAPICallout__mdt config = CarrefourAPICalloutDAO.getInstance().getByLabel('ListarParceleContratados');

        HttpResponse objHttpResponse = Util.executarHttpRequest(
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            
            new Map<String, String> {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer '+ tokenServices(cpf, canal, idEmpresa).access_token,
                'x-uat' => config.UAT__c
                }, 
                config.Body__c, 
                Integer.valueof(config.Timeout__c)
            );
                
        // REGISTRANDO LOG DE INTEGRAÇÃO
        LogIntegracaoBO.InsertLog(
            'Listar Parcele Contratados', 
            config.Endpoint__c + config.Path__c.replace('{numeroConta}', numeroConta), 
            config.Method__c, 
            config.Body__c, 
            cpf, 
            String.valueOf(objHttpResponse.getStatusCode()), 
            objHttpResponse.getBody(),
            idEmpresa,
            canal
            );
            
        IntegracaoParceleFacilTO.OutputListarContratados retorno = new IntegracaoParceleFacilTO.OutputListarContratados();
        String status = String.valueOf(objHttpResponse.getStatusCode());
        if(status == '200' || status == '204' || status.equalsIgnoreCase('OK') || status.equalsIgnoreCase('success')){
            retorno = (IntegracaoParceleFacilTO.OutputListarContratados) JSON.deserialize(objHttpResponse.getBody(), IntegracaoParceleFacilTO.OutputListarContratados.class);
            retorno.statusAPI = 'OK';
            return retorno;
        }
        
        retorno.statusAPI = 'ERROR';
        return retorno;
    }
}