public without sharing class BCSF_SegundaViaFaturaBO {
    public static List<OutputUltimosVencimentosFechados> getListaFaturas(String numeroConta, String idEmpresa, String cpf, String canal){
            
        List<IntegracoesFaturas.OutputUltimosVencimentosFechados> listaRetornada = IntegracoesFaturas.UltimosVencimentosFechados(numeroConta, idEmpresa, cpf, canal);
        List<OutputUltimosVencimentosFechados> listRetorno =  new List<OutputUltimosVencimentosFechados>();

        for (IntegracoesFaturas.OutputUltimosVencimentosFechados item : listaRetornada) {
            OutputUltimosVencimentosFechados retorno = new OutputUltimosVencimentosFechados();
            retorno.idFatura = item.idFatura;
            retorno.data = item.data;
            retorno.dataFormatado = item.dataFormatado;
            retorno.StatusOK = item.StatusOK;
            listRetorno.add(retorno);
        }
        
        return listRetorno;
    }

    public static Case createCase(String contaFinanceiraId, String accountId, String unidadeNegocio, String origem, String canalEntrada, String motivo, String motivoDescricao){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        Group gr = new Group();

        if(unidadeNegocio == '1'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatCarrefour');
        }else if(unidadeNegocio == '2'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatAtacadao');
        }else if(unidadeNegocio == '6'){
            gr = BloqueioCartaoDAO.getQueue('Queue', 'BCSF_QU_AtendimentoCasosChatSamsClub');
        }


        Case cs = new Case();
        cs.OwnerId = gr.Id;
        cs.NomeCliente__c = accountId;
        cs.RecordTypeId = rt.Id;
        cs.Status = 'Closed';
        cs.Assunto__c = 'Fatura';
        cs.Evento__c = 'Segunda via de fatura';
        cs.Origin = origem;
        cs.ContaFinanceira__c = contaFinanceiraId;   
        cs.UnidadeNegocio__c = unidadeNegocio;  
        cs.Type = 'Execução';
        cs.CanalEntrada__c = canalEntrada;
        cs.MotivoFatura__c = motivo;
        cs.Description = motivoDescricao;
        cs.Priority = 'Medium';

        insert cs;

        return BCSF_ReimpressaoSenhaDAO.getInstance().getCase(cs.id);
    }

    public class OutputUltimosVencimentosFechados {
        @AuraEnabled
        public Integer idFatura;
        @AuraEnabled
        public String data;
        @AuraEnabled
        public String dataFormatado;
        @AuraEnabled
        public String StatusOK;
    }
}