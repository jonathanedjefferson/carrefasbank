/* eslint-disable @lwc/lwc/no-leading-uppercase-api-name */
import { LightningElement, api, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation'

export default class Bcsf_PreviewFile extends NavigationMixin(LightningElement) {

    @api pdfBase64;
    @track pdfUrl;

    connectedCallback() {
        this.renderizarPdf();
        this.filesList.push({
            "label":"teste",
            "value": this.item,
            "url":`data:application/pdf;base64,${this.item}`
        })
    }

    @api OpenPdf() {
        if (this.pdfBase64) {
            // Converte a string base64 para um array de bytes
            const byteCharacters = atob(this.pdfBase64);
            const byteNumbers = Array.from(byteCharacters).map(char => char.charCodeAt(0));
            const byteArray = new Uint8Array(byteNumbers);

            // Cria um Blob a partir do array de bytes
            const blob = new Blob([byteArray], { type: 'application/pdf' });

            // Cria uma URL temporária a partir do Blob
            const pdfUrl = URL.createObjectURL(blob);

            // Cria um elemento <a> dinamicamente
            const link = document.createElement('a');
            link.href = pdfUrl;
            link.target = '_blank';
            
            // Simula um clique no link
            link.click();

            // Libera a URL Blob depois de um tempo para liberar memória
            setTimeout(() => URL.revokeObjectURL(pdfUrl), 5000);
        }
    }

    renderizarPdf() {
        // Converte a string base64 para um array de bytes
        const byteCharacters = atob(this.pdfBase64);
        const byteNumbers = Array.from(byteCharacters).map(char => char.charCodeAt(0));
        const byteArray = new Uint8Array(byteNumbers);

        // Cria um Blob a partir do array de bytes
        const blob = new Blob([byteArray], { type: 'application/pdf' });

        // Cria uma URL temporária a partir do Blob
        this.pdfUrl = URL.createObjectURL(blob);
    }
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}