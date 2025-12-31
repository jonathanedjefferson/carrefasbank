import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';

export default class Bcsf_Falecimento extends LightningElement {
    cmpFalecimento = true;
    closeModalComponent = true;
    
    @api recordId;
    @track nome = '--';
    @track cpf = '--';
    @track dataNascimento = '--';
    @track statusConta = '--';
    @track spinner = false;
    @track valueStatus;
    @track buttonPross = true;
    @track cancelar = false;
    @track bloquear = false;
    @track statusFalecimento = true;

    get options() {
        return [
            { label: 'Titular falecido com conta ativa', value: 'falecido_conta_ativa' },
            { label: 'Titular falecido com conta cancelada', value: 'falecido_conta_cancelada'},
            { label: 'Regular', value: 'regular' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    } 

    connectedCallback() {
        this.spinner = true;
        getContaFinanceira({ contaFinanceiraId: this.recordId })
            .then(result => {
            
                this.nome = result.Nome;
                this.cpf = result.CPF;
                this.statusConta = result.StatusConta;
                this.dataNascimento = result.DataNascimento;
                this.spinner = false;
            })
            .catch(error => {
                console.log('Erro getContaFinanceira2: ' + error.body.message);
                this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
            });
        ;
    }

    handleStatus(event) { 
        this.valueStatus = event.detail.value;
        this.buttonPross = false;
    }

    handleCopyCPF() {
        let cpf = this.cpf.toString()
        let cpfFormatado = cpf.replace(/[.-]/g, ''); 
        this.copyToClipboard(cpfFormatado);
    }

    handleCopyDataNascimento() {
        this.copyToClipboard(String(this.dataNascimento.toString()));
    }

    handleProsseguir() {
        if (this.valueStatus == "regular" || this.valueStatus == "falecido_conta_cancelada") {
            this.statusFalecimento = false;
            this.bloquear = true;  
        } else if(this.valueStatus == "falecido_conta_ativa") {
            this.cancelar = true;
            this.statusFalecimento = false;
        }
    }

    handleButtonVoltar(event) {
        this.closeQuickAction();
    }

    handleVoltarToFalecimento() {
        this.statusFalecimento = true;
        if (this.valueStatus == "regular" || this.valueStatus == "falecido_conta_cancelada") {
            this.bloquear = false;  
        } else if(this.valueStatus == "falecido_conta_ativa") {
            this.cancelar = false;
        }
    }

    handleConsultar() {
        let link = 'https://servicos.receita.fazenda.gov.br/Servicos/CPF/ConsultaSituacao/ConsultaPublica.asp';
        window.open(link, '_blank');
    }

    copyToClipboard(text) {
        const dummyInput = document.createElement('input');
        document.body.appendChild(dummyInput);
        dummyInput.value = text;
        dummyInput.select();
        document.execCommand('copy');
        document.body.removeChild(dummyInput);
    }

    showToast(titulo, mensagem, variante, closeModal) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'))
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
}