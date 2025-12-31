import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import criarCasoContestar from '@salesforce/apex/bcsf_cmp_SegurosController.criarCasosContestar'

export default class Bcsf_SegurosContestar extends LightningElement {

    @api recordId;
    @api seguros;
    @api dadosCliente;
    @track spinner = false;
    @track dadosClienteFormatados;
    @track disabledBtnLimpar = true;
    @track disabledBtnContestar = true;
    @track modalContestar = false;
    @track usouBtnSeguro = false;
    @track pageOneContestar = true;
    @track disableBtnNextContestar = true;
    @track dataAtualFormatada;
    @track canalCasoContestar;
    @track origemCasoContestar;
    @track iconeNome = "utility:arrowdown";
    @track iconeData = "utility:arrowdown";
    @track iconeMotivo = "utility:arrowdown";
    @track segurosSelected = [];
    @track segurosFormatados = [];

    connectedCallback(){
        this.dataAtualFormatada = this.formatDate(new Date());
        this.segurosFormatados = this.seguros.map(seguro => ({
            ...seguro,
            dataCancelamentoLabel: seguro.dataCancelamento ? this.formatDate(seguro.dataCancelamento):'--',
            idAdesao: seguro.idAdesaoProseg || seguro.idAdesaoPdr,
            checked: false
        }))
    }

    CriarCasoContestar(){
        this.spinner = true;
        const segurosFormatados = this.loadSeguros();
        criarCasoContestar({
            contaFinanceiraId: this.recordId, 
            accountId: this.dadosCliente.accountId, 
            unidadeNegocio: this.dadosCliente.unidadeNegocio,  
            Origem: this.origemCasoContestar, 
            Canal: this.canalCasoContestar,
            seguros: segurosFormatados
        }).then(result=>{
            this.numProtocoloContestar = result.CaseNumber;
            this.caseIdContestar = result.Id;
            this.pageOneContestar = false;
            this.spinner = false;
        }).catch(error=>{
            console.log('Erro getCriarCaso: '+ error.message);
            this.showToast('Erro', 'Houve um erro ao criar caso!', 'error', true);
        });
    }

    handleCheckSeguro(event) { 
        const itemId = event.target.dataset.id;
        this.segurosFormatados = this.segurosFormatados.map(item => {
            if (item.idAdesao == itemId) {
                const updatedItem = { ...item, checked: event.target.checked };
                if (event.target.checked) {
                    this.segurosSelected.push(updatedItem);
                } else {
                    this.segurosSelected = this.segurosSelected.filter(selItem => selItem.idAdesao != itemId);
                }
                return updatedItem;
            }
            return item;
        });
        this.validateBtnLimparAndContestar();
    }

    handleBtnContestarSeguro(event) {
        this.usouBtnSeguro = true;
        const itemId = event.target.dataset.id;
        this.handleBtnLimpar()
        this.segurosSelected = this.segurosFormatados.filter(item => item.idAdesao == itemId);
        this.modalContestar = true;
    }

    handleBtnLimpar(){
        this.segurosSelected = [];
        this.segurosFormatados = this.segurosFormatados.map(item => ({ ...item, checked: false }));
        this.validateBtnLimparAndContestar();
    }

    handleBtnContestarSeguros(){
        this.modalContestar = true;
    }

    handleBtnNext(){
        if (this.pageOneContestar) {
            this.CriarCasoContestar();
        } else {
            window.location.href = '/lightning/r/Case/'+ this.caseIdContestar +'/view';
        }
    }

    handleFecharModalContestar(){
        this.modalContestar = false;
        this.pageOneContestar = true;
        if(this.usouBtnSeguro){
            this.usouBtnSeguro = false;
            this.segurosSelected = [];
        }
    }

    handleFieldOrigemCaso(event){
        this.origemCasoContestar = event.target.value;
        this.validateBtnNextContestar();
    }

    handleFieldCanalCaso(event){
        this.canalCasoContestar = event.target.value;
        this.validateBtnNextContestar();
    }

    validateBtnNextContestar(){
        this.disableBtnNextContestar = true;
        if(this.canalCasoContestar && this.origemCasoContestar){
            this.disableBtnNextContestar = false;
        }
    }

    loadSeguros(){
        const retorno = this.segurosSelected.map(item => ({nome: item.nomeProduto, contrato: item.idAdesao, motivo: item.motivoCancelamento}));
        return JSON.stringify(retorno);
    }

    validateBtnLimparAndContestar(){
        this.disabledBtnContestar = !this.segurosSelected.length > 0 ;
        this.disabledBtnLimpar = !this.segurosSelected.length > 0;
    }

    handleOrdenarNome() {
        this.ordenarLista("nomeProduto", "iconeNome");
    }

    handleOrdenarData() {
        this.ordenarLista("dataCancelamento", "iconeData");
    }

    handleOrdenarMotivo() {
        this.ordenarLista("motivoCancelamento", "iconeMotivo");
    }


    ordenarLista(campo, iconeCampo) {
        const ordemAscendente = this[iconeCampo] === "utility:arrowdown";
        
        this.segurosFormatados = [...this.segurosFormatados].sort((a, b) => {
            if (a[campo] < b[campo]) return ordemAscendente ? -1 : 1;
            if (a[campo] > b[campo]) return ordemAscendente ? 1 : -1;
            return 0;
        });

        this.iconeNome = iconeCampo === "iconeNome" ? (ordemAscendente ? "utility:arrowup" : "utility:arrowdown") : "utility:arrowdown";
        this.iconeData = iconeCampo === "iconeData" ? (ordemAscendente ? "utility:arrowup" : "utility:arrowdown") : "utility:arrowdown";
        this.iconeMotivo = iconeCampo === "iconeMotivo" ? (ordemAscendente ? "utility:arrowup" : "utility:arrowdown") : "utility:arrowdown";
    }


    formatDate(date) {
        const data = new Date(date);
        const dia = String(data.getDate()).padStart(2, '0');
        const mes = String(data.getMonth() + 1).padStart(2, '0');
        const ano = data.getFullYear();
        return `${dia}/${mes}/${ano}`;
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
            this.spinner = false;
        }
    }


}