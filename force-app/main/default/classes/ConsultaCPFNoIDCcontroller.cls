public without sharing class ConsultaCPFNoIDCcontroller {
    @AuraEnabled
    public static Boolean validarCpf(String cpf){
        return CpfValidation.ValidarCpf(cpf).cpfValido;
    }

    @AuraEnabled
    public static Account getAccount(String cpf){
        return ConsultaCPFNoIDDAO.getAccountByCPF(cpf);
    }
    
    @AuraEnabled
    public static Account identificaCockpitAccount(String cpf, String canal){
        return ConsultaCPFNoIDCBO.createAccount(cpf, canal);
    }
}