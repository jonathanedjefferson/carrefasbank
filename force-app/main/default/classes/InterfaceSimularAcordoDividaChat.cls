public with sharing class InterfaceSimularAcordoDividaChat {
    @InvocableMethod(label='Simular Acordo Divida Chat')
    public static List<ResponseSimularAcordo> SimularAcordo(List<RequestSimularAcordo> parametersRequest){
    
        List<ResponseSimularAcordo> toReturn = new List<ResponseSimularAcordo>();
        ResponseSimularAcordo responseSimularAcordo = new ResponseSimularAcordo();

        Integer quantidadeParcelasSolicitada = 0;
        AcordoDivida.OutputSimularAcordo simularAcordo = null;
        for(RequestSimularAcordo request: parametersRequest){
            Date dataPrimeiraParcela = Util.stringToDate(request.vencimentoPrimeiraParcela, '/');
            String diaVencimentoDemaisParcelas = dataPrimeiraParcela.day() + '';
            String vencimentoPrimeiraParcela = Util.formatYYYYMMDD(request.vencimentoPrimeiraParcela, '/', '-');
            quantidadeParcelasSolicitada = request.quantidadeParcelas;
            
            simularAcordo = AcordoDivida.SimularAcordo(request.identificadorAcordo, vencimentoPrimeiraParcela, diaVencimentoDemaisParcelas, String.valueOf(quantidadeParcelasSolicitada), request.idEmpresa, request.cpf, request.canal);         
        }
                        
        if(simularAcordo == null || simularAcordo.planoParcelamentoParceirosDto == null){
            responseSimularAcordo.statusRetorno = 'ERRO';
        } else {
            responseSimularAcordo.statusRetorno = 'OK';
            List<AcordoDivida.PlanoParcelamento> planosParcelamentoParceirosDto = simularAcordo.planoParcelamentoParceirosDto;
            responseSimularAcordo.numeroMaximoParcelamento = planosParcelamentoParceirosDto.size(); 
            responseSimularAcordo.numeroOpcoesDisponiveis = planosParcelamentoParceirosDto.size(); 
            
            String idsPlanosAcordo = '';
            String valoresPlanosAcordo = '';
            String identificadoresPlanosAcordo = '';
            String identificadoresPlanosAcordo2 = '';
            String descontosPlanosAcordo = '';
            Integer quantidadeParcelas =  quantidadeParcelasSolicitada;
            if(quantidadeParcelas == 999){
                quantidadeParcelas = 1;
            }
            
            List<String> listOpcoesAcordo = new List<String>();
            String opcaoMenu = '';
            Integer count = 1;
            for(AcordoDivida.PlanoParcelamento plano : planosParcelamentoParceirosDto){
            
                if(plano.quantidadeParcelas == 1){
                    opcaoMenu = 'À vista, no valor de R$' + StringUtils.getCurrencyFormat(plano.valorParcela);
                } else {
                    opcaoMenu = 'Em ' + plano.quantidadeParcelas + ' parcelas de R$' + StringUtils.getCurrencyFormat(plano.valorParcela);
                }
                                
                if(plano.quantidadeParcelas == quantidadeParcelas){
                    responseSimularAcordo.valorPlanoAcordo = 'R$' + StringUtils.getCurrencyFormat(plano.valorParcela);
                    responseSimularAcordo.descontoPlanoAcordo = 'R$' + StringUtils.getCurrencyFormat(plano.valorDeDesconto);
                    responseSimularAcordo.identificadorPlanoAcordo = plano.identificador;
                    responseSimularAcordo.numeroParcelaPlanoAcordo = String.valueOf(plano.quantidadeParcelas);
                    responseSimularAcordo.percentualDescontoPlanoAcordo = plano.percentualDesconto + '%';
                    Decimal valorFinal = plano.valorParcela * plano.quantidadeParcelas;
                    responseSimularAcordo.valorFinalPlanoAcordo = 'R$' + StringUtils.getCurrencyFormat(valorFinal);
                    if(quantidadeParcelas == 1){
                        listOpcoesAcordo.add(opcaoMenu); 
                    } else {
                        listOpcoesAcordo.add(0, opcaoMenu); 
                    }
                } else {
                    listOpcoesAcordo.add(opcaoMenu);    
                }
                
                if(999 != quantidadeParcelasSolicitada){
                    idsPlanosAcordo += plano.quantidadeParcelas + ';';
                    valoresPlanosAcordo += StringUtils.getCurrencyFormat(plano.valorParcela) + ';';
                    descontosPlanosAcordo += 'R$' + StringUtils.getCurrencyFormat(plano.valorDeDesconto) + '(' + String.valueOf(plano.percentualDesconto.format()) + '%)' + ';';
                    if(count < 4){
                        identificadoresPlanosAcordo += plano.identificador + ';';
                    } else {
                        identificadoresPlanosAcordo2 += plano.identificador + ';';
                    }
                    count++;
                }
            }
            
            listOpcoesAcordo.add('Conferir outras opções');
            responseSimularAcordo.listOpcoesAcordo = listOpcoesAcordo;
            responseSimularAcordo.idsPlanosAcordo = idsPlanosAcordo;
            responseSimularAcordo.valoresPlanosAcordo = valoresPlanosAcordo;
            responseSimularAcordo.identificadoresPlanosAcordo = identificadoresPlanosAcordo;
            responseSimularAcordo.identificadoresPlanosAcordo2 = identificadoresPlanosAcordo2;
            responseSimularAcordo.descontosPlanosAcordo = descontosPlanosAcordo;
        }
            
        toReturn.add(responseSimularAcordo);
        return toReturn;
    }
        
    public class RequestSimularAcordo {
        @InvocableVariable(label='Identificador' required=true)
        public String identificadorAcordo;
        @InvocableVariable(label='Vencimento Primeira Parcela' required=true)
        public String vencimentoPrimeiraParcela;
        @InvocableVariable(label='Quantidade Parcelas' required=true)
        public Integer quantidadeParcelas;
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='CPF' required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseSimularAcordo {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Número Max Parcelas')
        public Integer numeroMaximoParcelamento;
        
        @InvocableVariable(label='Numeros Opcões Disponiveis')
        public Integer numeroOpcoesDisponiveis;
        @InvocableVariable(label='Numero Parcela Plano Acordo')
        public String numeroParcelaPlanoAcordo;
        @InvocableVariable(label='Valor Plano Acordo')
        public String valorPlanoAcordo;
        @InvocableVariable(label='Desconto Plano Acordo')
        public String descontoPlanoAcordo;
        @InvocableVariable(label='Identificador Plano Acordo')
        public String identificadorPlanoAcordo;
        @InvocableVariable(label='Percentual Desconto Plano Acordo')
        public String percentualDescontoPlanoAcordo;
        @InvocableVariable(label='Valor Final Plano Acordo')
        public String valorFinalPlanoAcordo;
        
        @InvocableVariable(label='Numeros Parcelas Plano Acordo')
        public String idsPlanosAcordo;
        @InvocableVariable(label='Valores Planos Acordo')
        public String valoresPlanosAcordo;
        @InvocableVariable(label='Identificadores Planos Acordo')
        public String identificadoresPlanosAcordo;
        @InvocableVariable(label='Identificadores Planos Acordo 2')
        public String identificadoresPlanosAcordo2;
        @InvocableVariable(label='Descontos Planos Acordo')
        public String descontosPlanosAcordo;
        
        @InvocableVariable
        public List<String> listOpcoesAcordo;

    }

}