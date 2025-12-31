import { LightningElement, track } from 'lwc';
import createBulkCases from '@salesforce/apex/BulkCaseManagerController.createBulkCases';
import updateBulkCases from '@salesforce/apex/BulkCaseManagerController.updateBulkCases';
import getImportFields from '@salesforce/apex/BulkCaseManagerController.getImportFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const IMPORT_FILE_TITLE = 'modelo_importacao_massiva.csv';
const UPDATE_FILE_TITLE = 'modelo_fechamento_massivo.csv';

export default class BulkCaseManager extends LightningElement {
    importCaseData = {
        Data: null
    };
    updateCaseData;
    selectedTab = 'open';
    file;
    importFields;

    connectedCallback() {
        getImportFields().then(response => {
            this.importFields = response;
        })
    }

    handleSelectTab(event) {
        this.selectedTab = event.target.value;
    }

    handleDownloadModel(event) {
        event.preventDefault();
        this.downloadModel();
    }

    downloadModel() {
        try {
            const bom = '\uFEFF';
            const csv = this.selectedTab === 'open' ?  this.importHeaders: this.updateHeaders;
            const csvData = 'data:text/csv;charset=ISO-8859-1,' + encodeURIComponent(bom  + csv);
            const link = document.createElement('a');
            link.href = csvData;
            link.download = this.selectedTab === 'open' ? IMPORT_FILE_TITLE : UPDATE_FILE_TITLE;
            link.click();
            document.body.appendChild(link);
        } catch (error) {
            console.error(error);
        }
    }

    openFilePicker() {
        this.template.querySelector('input[type="file"]').click();
    }

    handleDrop(event) {
        event.preventDefault();
        const files = event.dataTransfer.files;
        if (files.length > 0 && files[0].type === 'text/csv') {
            this.file = files[0];
            this.isProsseguirDisabled = false;
        } else {
            this.showToast('Erro', 'Somente arquivos .csv são permitidos.', 'error');
        }
    }

    handleDragOver(event) {
        event.preventDefault();
    }

   handleFileChange(event) {
       const file = event.target.files[0];
       if (!file) return;

       this.file = file;
       this.readFile();
    }

    readFile() {
        const reader = new FileReader();
        reader.onload = (e) => {
            const text = e.target.result;
            const lines = text.split("\n").map(l => l.trim()).filter(l => l);
            
            // primeira linha = cabeçalhos
            const headers = lines[0].split(",");
            const jsonData = lines.slice(1).map(line => {
                const values = line.split(",");
                return headers.reduce((obj, header, i) => {
                obj[header] = values[i] || "";
                return obj;
                }, {});
            });
            
            if (this.selectedTab === 'open') {
                this.importCaseData.Data = jsonData;
                this.startImport();
            }
            else {
                this.updateCaseData = jsonData;
                this.startUpdate();
            }
        };
        
        reader.readAsText(this.file, 'ISO-8859-1');
    }

    startImport() {
        console.log('Payload -> ', this.importCaseData);
        createBulkCases({lInputData : this.importCaseData}).then(() => {
            this.showToast('Importação em andamento', 'Assim que terminar, você receberá uma notificação. Fique a vontade para sair desta tela.', 'success');
        })
        .catch(error => {
            console.log('Erro ao passar para o apex criação: ', error);
            this.showToast('', 'Falha na importação, tente novamente.', 'error');
        })
    }

    startUpdate() {
        updateBulkCases({lLstInputs : this.updateCaseData}).then(() => {
            this.showToast('Finalização em andamento', 'Assim que terminar, você receberá uma notificação. Fique a vontade para sair desta tela.', 'success');
        }).catch(error => {
            console.log('Erro ao passar para o apex atualização: ', error);
            this.showToast('', 'Falha na Finalização, tente novamente.', 'error');
        })
    }

    showToast(title, message, variant, mode = 'sticky') {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    get importHeaders() {
        return this.importFields ? Object.keys(this.importFields).join(',') : '';
    }

    get updateHeaders() {
        return 'CaseNumber,ClosedReason' +
            '\n000123,Tratativa Encerrada';
    }
}