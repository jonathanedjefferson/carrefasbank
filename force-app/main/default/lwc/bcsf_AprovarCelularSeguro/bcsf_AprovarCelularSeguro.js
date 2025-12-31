import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';

import atualizarCaso from '@salesforce/apex/BCSF_CadastroCelularSeguroController.atualizarCaso';
import gravarCelularSeguro from '@salesforce/apex/BCSF_CadastroCelularSeguroController.gravarCelularSeguro';

const FIELDS = [
    "Case.Origin", 
    "Case.Evento__c",
    "Case.Assunto__c", 
    "Case.CaseNumber", 
    "Case.CanalEntrada__c", 
    "Case.UnidadeNegocio__c",
    "Case.CPFContato__c", 
    "Case.NomeCliente__c", 
    "Case.ContaFinanceira__r.NumeroConta__c", 
    "Case.Telefone__c",
    "Case.TelefoneParaCadastro__c",
    "Case.Status",
    "Case.Fraude__c",
    "Case.HouveAlteracaoCadastral__c",
    "Case.Resolucao__c",
    "Case.Aprovado__c"
];

export default class Bcsf_AprovarCelularSeguro extends LightningElement {

    @api recordId;
    @track spinner;
    @track pageOne = true;
    @track pageTwo = false;
    @track showInfo = true;
    @track showEditForm;
    @track telefone;
    @track showModal;
    @track CaseNumber;
    @track houveAlteracao;
    @track houveFraude;
    @track resolucao;
    @track accountId;
    @track cpf;
    @track numeroConta;
    @track unidadeNegocio;
    @track dataAtualFormatada;
    @track disabledBtnFinalizar = true;
    @track classModal = "slds-modal slds-fade-in-open slds-modal_medium";
    @track closedCaseData

    options = [
        { label: 'Sim', value: 'Sim' },
        { label: 'Não', value: 'Não' },
    ];

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS}) 
    currentCaseInfo({error, data}) {
        if (data) {
            this.CaseNumber = data.fields.CaseNumber.value;
            this.telefone = data.fields.Telefone__c.value;
            this.assunto = data.fields.Assunto__c.value;
            this.evento = data.fields.Evento__c.value;
            this.origem = data.fields.Origin.value;
            this.canal = data.fields.CanalEntrada__c.value;
            this.cpf = data.fields.CPFContato__c.value;
            this.unidadeNegocio = data.fields.UnidadeNegocio__c.value;
            this.accountId = data.fields.NomeCliente__c.value;
            this.numeroConta = data.fields.ContaFinanceira__r.value.fields.NumeroConta__c.value;
            this.closedCaseData = {
                status: data.fields.Status.value,
                houveFraude: data.fields.Fraude__c.value,
                houveAlteracao: data.fields.HouveAlteracaoCadastral__c.value,
                resolucao: data.fields.Resolucao__c.value,
                statusAprovacao: this.getStatusAprovacao(data.fields.Aprovado__c.value), 
                celularSeguro: this.getNumeroCelularSeguro(data.fields.Telefone__c.value, data.fields.Aprovado__c.value),
                celularOrignal: this.formatarTelefone(data.fields.TelefoneParaCadastro__c.value)
            }
        } else if (error) {
            console.log('data WIRE: ' + JSON.stringify(error));
            this.error = error ;
        }
    }

    GravarCelularSeguro(){
        this.spinnerOpen();
        gravarCelularSeguro({
            cpf: this.cpf,
            numeroCelular: this.telefone.replace(/\D/g, ''), 
            numeroConta: this.numeroConta,
            idEmpresa: this.unidadeNegocio, 
            canal: 'cockpit'
        }).then(result=>{
            if(result){
                this.AtualizarCaso();
            }else{
                this.spinnerClose();
                throw new Error("celular não cadastrado");
            }
        }).catch(error=>{
            console.log('Erro ao cadastrar celular: '+ error.message);
            this.showToast('', 'Não foi possível carregar as informações', 'error', true);
        });
    }

    AtualizarCaso(){
        this.spinnerOpen();
        atualizarCaso({
            caseId: this.recordId,
            fraude: this.houveFraude,
            alteracao: this.houveAlteracao,
            aprovado: this.aprovado ? 'Sim' : 'Não',
            resolucao: this.resolucao
        }).then(result=>{
            this.pageOne = false;
            this.pageTwo = true;
            this.dataAtualFormatada = this.formatDate(new Date());
            this.classModal = "slds-modal slds-fade-in-open";
            this.spinnerClose();
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('', 'Não foi possível carregar as informações', 'error', true);
        });
    }

    handleEdit(){
        this.showEditForm = !this.showEditForm;
        this.showInfo = !this.showInfo;
    }

    handleSave(){
        this.showSpinner();
        this.showEditForm = !this.showEditForm;
        this.showInfo = !this.showInfo;
        this.closeSpinner();
    }

    handleBtnFinalizar(){
        if (this.aprovado) {
            this.GravarCelularSeguro();
        }else{
            this.AtualizarCaso();
        }
    }

    handleBtnValidar(event){
        const textReprovado = 'Ao Finalizar, o caso será fechado e as alterações solicitadas não serão feitas no perfil do cliente.';
        const textAprovado = 'Ao Finalizar, o caso será fechado e as alterações solicitadas serão feitas no perfil do cliente.';
        this.showModal = true;
        this.status = event.target.name.toUpperCase();
        this.aprovado = event.target.name === 'Aprovado';
        this.textAlert = event.target.name === 'Aprovado'? textAprovado : textReprovado;
    }

    handleChangeAlteracao(event){
        this.houveAlteracao = event.target.value;
        this.validarBtnFinalizar();
    }

    handleChangeFraude(event){
        this.houveFraude = event.target.value;
        this.validarBtnFinalizar();
    }

    handleChangeResolucao(event){
        this.resolucao = event.target.value;
        this.validarBtnFinalizar();
    }

    handleCloseModal(){
        let atualizarCase = this.pageTwo;
        this.houveAlteracao = '';
        this.houveFraude = '';
        this.resolucao = '';
        this.showModal = false;
        this.pageOne = true;
        this.pageTwo = false;
        this.classModal = "slds-modal slds-fade-in-open slds-modal_medium";
        this.disabledBtnFinalizar = true;
        if(atualizarCase){
            this.dispatchEvent(new RefreshEvent())
        }
    }

    validarBtnFinalizar(){
        this.disabledBtnFinalizar = true;
        if(this.houveAlteracao && this.houveFraude && this.resolucao){
            this.disabledBtnFinalizar = false;
        }
    }

    showToast(titulo, mensagem, variante, close) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);

        if(close){
            this.spinnerClose();
        }
    }

    spinnerClose(){
        this.spinner = false;
    }

    spinnerOpen(){
        this.spinner = true;
    }

    formatDate(dataString) {
        if (!dataString) return '';
        const data = new Date(dataString);
        const opcoes = {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        };
        const dataFormatada = data.toLocaleString('pt-BR', opcoes).replace(',', '');
        return dataFormatada.replace(' ', ' - ');
    }

    formatarTelefone(telefone) {
        if (!telefone) return '';

        const numeros = telefone.replace(/\D/g, '');

        if (/^\+55 \d{2} \d{5}-\d{4}$/.test(telefone) || /^\(\d{2}\) \d{4,5}-\d{4}$/.test(telefone)) {
            return telefone;
        }

        if (numeros.length === 13) {
            const ddd = numeros.substring(2, 4);
            const primeiro = numeros.length === 13 ? numeros.substring(4, 9) : numeros.substring(4, 8);
            const segundo = numeros.substring(9);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 11) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 7);
            const segundo = numeros.substring(7);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        if (numeros.length === 10) {
            const ddd = numeros.substring(0, 2);
            const primeiro = numeros.substring(2, 6);
            const segundo = numeros.substring(6);
            return `(${ddd}) ${primeiro}-${segundo}`;
        }

        return telefone;
    }

    getStatusAprovacao(statusAprovacao) {
        if (!statusAprovacao) {
            return;
        }

        return statusAprovacao == 'Sim' ? 'Aprovado' : 'Reprovado'
    }

    getNumeroCelularSeguro(numeroCelularSeguro, statusAprovacao) {
        if (!statusAprovacao) {
            return this.formatarTelefone(numeroCelularSeguro)
        }

        return statusAprovacao == 'Sim' ? this.formatarTelefone(numeroCelularSeguro) : '-'
    }

    get isCaseClosed() {
        return this.closedCaseData &&  this.closedCaseData.status && this.closedCaseData.status == 'Closed';
    }
}