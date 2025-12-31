public without sharing class ConsultaCPFNoIDCBO {
    public static Account createAccount(String cpf, String canal){
        IdentificaCockpit.ResponseAPIConta responseAccount = IdentificaCockpit.identificaConta(cpf, null, canal);
        
        if (responseAccount.data.cliente.contaCartao != null && responseAccount.data.cliente.dadosSociais.size() > 0) {
            RecordType rt = ConsultaCPFNoIDDAO.getRecordType('BCSF Cliente Pessoal Carrefour');
            Account acc = new Account();
            if((String.isBlank(responseAccount.data.cliente.dadosSociais[0].nomeMeio) || String.isBlank(responseAccount.data.cliente.dadosSociais[0].nomeUltimo)) && !String.isBlank(responseAccount.data.cliente.dadosSociais[0].nomeCompleto)){
                acc.FirstName = !String.isBlank(responseAccount.data.cliente.dadosSociais[0].nomePrimeiro) ? responseAccount.data.cliente.dadosSociais[0].nomePrimeiro.split(' ')[0] : responseAccount.data.cliente.dadosSociais[0].nomeCompleto.split(' ')[0];
                acc.LastName = Util.obterSobrenome(responseAccount.data.cliente.dadosSociais[0].nomeCompleto);
            }else{
                acc.FirstName = responseAccount.data.cliente.dadosSociais[0].nomePrimeiro;
                acc.LastName = responseAccount.data.cliente.dadosSociais[0].nomeMeio + ' ' + responseAccount.data.cliente.dadosSociais[0].nomeUltimo;
            }
            acc.NomeMae__c = responseAccount.data.cliente.dadosSociais[0].nomeMae;
            acc.Sexo__c = responseAccount.data.cliente.dadosSociais[0].genero;
            acc.DataNascimento__c = responseAccount.data.cliente.dadosSociais[0].dataDeNascimento.date();
            acc.CPF__c = cpf;
            acc.RecordTypeId = rt != null ? rt.Id : null;
            insert acc;

            List<ContaFinanceira__c> listContaFinanceira = new List<ContaFinanceira__c>();
            for (IdentificaCockpit.ContaResponse item: responseAccount.data.cliente.contaCartao.contratos) {
                String unidadeNegocio = '';
                if (item.unidadeNegocio == 'CSF' || item.unidadeNegocio == 'CRF' || item.unidadeNegocio == '1') {
                    unidadeNegocio = '1';
                }else if(item.unidadeNegocio == 'ATC' || item.unidadeNegocio == '2') {
                    unidadeNegocio = '2';
                }else if(item.unidadeNegocio == 'SAMS' || item.unidadeNegocio == '6'){
                    unidadeNegocio = '6';
                }else{
                    unidadeNegocio = null;
                }
                
                ContaFinanceira__c cf = new ContaFinanceira__c();
                cf.NomeCliente__c = acc.Id;
                cf.NumeroConta__c = item.numeroConta;
                cf.StatusConta__c = item.statusConta;
                cf.UnidadeNegocio__c = unidadeNegocio;
                cf.IdConta__c = item.numeroContaSerno;
                listContaFinanceira.add(cf);
            }

            insert listContaFinanceira;
            return acc;
        }
        return null;
    }
}