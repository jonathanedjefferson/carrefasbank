public with sharing class LancamentoContestadoDAO {

    private static final LancamentoContestadoDAO instance = new LancamentoContestadoDAO();

    public static LancamentoContestadoDAO getInstance() {
        return instance;
      }
  
      public static List<Database.SaveResult> createLancamentosContestados(Case caso, 
        List<LancamentoContestadoBO.LancamentoContestado> transacoesContestadas){
          
        List<LancamentoContestado__c> listaLancamentos = new List<LancamentoContestado__c>();
  
          for(LancamentoContestadoBO.LancamentoContestado transacao : transacoesContestadas){

              listaLancamentos.add(new LancamentoContestado__c(
                  Caso__c = caso.Id,
                  ContaFinanceira__c = caso.ContaFinanceira__c,
                  NumeroCartao__c = transacao.numeroCartaoOfuscado,
                  IdCartao__c = transacao.idCartaoSerno,
                  NumeroConta__c = transacao.numeroConta,
                  IdTransacao__c = transacao.codigoTransacao,
                  Valor__c = transacao.valor == null ? 0 : math.abs(transacao.valor),
                  CartaoBloqueado__c = transacao.cartaoBloqueado,
                  CodigoEntrada__c = transacao.codigoEntrada,
                  CartaoRoubado__c = transacao.cartaoRoubado,
                  ClienteCartao__c = transacao.clienteCartao
              ));
          }
  
          return Database.Insert(listaLancamentos);
      }
}