public class InterfaceAcordoDivida {
    @InvocableMethod(label='Consultar Situacao Acordo')
    public static List<ResponseConsultarSituacao> ConsultarSituacaoAcordo(List<RequestConsultarSituacao> parametersRequest){
        List<ResponseConsultarSituacao> toReturn = new List<ResponseConsultarSituacao>();
        ResponseConsultarSituacao responseConsultarSituacao = new ResponseConsultarSituacao();
    
        for(RequestConsultarSituacao request: parametersRequest){
            AcordoDivida.OutputConsultarSituacaoAcordo situacaoAcordo = AcordoDivida.ConsultarSituacaoAcordo(request.cpf, request.idEmpresa, request.canal);
            if(situacaoAcordo == null){
                responseConsultarSituacao.statusRetorno = 'ERRO';
            } else if(situacaoAcordo.situacao.codigo == '303' || situacaoAcordo.situacao.codigo == '302'){
                // 302 - cliente não encontrado
                // 303 - cliente não possui dívida/acordo
                responseConsultarSituacao.statusRetorno = 'OK';
                responseConsultarSituacao.situacaoCliente = situacaoAcordo.situacao.codigo;
            } else if(situacaoAcordo.situacao.codigo == '2' || situacaoAcordo.situacao.codigo == '3'){
                responseConsultarSituacao.statusRetorno = 'OK';
                responseConsultarSituacao.situacaoCliente = situacaoAcordo.situacao.codigo;
                Boolean possuiEmail = situacaoAcordo.infosCliente.possuiEmail;
                if(possuiEmail){
                    responseConsultarSituacao.possuiEmail = 'TRUE';
                } else {
                    responseConsultarSituacao.possuiEmail = 'FALSE';
                }
                
                if(situacaoAcordo.situacao.codigo == '2'){
                    responseConsultarSituacao.valorDivida = 'R$' + StringUtils.getCurrencyFormat(situacaoAcordo.divida.valor);
                    responseConsultarSituacao.identificadorAcordo = situacaoAcordo.divida.identificador;
                } else if(situacaoAcordo.situacao.codigo == '3'){
                    responseConsultarSituacao.identificadorAcordo = situacaoAcordo.contratos[0].acordos[0].identificadorAcordo;
                    Integer numeroTotalParcelas = situacaoAcordo.contratos[0].acordos[0].numeroParcela;
                    Integer numeroParcelasPagas = 0;
                    Decimal valorParcela = 0;
                    List<AcordoDivida.Parcela> parcelas = situacaoAcordo.contratos[0].acordos[0].parcelas;
                    
                    Boolean encontrouParcelaAtual = false;
                    responseConsultarSituacao.dataVencimentoProxParcela = '';
                    responseConsultarSituacao.pix = '';
                    responseConsultarSituacao.linhaDigitavel = '';
                    responseConsultarSituacao.statusParcela = 'SEM PENDENTE';
                    for(AcordoDivida.Parcela parcela : parcelas){
                    
                        if(encontrouParcelaAtual){
                            responseConsultarSituacao.dataVencimentoProxParcela = Util.formatDDMM(parcela.dataVencimento.dateGMT().day(), 
                            parcela.dataVencimento.dateGMT().month(), '/');
                            break;
                        } else {
                            if (parcela.status == 'Pendente' || parcela.status == 'A Pagar'){
                                responseConsultarSituacao.valorParcela = 'R$' + StringUtils.getCurrencyFormat(parcela.valorParcela);
                                responseConsultarSituacao.diaVencimentoAtual = Util.formatDDMM(parcela.dataVencimento.dateGMT().day(), 
                                parcela.dataVencimento.dateGMT().month(), '/');
                                
                                if(String.isNotBlank(parcela.linhaDigitavel)){
                                    responseConsultarSituacao.linhaDigitavel = parcela.linhaDigitavel;
                                }
                                
                                if(String.isNotBlank(parcela.copiaCola)){
                                    responseConsultarSituacao.pix = parcela.copiaCola;
                                }
                                                                
                                if(parcela.dataVencimento.dateGMT() >= Date.today()){
                                    responseConsultarSituacao.statusParcela = 'EM DIA';
                                } else {
                                    responseConsultarSituacao.statusParcela = 'VENCIDO';
                                }
                                
                                encontrouParcelaAtual = true;
                            } else {
                                numeroParcelasPagas++;
                            }
                        }   
                    }
                    
                    Integer numeroParcelaRestantes = numeroTotalParcelas - numeroParcelasPagas;
                    responseConsultarSituacao.numeroParcelaRestantes = '' + numeroParcelaRestantes; 
                }
            } else {
                responseConsultarSituacao.statusRetorno = 'ERRO';
            }
            
            toReturn.add(responseConsultarSituacao);
        }
        
        return toReturn;
    }
        
    public class RequestConsultarSituacao {
        @InvocableVariable(label='Id Empresa' required=true)
        public String idEmpresa;
        @InvocableVariable(label='CPF Cliente' required=true)
        public String cpf;
        @InvocableVariable(required=true)
        public String canal;
    }
    
    public class ResponseConsultarSituacao {
        @InvocableVariable(label='Status Chamada')
        public String statusRetorno;
        @InvocableVariable(label='Numero Parcelas Restantes')
        public String numeroParcelaRestantes;
        @InvocableVariable(label='Valor da parcela')
        public String valorParcela;
        @InvocableVariable(label='Dia do vencimento')
        public String diaVencimentoAtual;
        @InvocableVariable(label='linha Digitavel')
        public String linhaDigitavel;
        @InvocableVariable(label='Pix')
        public String pix;
        @InvocableVariable(label='Status Parcela')
        public String statusParcela;
        @InvocableVariable(label='Vencimento Proxima Parcela')
        public String dataVencimentoProxParcela;
        @InvocableVariable(label='Situacao Cliente')
        public String situacaoCliente;
        @InvocableVariable(label='Identificador Acordo')
        public String identificadorAcordo;
        @InvocableVariable(label='ValorDividaAcordo')
        public String valorDivida;
        @InvocableVariable(label='Cliente possui e-mail')
        public String possuiEmail;
    }
}