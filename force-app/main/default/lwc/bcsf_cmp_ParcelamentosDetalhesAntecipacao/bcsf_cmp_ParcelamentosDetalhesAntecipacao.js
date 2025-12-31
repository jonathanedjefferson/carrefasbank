import { api, LightningElement } from 'lwc';

export default class Bcsf_cmp_ParcelamentosDetalhesAntecipacao extends LightningElement {

    @api listaSimulacoesRealizadas;
    @api listaSimulacoesComFalha;
    @api labelErro;
    @api labelSucesso;
}