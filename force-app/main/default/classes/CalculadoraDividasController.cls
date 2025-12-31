public class CalculadoraDividasController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static CalculadoraDividas.OutputObterParametros ObterParametrosBusca(
        String canal, String idEmpresa, String cpf, String numeroConta) {

        CalculadoraDividas.OutputObterParametros toReturn = 
            CalculadoraDividas.ObterParametrosBusca(canal, idEmpresa, cpf, numeroConta);
        return toReturn;
    }

    @AuraEnabled
    public static CalculadoraDividas.OutputCalculadoraDividas CalcularJurosEncargos(
        String canal, String idEmpresa, String cpf, String numeroConta, String dataPagamento, String valorPagamento) {

        CalculadoraDividas.OutputCalculadoraDividas toReturn = 
            CalculadoraDividas.CalcularJurosEncargos(canal, idEmpresa, cpf, numeroConta, dataPagamento, valorPagamento);
        return toReturn;
    }

    @AuraEnabled
    public static CalculadoraDividas.OutputCalculadoraDividas CalcularSaldoDevedor(
        String canal, String idEmpresa, String cpf, String numeroConta, String dataPagamento) {

        CalculadoraDividas.OutputCalculadoraDividas toReturn = 
            CalculadoraDividas.CalcularSaldoDevedor(canal, idEmpresa, cpf, numeroConta, dataPagamento);
        return toReturn;
    }
    
    @AuraEnabled
    public static Case createCase(String evento, String canal, String origem, String contaFinanceiraId, 
        String accountId, String unidadeNegocio){
            RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
            return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Calculadora de juros', evento, 'Execução', 
            'Medium', canal, origem, contaFinanceiraId, accountId, unidadeNegocio);
    }
    

}