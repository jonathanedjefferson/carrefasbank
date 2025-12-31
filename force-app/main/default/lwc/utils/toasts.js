import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export function showToast(titulo, mensagem, variante, mode = 'dismissable') {
    const evt = new ShowToastEvent({
        title: titulo,
        message: mensagem,
        variant: variante,
        mode: mode
    });
    this.dispatchEvent(evt);
}