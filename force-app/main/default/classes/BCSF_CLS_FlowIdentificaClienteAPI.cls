public class BCSF_CLS_FlowIdentificaClienteAPI {
    @invocableMethod(label='Identifica cliente')
    public static List<Output> identificaCliente(List<Input> inputs){
            
        List<IdentificaClienteTO.DadosTO> lstData = new List<IdentificaClienteTO.DadosTO>();
        List<Output> lstRetorno = new List<Output>();
        
        String unidadeNegocioEntrada = '';
        String telefoneEntrada = '';
        for (Input item : inputs) {
            unidadeNegocioEntrada = item.unidadeNegocio;
            telefoneEntrada = item.telefone;


            
            lstData = BCSF_CLS_IdentificaClienteAPI.calloutMethod(item.chaveToken, item.cpf, 'whatsapp', unidadeNegocioEntrada);
        }

        String telefoneMascarado = null;
        if(String.isNotBlank(telefoneEntrada) && telefoneEntrada.length() >= 10){
            if(telefoneEntrada.length() == 10){
                telefoneMascarado = '(••) ••••-';
            } else {
                telefoneMascarado = '(••) •••••-';
            }
            telefoneMascarado += telefoneEntrada.substring(telefoneEntrada.length() - 4, telefoneEntrada.length());
        }


        Output objOutput;
        for (IdentificaClienteTO.DadosTO item : lstData) {
            objOutput = new Output();

            //Busca cartão primário
            String statusCartaoPrimario = '';
            String statusContaPrimario = '';
            String idCartaoPrimario = '';
            Boolean numeroExiste_e_celularEhSeguro = false;
            Date dataAtual = null;
            Date dataRegistrada = null;

            // Telefone de acesso
            objOutput.TelefoneMascarado = telefoneMascarado;

            for (IdentificaClienteTO.ContratoTO objContrato : item.data.cliente.contaCartao.contratos) {
                
                if(String.isNotBlank(objContrato.dataAberturaConta)){
                    dataAtual = Date.valueOf(objContrato.dataAberturaConta);
                }

                if (objContrato.unidadeNegocio == unidadeNegocioEntrada) {
                    if (dataRegistrada == null || dataRegistrada < dataAtual) {
                        for(IdentificaClienteTO.CartaoTO objCartao : objContrato.cartoes){
                            if(objCartao.ehPrimario){
                                statusCartaoPrimario = objCartao.statusCartao;
                                idCartaoPrimario = objCartao.id;
                                break;
                            }
                        }
                        statusContaPrimario = objContrato.statusConta;
                        dataRegistrada = dataAtual;
                        
                        objOutput.NumeroConta = objContrato.numeroConta;
                        objOutput.LimiteDisponivel = objContrato.valorLimiteDisponivel;
                        objOutput.LimiteTotal = objContrato.valorLimiteTotal;
                        objOutput.StatusConta = objContrato.statusConta;
                        objOutput.unidadeNegocio = objContrato.unidadeNegocio;
                        objOutput.statusCartaoPrimario = statusCartaoPrimario;
                        objOutput.idCartaoPrimario = statusCartaoPrimario;
                        objOutput.tipoCartaoTransversal = String.valueOf(objContrato.tipoCartaoTransversal);
                    }
                }
            }
            for (IdentificaClienteTO.DadosSociaisTO dadosSociais: item.data.cliente.dadosSociais) {
                if (dadosSociais.numeroConta == objOutput.numeroConta) {
                    objOutput.PrimeiroNome = dadosSociais.nomePrimeiro;
                    objOutput.SobrenomeCliente = dadosSociais.nomeMeio;
                    objOutput.UltimoNome = dadosSociais.nomeUltimo;
                    objOutput.tipoEnvioFatura = dadosSociais.tipoEnvioFatura;
                }
            }

            for(IdentificaClienteTO.DadosContatoTO itemData : item.data.cliente.contato.dadosContato){
                if(objOutput.NumeroConta == itemData.numeroConta){
                    if(itemData.emails.size() > 0){
                        String email = itemData.emails.get(0).endereco;
                        objOutput.email = email;
                        objOutput.emailMascarado = Util.mascararEmail(email);
                    }
                    
                    if(itemData.telefones.size() > 0){
                        for(IdentificaClienteTO.TelefoneTO objTelefone : itemData.telefones){
                            Boolean celularExistente = Util.validaCelular(telefoneEntrada, objTelefone) || Util.validaCelular(Util.formataNumeroCelular(telefoneEntrada), objTelefone);
                
                            if(celularExistente && objTelefone.celularSeguro == true) {
                                numeroExiste_e_celularEhSeguro = true;
                                objOutput.DDDCelularSeguro = objTelefone.ddd;
                                break;
                            }
                        }
                    }
                    break;
                }
            }

            List<String> statusValidos = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPermitido' + unidadeNegocioEntrada);
            List<String> statusValidosSemCelularSeguro = StatusCartaoPermitidosDAO.getStatusCartaoPermitido('StatusCartaoPermitidoSemCelularSeguro');
        
            if (objOutput.unidadeNegocio != unidadeNegocioEntrada) {
                objOutput.returnTagBot = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO IDENTIFICADO';
            }else if (!statusValidos.contains(statusCartaoPrimario) && !statusValidosSemCelularSeguro.contains(statusContaPrimario)){
                objOutput.returnTagBot = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM ACESSO';
            }else if(!numeroExiste_e_celularEhSeguro && (!statusValidosSemCelularSeguro.contains(statusCartaoPrimario) && !statusValidosSemCelularSeguro.contains(statusContaPrimario))){
                objOutput.returnTagBot = 'DESCONEXÃO - WHATSAPP ATACADÃO - CLIENTE NÃO TEM CELULAR SEGURO OU INCONSISTÊNCIA DE DADOS';
            }else{
                objOutput.returnTagBot = 'NAVEGAÇÃO - WHATSAPP ATACADÃO - CLIENTE TEM ACESSO';
            }    
            
            lstRetorno.add(objOutput);
        }

        return lstRetorno;
    }

    public class Input {
        @InvocableVariable(label='Token' required=true)
        public String chaveToken;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(label='Telefone' required=true)
        public String telefone;
        @InvocableVariable(label='Unidade de negócio' required=true)
        public String unidadeNegocio;
    }

    public class Output{
        @InvocableVariable
        public String NumeroConta;
        @InvocableVariable
        public Decimal LimiteDisponivel;
        @InvocableVariable
        public Decimal LimiteTotal;
        @InvocableVariable
        public String ReturnTagBot;
        @InvocableVariable
        public String SobrenomeCliente;
        @InvocableVariable
        public String UltimoNome;
        @InvocableVariable
        public String StatusConta;
        @InvocableVariable
        public String TelefoneCliente;
        @InvocableVariable
        public String TelefoneMascarado;
        @InvocableVariable
        public String DDDCelularSeguro;
        @InvocableVariable
        public String PrimeiroNome;
        @InvocableVariable
        public String statusCartaoPrimario;
        @InvocableVariable
        public String idCartaoPrimario;
        @InvocableVariable
        public String unidadeNegocio;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String emailMascarado;
        @InvocableVariable
        public String tipoEnvioFatura;
        @InvocableVariable
        public String tipoCartaoTransversal;
    }
}