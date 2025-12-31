public class BlindagemTO {

    public class InputFiltroListarCLientes{
        @AuraEnabled
        public Integer tipoFiltro { get; set; }
        @AuraEnabled
        public String valor { get; set; }
    }

    public class InputCriarClienteBlindado{
        @AuraEnabled
        public String cpf { get; set; }
        @AuraEnabled
        public String nome { get; set; }
        @AuraEnabled
        public String usuario { get; set; }
        @AuraEnabled
        public String descricao { get; set; }
        @AuraEnabled
        public Boolean fullBlindagem { get; set; }
        @AuraEnabled
        public Integer siglaUnidadeNegocio { get; set; }
    }

    public class InputRemoverClienteBlindado{
        @AuraEnabled
        public String cpf { get; set; }
        @AuraEnabled
        public String usuario { get; set; }
        @AuraEnabled
        public Integer siglaUnidadeNegocio { get; set; }
    }


    public class RetornoListarClientesBlindados{
        @AuraEnabled
        public String statusAPI;
        @AuraEnabled
        public List<RetornoClienteBlindado> listaDeUsuariosPorCpf;
        @AuraEnabled
        public Integer totalItens;
        @AuraEnabled
        public Integer tamanhoPagina;
        @AuraEnabled
        public Integer pagina;
    }

    public class RetornoClienteBlindado{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public String cpf;
        @AuraEnabled 
        public String nome;
        @AuraEnabled 
        public String descricao;
        @AuraEnabled 
        public String blindagem;
        @AuraEnabled 
        public String usuario;
        @AuraEnabled 
        public String dataAlteracao;
        @AuraEnabled 
        public String blindagemFull;
    }

    public class RetornoCriarClienteBlindado{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean criadoComSucesso;
    }

    public class RetornoOperacaoEmMassa{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public List<String> cpfsComSucesso;
        @AuraEnabled 
        public List<String> cpfsComErro;
    }

    public class RetornoRemoverBlindagem{
        @AuraEnabled 
        public String statusAPI;
        @AuraEnabled 
        public Boolean sucesso;
    }
    
}