import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/BCSF_CarinaPhraseCalendarController.uploadFile';
import deleteFile from '@salesforce/apex/BCSF_CarinaPhraseCalendarController.deleteFile';

export default class bcsf_CarinaPhraseCalendarLWC extends LightningElement {
    @api myRecordId;
    spinner = false;
    showButton = true;
    textFiles = false;
    documentId = null;
    fileName;

    
    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event){
        try {
            this.documentId = event.detail.files[0].documentId;
            this.showButton = false;
            this.textFiles = true;
            this.fileName = event.detail.files[0].name;
        } catch (error) {
            this.ShowToast(
                'Erro na importação do arquivo',
                error.body.message,
                'error'
            );
            this.DeleteFile(this.documentId);
        }
    }

    FinalizarImportacao() {
        this.ShowSpinner();
         
        uploadFile({ 
            idContentDocument: this.documentId
        }).then(result => {
            this.ShowToast(
                'Sucesso na importação',
                'Todos os dados foram importados com sucesso! ',
                'success'
            );

            this.DeleteFile(this.documentId);
            this.CloseSpinner();

            this.showButton = true;
            this.textFiles = false;
            this.documentId = null;
        }).catch(error => {
            this.DeleteFile(this.documentId);
            if(error.body.message == 'BLOB is not a valid UTF-8 string'){
                this.ShowToast(
                    'Erro na importação',
                    'Houve um erro durante a conversão do arquivo Excel para CSV. Por favor, regenere o arquivo CSV novamente.',
                    'error'
                );
            }else{
                this.ShowToast(
                    'O processo de importação encontrou um erro.',
                    error.body.message,
                    'error'
                );
            }
            this.CloseSpinner();
            this.showButton = true;
            this.textFiles = false;
            this.documentId = null;
        });

    }

    DeleteFile(ContentDocumentId){
        deleteFile({
            idContentDocument: ContentDocumentId
        }).then(result => {
        }).catch(error => {
            console.log('DeleteFile ERROR: ' + error.body.message);
        });
    }

    ShowToast(titulo, mensagem, variant){
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    ShowSpinner(){
        this.spinner = true;
    }
    CloseSpinner(){
        this.spinner = false;
    }
}