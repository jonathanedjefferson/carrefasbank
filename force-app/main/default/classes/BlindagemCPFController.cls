public with sharing class BlindagemCPFController {

    @AuraEnabled
    public static BlindagemTO.RetornoListarClientesBlindados listarClientes(BlindagemTO.InputFiltroListarCLientes filtro, Integer tamanhoPagina, Integer pagina, String canal) {
        return BlindagemCPF.listarClientesBlindados(filtro, tamanhoPagina, pagina, canal);
    }

    @AuraEnabled
    public static BlindagemTO.RetornoClienteBlindado obterCliente(String cpfCliente, String canal) {
        return BlindagemCPF.obterClienteBlindado(cpfCliente, canal);
    }

    @AuraEnabled
    public static BlindagemTO.RetornoCriarClienteBlindado criarCliente(BlindagemTO.InputCriarClienteBlindado cliente, String canal) {
        return BlindagemCPF.criarClienteBlindado(cliente, canal);
    }

    @AuraEnabled
    public static BlindagemTO.RetornoOperacaoEmMassa criarClientesMassa(List<BlindagemTO.InputCriarClienteBlindado> clientes, String canal) {
        return BlindagemCPF.criarClientesBlindadosEmMassa(clientes, canal);
    }

    @AuraEnabled
    public static BlindagemTO.RetornoRemoverBlindagem removerCliente(BlindagemTO.InputRemoverClienteBlindado cliente, String canal) {
        return BlindagemCPF.removerClienteBlindado(cliente, canal);
    }

    @AuraEnabled
    public static BlindagemTO.RetornoOperacaoEmMassa removerClientesMassa(List<BlindagemTO.InputRemoverClienteBlindado> clientes, String canal) {
        return BlindagemCPF.removerClientesBlindadosEmMassa(clientes, canal);
    }

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira obterContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }
    
    @AuraEnabled
    public static Account obterContaCliente(Id recordId){
        return AccountDAO.getAccountById(recordId);
    }
}