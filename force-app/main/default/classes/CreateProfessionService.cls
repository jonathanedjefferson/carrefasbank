public class CreateProfessionService {

    private static final Integer ID_EMPRESA = 1;
    private static final String CANAL = 'Cockpit';
    private static final String CPF = '12345678910';

    public static void setPreviousOcupationToDelete() {
        //Consulta todas as ocupações existentes que não estão marcadas com Deletar = true
        List<ParametroConsultaProfissao__c> lLstPrevisouOcupations = CreateProfessionHelper.getExistingOcupation();

        for (ParametroConsultaProfissao__c ocupation : lLstPrevisouOcupations) {
            ocupation.Deletar__c = true;
        }

        update lLstPrevisouOcupations;
    }
    
    public static Boolean createOccupation() {
        BCSF_AquisicaoDeCartaoTO.listResponseWrapper response = BCSF_AquisicaoDeCartao.buscarModelosContratacao(ID_EMPRESA, CANAL, CPF);
        List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper> body = (List<BCSF_AquisicaoDeCartaoTO.buscarModelosContratacaoResponseWrapper>) response.body;

        if (response.statusCode != 200) {
            return false;
        }

        CreateProfessionService.setPreviousOcupationToDelete();
        CreateProfessionHelper.createNewOcupations(body);

        return true;
    }
}