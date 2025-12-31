public class ResumoFaturaController {

    @AuraEnabled
    public static ResumoFatura.OutputFatura obterResumoFaturaConta(
        String numeroConta, String cpfCliente, String unidadeNegocio, String canal) {

        ResumoFatura.OutputFatura toReturn = 
            ResumoFatura.obterResumoFaturaConta(numeroConta, cpfCliente, unidadeNegocio, canal);

        if(toReturn != null && 'OK'.equals(toReturn.StatusAPI) && toReturn.faturas != null){
            for(ResumoFatura.DetalheFatura fatura : toReturn.faturas){
                fatura.tipoFatura = atualizaTipoFatura(fatura.idTipoFatura);
            }
        }

        return toReturn;
    }

    @AuraEnabled
    public static ResumoFatura.OutputFatura obterResumoFaturaMes(
        String numeroConta, String mesAno, String cpfCliente, String unidadeNegocio, String canal) {

        ResumoFatura.OutputFatura toReturn = 
            ResumoFatura.obterResumoFaturaMes(numeroConta, mesAno, cpfCliente, unidadeNegocio, canal);
            System.debug('### mesAno recebido: ' + mesAno);

        if(toReturn != null && 'OK'.equals(toReturn.StatusAPI)){
            toReturn.fatura.tipoFatura = atualizaTipoFatura(toReturn.fatura.idTipoFatura);
        }

        return toReturn;
    }

    private static String atualizaTipoFatura(Integer idTipoFatura){
        String tipoFatura = '--';
        switch on idTipoFatura {
            when 0 {
                tipoFatura = 'Aberta';
            }	
            when 1 {
                tipoFatura = 'Fechada';
            }
            when 2 {
                tipoFatura = 'Futura';
            }
            when 3 {
                tipoFatura = 'Paga';
            }
            when 4 {
                tipoFatura = 'Paga parcialmente';
            }
            when 5 {
                tipoFatura = 'Atrasada';
            }
        }

        return tipoFatura;
    }
}