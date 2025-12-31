import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import CANAL_ENTRADA_FIELD from '@salesforce/schema/Case.CanalEntrada__c';
import MOTIVO_FATURA_FIELD from '@salesforce/schema/Case.MotivoFatura__c';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';

import getContaFinanceira from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getContaFinanceira';
import getFaturas from '@salesforce/apex/BCSF_SegundaViaFaturaController.getListaFaturas';
import criarCaso from '@salesforce/apex/BCSF_SegundaViaFaturaController.createCase';
import enviarFaturas from '@salesforce/apex/BCSF_SegundaViaFaturaController.enviarFaturas';
import atualizaEmail from '@salesforce/apex/BCSF_ModoEnvioFaturaController.atualizaEmail';
import updateEmailEnvioFatura from '@salesforce/apex/BCSF_ModoEnvioFaturaController.UpdateEmailEnvioFatura';

import getAssetTitular from '@salesforce/apex/AlteracaoCadastralController.getAssetTitular';
import GetAllValidationData from '@salesforce/apex/MetadataValidationConfigController.GetAllValidationData';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Bcsf_SegundaViaFatura extends LightningElement {

    @api recordId;
    cmp2viafatura = true;

    // Variaveis de layout 
    @track spinner = false;
    @track disableBtnPross = true;
    @track disableBtnVoltar = true;
    @track disableBtnFinalizar = true;
    @track pageOne = true;
    @track pageTwo = false;
    @track pageTree = false;
    @track checkedEmailAlternativo = false;
    @track checkedAlterarEmail = false;
    @track showSuggestions = false;
    @track todosSelecionados = false;
    @track ordemDataAscendente = false;
    @track iconeOrdenacao = 'utility:arrowdown';
    @track currentStep = '1';
    @track dataAtual;
    @track alertAlterarEmail = false;
    @track motivoFaturaOptions = [];
    @track selectedMotivoFatura = '';
    @track showMotivoOutro = false;
    @track motivoOutroTexto = '';


    //Valores retornados da conta e informações para a integração
    @track numeroConta;
    @track unidadeNegocio;
    @track accountId;
    @track cpf;
    @track email;
    @track emailAlternativo;
    @track emailSelecionado;
    @track tipoEnvio;
    @track canalAPI = 'cockpit';
    @track sistema = 'cockpit';
    @track area;
    @track modalSegundaVia = false;
    @track cmpSegundaViaFatura = true;
    @track cmpModoEnvioFatura = false;
    @track originOptions = [];
    @track selectedOrigin = '';
    @track canalEntradaOptions = [];
    @track selectedCanalEntrada = '';

    @track tempo;
    @track allowListProfiles;
    @track userProfileName;
    @track dataLimite;
    @track atendente;
    @track StatusConta;

    //Listas
    @track itens = [];
    @track itensSelecionados = [];
    @track itensEnvio = [];
    domainSuggestions = ['--Nenhum--', 'Yahoo', 'Gmail', 'Hotmail', 'Terra', 'Outlook', 'Uol', 'Icloud', 'Bol'];

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MOTIVO_FATURA_FIELD })
    wiredMotivoFaturaValues({ error, data }) {
        if (data) {
            this.motivoFaturaOptions = data.values;
        } else if (error) {
            console.error('Erro ao buscar picklist Motivo da Fatura:', error);
        }
    }

    //Card para liberar escolha de Origem e Canal
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ORIGIN_FIELD })
    wiredOriginValues({ error, data }) {
        if (data) {
            this.originOptions = data.values;
        } else if (error) {
            console.error('Erro ao buscar picklist Origin:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CANAL_ENTRADA_FIELD })
    wiredCanalEntradaValues({ error, data }) {
        if (data) {
            this.canalEntradaOptions = data.values;
        } else if (error) {
            console.error('Erro ao buscar picklist CanalEntrada__c:', error);
        }
    }
    // Fim Card para liberar escolha de Origem e Canal

    connectedCallback() {
        this.showSpinner();
        const today = new Date();
        const day = String(today.getDate()).padStart(2, '0');
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const year = today.getFullYear();

        this.dataAtual = `${day}/${month}/${year}`;

        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(async result => {
            try {
                this.numeroConta = result.NumeroConta;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.cpf = result.CPF.replaceAll('.', '').replaceAll('-', '');
                this.email = result.Email;
                this.tipoEnvio = result.TipoEnvio == "SMS" ? result.TipoEnvio : result.TipoEnvio.charAt(0).toUpperCase() + result.TipoEnvio.slice(1).toLowerCase();
                await this.buscarDadosValidacao();
                this.GetFaturas();
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContaFinanceira: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
    }
    async buscarDadosValidacao() {
        try {
            const result = await GetAllValidationData({
                contaFinanceiraId: this.recordId,
                userId: USER_ID
            });

            this.tempo = result.tempoLimite;
            this.allowListProfiles = result.perfisBypass;
            this.userProfileName = result.perfilUsuario;
            this.dataLimite = result.dataLimiteDesbloqueio;
            this.atendente = result.ultimoOperador;
            this.StatusConta = result.statusConta
            console.log('result: ', result);

        } catch (error) {
            console.error('❌ Erro ao buscar dados:', error);
        }
        await this.getAssetTitular();
        await this.handleContaValidada();
    }
    handleContaValidada() {
        let ContaCartaoNORM = this.statusCartaoPrimario === this.StatusConta &&
            this.statusCartaoPrimario === 'NORM';
        console.log('ContaCartaoNORM: ' + ContaCartaoNORM);
        console.log('statusCartaoPrimario: ' + this.statusCartaoPrimario);
        console.log('StatusConta : ' + this.StatusConta);
        if (this.allowListProfiles.includes(this.userProfileName)) {
            switch (ContaCartaoNORM) {
                case true:
                    console.log('Conta norm')
                    if (this.atendente == undefined || this.dataLimite == undefined) {
                        setTimeout(() => {
                        this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                        console.log('Fechando modal por falta de dados de validação...');
                        this.dispatchEvent(new CustomEvent('closeparentmodal'))
                        }, 2);
                    } else {
                        console.log('Chamando validação de tempo ')
                        this.validarTempoExpirado(this.dataLimite);
                    }
                    break;
                case false:
                    break;
            }
        }
    }

    async getAssetTitular() {
        await getAssetTitular({
            idContaFinanceira: this.recordId
        }).then(result => {
            try {
                this.statusCartaoPrimario = result.Status;
                console.log('statusCartaoPrimario: ' + this.statusCartaoPrimario);
            } catch (error) {
                console.log('Erro catch() getAssetTitular: ' + error);
            }
        }).catch(error => {
            console.log('Erro getAssetTitular: ' + error.body.message);
            console.dir(error);
        });
    }
    validarTempoExpirado(dataLimiteStr) {
        if (!dataLimiteStr) {
            console.warn('⚠️ Data limite não informada.');
            return;
        }
        const dataLimite = new Date(dataLimiteStr);
        const agora = new Date();
        const diferencaMinutos = (agora.getTime() - dataLimite.getTime()) / (1000 * 60);

        // console.log(`🕒 Diferença em minutos: ${diferencaMinutos.toFixed(2)}`);

        if (diferencaMinutos >= this.tempo || this.atendente !== USER_ID) {
            setTimeout(() => {
                this.showToast('Atenção', `Cliente não possue senha validada`, 'warning');
                console.log('⛔ Fora do tempo limite. Fechando modal...');
                this.dispatchEvent(new CustomEvent('closeparentmodal'))
            }, 2);
        } else {
            console.log('✅ Dentro do tempo limite. Mantendo modal aberto. ');
        }
    }
    GetFaturas() {
        getFaturas({
            numeroConta: this.numeroConta,
            idEmpresa: this.unidadeNegocio,
            cpf: this.cpf,
            canal: this.canalAPI
        }).then(result => {
            if (result[0].StatusOK != 'SEM FATURAS') {
                result.forEach(item => {
                    let [ano, mes] = item.data.split('-');
                    this.itens.push({ id: Number(item.idFatura), data: `${mes}/${ano}`, dataCompleta: item.data, checked: false })
                })
                this.closeSpinner();
            } else {
                this.showToast('Alerta', 'Esta conta ainda não possui faturas fechadas!', 'Warning', true);
            }
        }).catch(error => {
            console.log('Erro getFaturas: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar faturas!', 'error', true);
        })
    }

    UpdateEmailEnvioFatura() {
        updateEmailEnvioFatura({
            idEmpresa: this.unidadeNegocio,
            sistema: this.sistema,
            canal: this.canalAPI,
            area: this.area,
            cpf: this.cpf,
            numeroConta: this.numeroConta,
            emailToUpdate: this.emailAlternativo
        }).then((result) => {
            if (result.StatusAPI == 'OK') {
                this.AtualizaEmail();
            } else {
                this.showToast('Erro', 'Erro ao atualizar E-mail de envio da fatura', 'error', true);
            }
        }).catch(error => {
            console.log('Erro UpdateEmailEnvioFatura: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao atualizar E-mail de envio da fatura', 'error', true);
        });
    }
    EnviarFaturas() {
        enviarFaturas({
            idEmpresa: this.unidadeNegocio,
            sistema: this.sistema,
            canal: this.canalAPI,
            area: this.area,
            cpf: this.cpf,
            numeroConta: this.numeroConta,
            email: this.emailSelecionado,
            listFaturas: this.itensEnvio
        }).then(result => {
            if (result) {
                if (this.checkedAlterarEmail) {
                    this.UpdateEmailEnvioFatura();
                } else {
                    this.CriarCaso();
                }
            } else {
                this.showToast('Erro', 'Houve um erro ao enviar faturas!!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro : EnviarFaturas' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao enviar faturas!', 'error', true);
        });
    }
    CriarCaso() {
        criarCaso({
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            origem: this.selectedOrigin,
            canalEntrada: this.selectedCanalEntrada,
            motivo: this.selectedMotivoFatura,
            motivoDescricao: this.motivoOutroTexto
        }).then((result) => {
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.pageTwo = false;
            this.pageTree = true;
            this.closeSpinner();

        }).catch(error => {
            console.log('Erro CriarCaso: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao Criar Caso', 'error', true);
        });
    }

    AtualizaEmail() {
        atualizaEmail({
            contaFinanceiraId: this.recordId,
            emailToUpdate: this.email
        }).then(result => {
            this.CriarCaso();
        }).catch(error => {
            console.log('Erro AtualizaEmail: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao atualizar email', 'error', true);
        });
    }

    //#region Métodos Handle
    handleProsseguir() {
        this.pageOne = false;
        this.pageTwo = true;
        this.disableBtnVoltar = false;
        this.currentStep = '2';
    }

    handleButtonVoltar() {
        this.pageOne = true;
        this.pageTwo = false;
        this.disableBtnVoltar = true;
    }

    handleFinalizar() {
        this.itensSelecionados.forEach(item => {
            let lista = [];
            lista.push(item.id.toString());
            lista.push(item.dataCompleta);
            this.itensEnvio.push(lista);
        });
        this.pageOne = false;
        this.pageTwo = false;
        this.pageTree = true;
        this.alertAlterarEmail = this.checkedAlterarEmail ? true : false;
        this.spinner = true;
        this.currentStep = '3';
        this.emailSelecionado = this.checkedEmailAlternativo ? this.emailAlternativo : this.email;
        this.EnviarFaturas();
    }

    handleEmailAlternativo() {
        this.checkedEmailAlternativo = !this.checkedEmailAlternativo;
        this.disableBtnFinalizar = this.checkedEmailAlternativo ? true : false;
    }

    handleAlterarEmail() {
        this.checkedAlterarEmail = !this.checkedAlterarEmail;
    }

    handleEmailChange(event) {
        this.disableBtnFinalizar = true;
        this.emailAlternativo = event.target.value;
        this.showSuggestions = this.emailAlternativo.includes('@');
    }
    handleFocusedEmail() {
        this.validateEmailFormat();
        setTimeout(() => {
            this.closeSuggestions();
        }, 300);
    }

    handleListCheckboxChange(event) {
        const itemId = event.target.dataset.id;
        this.itens = this.itens.map(item => {
            if (item.id === parseInt(itemId, 10)) {
                const updatedItem = { ...item, checked: event.target.checked };
                if (event.target.checked) {
                    this.itensSelecionados.push(updatedItem);
                } else {
                    this.itensSelecionados = this.itensSelecionados.filter(selItem => selItem.id != itemId);
                }
                return updatedItem;
            }
            return item;
        });
        this.atualizarStatusTodosSelecionados();
        this.verificarListaData();
    }

    handleOriginChange(event) {
        this.selectedOrigin = event.detail.value;
    }

    handleMotivoFaturaChange(event) {
        this.selectedMotivoFatura = event.detail.value;
        this.showMotivoOutro = (this.selectedMotivoFatura == 'OUTROS');
    }

    handleMotivoOutroChange(event) {
        this.motivoOutroTexto = event.detail.value;
    }

    handleCanalEntradaChange(event) {
        this.selectedCanalEntrada = event.detail.value;

        if (this.selectedCanalEntrada === null || this.selectedCanalEntrada === '' || this.selectedCanalEntrada === undefined) {
            this.disableBtnFinalizar = true;
        } else {
            this.disableBtnFinalizar = false;
        }
    }


    handleSelecionarTodos(event) {
        this.todosSelecionados = event.target.checked;
        this.itens = this.itens.map(item => ({ ...item, checked: this.todosSelecionados }));
        this.itensSelecionados = this.itens.filter(item => item.checked);
        this.verificarListaData();
    }

    atualizarStatusTodosSelecionados() {
        this.todosSelecionados = this.itens.every(item => item.checked);
        this.itensSelecionados = this.todosSelecionados ? [...this.itens] : this.itensSelecionados;
    }

    handleAlternarOrdenacao() {
        this.ordemDataAscendente = !this.ordemDataAscendente;
        this.iconeOrdenacao = this.ordemDataAscendente ? 'utility:arrowup' : 'utility:arrowdown';
        this.ordenarLista();
    }

    handleBtnAlterarModoEnvio() {
        this.cmpSegundaViaFatura = false;
        this.cmpModoEnvioFatura = true;
    }
    //#endregion

    //#region Métodos padrões e auxiliares
    selectSuggestion(event) {
        const selectedDomain = event.target.textContent;
        if (selectedDomain != "--Nenhum--") {
            this.emailAlternativo = `${this.emailAlternativo.split('@')[0]}@${selectedDomain.toLowerCase()}.com`;
        }
        this.closeSuggestions();
        this.validateEmailFormat();
    }

    closeSuggestions() {
        this.showSuggestions = false;
    }

    ordenarLista() {
        if (this.pageOne) {
            this.itens.reverse();
        } else {
            this.itensSelecionados.reverse();
        }
    }

    validateEmailFormat() {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (this.emailAlternativo && !emailRegex.test(this.emailAlternativo)) {
            this.errorText = 'Formato inválido';
            this.errorStyle = 'color: #BB462D; display: block;position: absolute;';
            this.disableBtnFinalizar = true;
        } else if (this.emailAlternativo == '') {
            this.errorText = 'Informe o E-mail';
            this.errorStyle = 'color: #BB462D; display: block;position: absolute;';
            this.disableBtnFinalizar = true;
        } else {
            this.errorText = '';
            this.errorStyle = 'color: red; display: none;transition: 0.8s';
            this.disableBtnFinalizar = false;
        }
    }

    verificarListaData() {
        if (this.itensSelecionados.length > 0) {
            this.disableBtnPross = false;
        } else {
            this.disableBtnPross = true;
        }
    }

    showSpinner() {
        this.spinner = true;
    }

    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante, closeModal, mode = 'dismissable') {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: mode
        });
        this.dispatchEvent(evt);

        if (closeModal) {
            this.closeQuickAction();
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('closeparentmodal'))
    }

    irCase() {
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }

    get motivoDisplay() {
        return this.selectedMotivoFatura == 'OUTROS'
            ? this.motivoOutroTexto || 'Outros'
            : this.selectedMotivoFatura || '—';
    }
    //#endregion

}