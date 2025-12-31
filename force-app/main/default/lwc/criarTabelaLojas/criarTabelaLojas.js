import { LightningElement, api, wire } from 'lwc';
import uploadFile from '@salesforce/apex/CriarTabelaLojasController.uploadFile';

export default class CriarTabelaLojas extends LightningElement {
    @api
    myRecordId;
    
    get acceptedFormats() {
        return ['.csv'];
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadFile({idContentDocument: uploadedFiles[0].documentId}
        )
    }
}