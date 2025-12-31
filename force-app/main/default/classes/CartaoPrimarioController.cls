public class CartaoPrimarioController {

    @AuraEnabled
    public static ContaFinanceiraBO.ContaFinanceira getContaFinanceira(String recordId){
        return ContaFinanceiraBO.getContaFinanceira(recordId);
    }

    @AuraEnabled
    public static AssetBO.AssetTO getCartaoPrimario(String contaFinanceiraId, String numeroConta, 
        String cpf,  String idEmpresa,  String area,  String canal,  String sistema){
            
        List<AssetBO.AssetTO> assetsTitular = AssetBO.getAssets(contaFinanceiraId, 'C', 'TITULAR');

        AssetBO.AssetTO toReturn = null;
        if(!assetsTitular.isEmpty()){
            String listaCartaoSerno = '';
            for(AssetBO.AssetTO asset : assetsTitular){
                listaCartaoSerno += asset.NumeroSernoId;
                listaCartaoSerno += ',';
            }

            listaCartaoSerno = listaCartaoSerno.substring(0, listaCartaoSerno.length()  - 1);

            CartaoPrimario.OutputListaCartoes output = CartaoPrimario.ObterDataEmissaoCartoes(numeroConta, 
                listaCartaoSerno, cpf, idEmpresa, area, canal, sistema);

            if(output != null && 'OK'.equals(output.statusAPI)){
                CartaoPrimario.Cartao cartaoPrimario = output.cartoes[0];

                for(AssetBO.AssetTO assetTO : assetsTitular){
                    if(assetTO.NumeroSernoId.equals(cartaoPrimario.idSerno)){
                        if(cartaoPrimario.dataCriacao != null){
                            assetTO.DataEmissao = cartaoPrimario.dataCriacao.format('dd/MM/yyyy');
                        }
                        assetTO.Status = cartaoPrimario.status;
                        assetTO.IsCartaoPrimario = cartaoPrimario.ehPrimario;
                        toReturn = assetTO;
                        break;
                    }
                }
            }
        }

        return toReturn;
    }

    @AuraEnabled
    public static Boolean definirCartaoPrimario(String contaFinanceiraId, String numeroConta, String numeroCartaoSerno, String cpf, String idEmpresa, String area, String canal, String sistema){
        Boolean retornoAPI = CartaoPrimario.DefinirCartaoPrimario(numeroConta, numeroCartaoSerno, cpf, idEmpresa, area, canal, sistema);
        if(retornoAPI){
            retornoAPI = AssetBO.updateAssetPrimario(contaFinanceiraId, numeroCartaoSerno);
        }
        return retornoAPI;
    }

    @AuraEnabled
    public static Case createCase(String canal, String origem, String contaFinanceiraId, String accountId, String unidadeNegocio){
        RecordType rt = BloqueioCartaoDAO.getRecordType('Case', 'BCSF_RT_CAS_Atendimento');
        return CasoDAO.getInstance().createCase(UserInfo.getUserId(), rt.Id, 'Closed', 'Cartão', 
        'Cartão Primário', 'Execução', 'Medium', canal, origem, contaFinanceiraId, accountId, unidadeNegocio);
    }
}