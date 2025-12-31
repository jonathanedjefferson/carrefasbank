import { LightningElement, track, api } from 'lwc';

export default class TesteCallLWC extends LightningElement {

    @api recordId;
    @track modalBoletoAvulso = false;

    boletoAvulsoHandler(){
        this.modalBoletoAvulso = true;
    }

    fecharModalBoletoAvulso() {
        this.modalBoletoAvulso = false;
    }

}