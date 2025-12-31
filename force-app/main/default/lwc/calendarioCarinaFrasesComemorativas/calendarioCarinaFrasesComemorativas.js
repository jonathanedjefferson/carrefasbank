import { LightningElement, api, wire } from 'lwc';
import uploadFile from '@salesforce/apex/CalendarioCarinaFrasesController.uploadFile';

export default class CalendarioCarinaFrasesComemorativas extends LightningElement {
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