public class InclusaoAdicionalController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        ContaFinanceiraBO.ContaFinanceira contaFinanceira = ContaFinanceiraBO.getContaFinanceira(recordId);
        
        if(contaFinanceira != null){
            contaFinanceira.CEP = Util.formatCEP(contaFinanceira.CEP);

            String telefone = contaFinanceira.Telefone;
            if(String.isNotBlank(telefone) && !'--'.equals(telefone)){
                contaFinanceira.Telefone = Util.formatCelular(telefone);
            }
        }

        return contaFinanceira;
    }

    @AuraEnabled
    public static IntegrationAdicional.OutputSolicitarCartaoAdicional solicitarCartaoAdicional(String cpf, String numeroConta, 
    String canal, String area, String sistema, String idEmpresa,
    String cpfAdicional, String nomeAdicional, String sexoAdicional, String dataNascimentoAdicional){

        IntegrationAdicional.OutputSolicitarCartaoAdicional toReturn = IntegrationAdicional.SolicitarCartaoAdicional(cpf, 
            numeroConta, canal, area, sistema, idEmpresa, cpfAdicional, nomeAdicional, 
            sexoAdicional, dataNascimentoAdicional);

        if(toReturn != null  && 'ERROR_400'.equals(toReturn.statusAPI)) {
            toReturn.mensagem = 'Conta sem status de permissão para fazer inclusão de adicional';
        }

        return toReturn;
    }

    @AuraEnabled
    public static Case createCaseSolicitarAdicional(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');

        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Cartão', 
        'Inclusão de cartão adicional', 'Execução', 'Medium', canal, origem, contaFinanceiraId, accountId, unidadeNegocio);
    }
    
}