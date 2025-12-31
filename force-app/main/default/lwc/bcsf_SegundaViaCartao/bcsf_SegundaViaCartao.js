import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from 'lightning/navigation';

import USER_ID from '@salesforce/user/Id';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';


import getContaFinanceira from '@salesforce/apex/BCSF_ReimpressaoSenhaController.getContaFinanceira';
import createCase from '@salesforce/apex/BCSF_SegundaViaCartaoController.createCaseNomeReduzido';
import getListCartoes from '@salesforce/apex/BCSF_SegundaViaCartaoController.getListCartoes';
import reemitirCartao from '@salesforce/apex/BCSF_SegundaViaCartaoController.ReemitirCartao';
import ReemitirCartaoComAlteracaoNomeReduzido from '@salesforce/apex/BCSF_SegundaViaCartaoController.ReemitirCartaoComAlteracaoNomeReduzido';
import updateAtivo from '@salesforce/apex/BCSF_SegundaViaCartaoController.updateAtivo';

export default class Bcsf_SegundaViaCartao extends NavigationMixin(LightningElement) {

    @api recordId;
    value = '';

    //Variaveis de Layout
    @track spinner = false;
    @track pageOne = true;
    @track pageTwo = false;
    @track stepOne = true;
    @track stepTwo = false;
    @track secondStepOne = false;
    @track secondStepTwo = false;
    @track stepNameOne = false;
    @track stepNameTwo = false;
    @track stepNameRadio = false;
    @track stepNameRadioIcon = false;
    @track errorMessage = '';
    @track disableBtnVoltar = true;
    @track disableBtnProsseguir = true;
    @track disableBtnFinalizar = true;
    @track disableInputStatus = true;
    @track disableAlterarNome = true;
    @track disableMotivo = false;
    @track numProtocolo = "--"
    @track titleProtocol = false;

    //Dados para integração e Caso
    @track valueOrigem;
    @track valueCanal;
    @track area;
    @track canal = 'cockpit';
    @track valueCartao;
    @track nomeCartao = 'Final 1234 - Julia Pereira (Titular)';
    @track nomeCartaoAlterar = 'Julia Pereira';
    @track nomeCompleto = 'Julia Pereira';
    @track nomeCompletoParts;
    @track nomeReduzido = 'Julia Pereira';
    @track nomeCartaoEnviar = null;
    @track copy;
    @track valueMotivo;
    @track valueMotivoSelecionado;
    @track valueBraile = "Não";
    @track cartaoOptions;
    @track numeroCartaoOfuscado;
    @track motivoOptions;
    @track checkedBraile = false;
    @track checkedNomeReduzido = false;
    @track listStatusBloqueados;
    @track alterarStatus;
    @track template;

    //Informações do Cliente
    @track cep;
    @track rua;
    @track numero;
    @track complemento;
    @track bairro;
    @track cidade;
    @track estado;
    @track numeroConta;
    @track unidadeNegocio;
    @track accountId;
    @track cpf;
    @track dataNascimento;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && !this.recordId) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.showSpinner();
        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.numeroConta = result.NumeroConta;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                this.cep = result.CEP;
                this.rua = result.Rua;
                this.numero = result.Numero;
                this.complemento = result.Complemento;
                this.bairro = result.Bairro;
                this.cidade = result.Cidade;
                this.estado = result.Estado;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.GetListCartoes();

            } catch (error) {
                console.log('Erro catch() getContaFinanceira: ' + error);
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            }
        }).catch(error => {
            console.log('Erro getContaFinanceira: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
        this.closeSpinner();
    }

    navegarParaAlteracao(){
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName:"ContaFinanceira__c.AlteracaoDadosCadastrais"
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    get radioOptions() {
        return [
            { label: this.nomeReduzido, value: 'nomeReduzido' },
            { label: 'Outro', value: 'outro' },
        ];
    }

    handleNameRadio(event) {
        this.value = event.detail.value;
        this.stepNameRadio = (this.value === 'outro');
        this.stepNameRadioIcon = (this.value === 'outro');
        this.nomeCartaoEnviar = this.nomeReduzido;
        this.verifyDisable();
    }

    handleNomeDigitado(event) {
        this.nomeCartaoEnviar = event.target.value != null ? event.target.value.toUpperCase() : '';;
        this.stepNameRadioIcon = false;

        try {
            let idCampo = event.target.id;
            let valorCampo = event.target.value != null ? event.target.value.toUpperCase() : '';
            let numeroApenas = this.returnApenasNumero(valorCampo);
            let ultimoCaracter = valorCampo.split('')[valorCampo.split('').length - 1];
            let ehCaracter = JSON.stringify(parseInt(ultimoCaracter)) == 'null' ? true : false;
            let specialCharPattern = /[^a-zA-Z0-9áéíóúÁÉÍÓÚãõÃÕâêîôûÂÊÎÔÛàèìòùÀÈÌÒÙäëïöüÄËÏÖÜçÇ\s]/;
            let acento = /[^a-zA-Z0-9\s]/;
            let espacoDuplo = /\s{2,}/;
            let temCaracterEspecial = specialCharPattern.test(valorCampo);
            let temEspacoDuplo = espacoDuplo.test(valorCampo);
            let temAcento = acento.test(valorCampo);
            let input = event.target;

            if (idCampo.includes('nomeCartaoEnviar')) {

                if (temCaracterEspecial || temAcento || !ehCaracter) {
                    input.value = this.PrimeiroNome;
                    this.errorMessage = 'O nome não pode conter caracteres especiais ou números.';
                    this.nomeCartaoEnviar = this.nomeCartaoEnviar.replace(specialCharPattern, '');
                    this.nomeCartaoEnviar = this.nomeCartaoEnviar.replace(acento, '');
                    this.nomeCartaoEnviar = this.nomeCartaoEnviar.replace(/[0-9]/g, '');
                } else if (temEspacoDuplo) {
                    input.value = this.PrimeiroNome;
                    this.errorMessage = 'Não pode conter espaços duplos.';
                }
                else {
                    this.PrimeiroNome = valorCampo;
                    this.errorMessage = '';
                }
            }

        } catch (error) {
            console.log('ERROR handlerField: ' + error);
            this.disableButtonAvancar = true;
        }
    }

    handleCopy(event) {
        this.copy = event.target.value;

        const formattedText = this.copy;
        const textarea = document.createElement('textarea');
        textarea.value = formattedText;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
    }

    //#region Métodos Integração e criação de caso
    GetListCartoes() {
        getListCartoes({
            canal: this.canal,
            area: this.area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            idEmpresa: this.unidadeNegocio
        }).then(result => {
            if (result.cartoesElegiveis != null) {

                this.cartaoOptions = result.cartoesElegiveis.map(item => ({
                    label: `Final ${item.numeroCartaoOfuscado.slice(-4)} - ${item.nomePortador} ${item.ehPrimario ? "(Titular)" : ""}`,
                    value: `${item.numeroCartaoSerno}`,
                    ehPrimario: item.ehPrimario,
                    status: item.status,
                    alterarStatus: item.precisaAlterarStatus,
                    numberCartao: `${item.numeroCartaoOfuscado}`,
                    nomeCartao: `${item.nomeCartao}`,
                    nomeCompleto: `${item.nomePortador}`
                }));
                if (this.cartaoOptions.length == 0) {
                    this.showToast('Erro', 'Esta conta financeira não possui cartões para emissão de segunda via.', 'error', true);
                }
                this.motivoOptions = result.status.map(status => ({
                    label: `${status.nome} - ${status.descricao}`,
                    value: `${status.nome}`
                }));

                this.closeSpinner();
            } else {
                this.showToast('Erro', 'Esta conta financeira não possui cartões para emissão de segunda via.', 'error', true);
            }

        }).catch(error => {
            console.log('Erro getListCartoes: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar cartões para gerar a segunda via!', 'error', true);
        });
    }

    ReimprimirCartao() {
        this.showSpinner();
        reemitirCartao({
            idEmpresa: this.unidadeNegocio,
            sistema: this.canal,
            canal: this.canal,
            area: this.area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            numeroCartaoSerno: this.valueCartao,
            novoStatus: this.valueMotivo
        }).then(result => {
            let emitidoRecente = /7.*dias|dias.*7/.test(result.message);
            if (result.StatusAPI) {
                this.UpdateCartao();
            } else if (result.statusCode == '422' && emitidoRecente) {
                this.stepTwo = false;
                this.pageOne = false;
                this.pageTwo = true;
                this.secondStepTwo = true;
                this.closeSpinner();
                this.showToast('Erro', 'Não foi possivel solicitar segunda via.', 'error', false);
            } else {
                this.showToast('Erro', 'Não foi possivel solicitar segunda via.', 'error', true);
            }
        }).catch(error => {
            console.log('Erro reimprimir Cartão: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao solicitar segunda via!', 'error', true);
        });
    }

    ReimprimirCartaoNomeReduzido() {
        this.showSpinner();
        ReemitirCartaoComAlteracaoNomeReduzido({
            idEmpresa: this.unidadeNegocio,
            sistema: this.canal,
            canal: this.canal,
            area: this.area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta,
            numeroCartaoSerno: this.valueCartao,
            novoStatus: this.valueMotivo,
            nomeReduzido: this.nomeCartaoEnviar
        }).then(result => {
            let emitidoRecente = /7.*dias|dias.*7/.test(result.message);
            if (result.StatusAPI) {
                this.UpdateCartao();
            } else if (result.statusCode == '422' && emitidoRecente) {
                this.stepTwo = false;
                this.pageOne = false;
                this.pageTwo = true;
                this.secondStepTwo = true;
                this.closeSpinner();
                this.showToast('Erro', 'Não foi possivel solicitar segunda via com nome reduzido.', 'error', false);
            } else {
                this.showToast('Erro', 'Não foi possivel solicitar segunda via com nome reduzido.', 'error', true);
            }
        }).catch(error => {
            console.log('Erro reimprimir Cartão: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao solicitar segunda via com nome reduzido!', 'error', true);
        });
    }

    UpdateCartao() {
        this.showSpinner();
        updateAtivo({
            contaFinanceiraId: this.recordId,
            cartaoOfuscado: this.numeroCartaoOfuscado,
            newStatus: this.valueMotivo
        }).then(() => {
            this.CreateCase();
        }).catch(error => {
            console.log('Erro updateAtivo: ' + error.body.message);
            this.showToast('Erro', 'Ouve um erro ao atualizar Cartão!', 'error', true);
        });
    }

    CreateCase() {
        createCase({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal,
            isBraile: this.checkedBraile,
            isNomeReduzido: this.checkedNomeReduzido
        }).then(result => {
            this.stepTwo = false;
            this.pageOne = false;
            this.pageTwo = true;
            this.secondStepOne = true;
            this.disableBtnVoltar = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
            this.refreshPage();
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro createCase: ' + error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
            this.showSpinner = false;
        });
    }
    //#endregion

    //#region - Métodos handle
    passwordHintClass = "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide"
    togglePasswordHint() {
        this.passwordHintClass = this.passwordHintClass == 'slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide' ? "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-rise-from-ground" : "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide"
    }

    handleBtnProsseguir() {
        this.stepOne = false;
        this.stepTwo = true;
        this.stepNameOne = false;
        this.stepNameTwo = false;
        this.disableBtnVoltar = false;
        this.titleProtocol = true;
    }

    handleBtnVoltar() {

        this.disableBtnVoltar = true;
        this.disableBtnProsseguir = true;
        this.stepOne = true;
        this.stepTwo = false;
        this.stepNameOne = true;
        this.stepNameTwo = false;
        this.checkedNomeReduzido = false;
        this.titleProtocol = false;
        this.disableMotivo = false;
        this.IncluirMotivoCancelamento();
        this.verifyDisable();
    }

    handleAlteraNomeCartao(event) {
        this.stepNameTwo = event.target.checked;
        this.checkedNomeReduzido = event.target.checked;
        this.nomeCartaoEnviar = null;
        this.IncluirMotivoCancelamento();
    }

    IncluirMotivoCancelamento() {
        if (this.checkedNomeReduzido == true) {
            this.disableInputStatus = true;
            this.motivoOptions.push({
                label: 'CLSC - CANCELAMENTO PELO CLIENTE',
                value: 'CLSC'
            });
            this.valueMotivo = 'CLSC';
            this.valueMotivoSelecionado = 'CLSC';
            this.AlterarStatus(this.valueMotivoSelecionado);
        }
        else {
            this.disableInputStatus = false;
            this.motivoOptions = this.motivoOptions.filter(option => option.value !== 'CLSC');
            this.valueMotivo = null;
            this.valueMotivoSelecionado = null;
        }
    }

    AlterarStatus(valueMotivoSelecionado) {
        this.valueMotivo = valueMotivoSelecionado;
        this.valueMotivoSelecionado = valueMotivoSelecionado;
    }

    handleBtnFinalizar() {
        if (!this.checkedNomeReduzido) {
            console.log('Reimpimir Cartao');
            this.ReimprimirCartao();
        }
        else {
            console.log('Reimprimir Cartao Nome Reduzido')

            this.ReimprimirCartaoNomeReduzido();
        }
    }

    handleCartao(event) {
        this.valueMotivo = null;
        this.valueMotivoSelecionado = 'Selecione o motivo';
        this.disableBtnProsseguir = true;
        this.valueCartao = event.detail.value;
        this.nomeCartao = this.cartaoOptions.find(option => option.value == this.valueCartao).label;
        this.numeroCartaoOfuscado = this.cartaoOptions.find(option => option.value == this.valueCartao).numberCartao;
        this.alterarStatus = this.cartaoOptions.find(option => option.value == this.valueCartao).alterarStatus;
        this.nomeCartaoAlterar = this.cartaoOptions.find(option => option.value == this.valueCartao).nomeCartao;
        this.nomeCompleto = this.cartaoOptions.find(option => option.value == this.valueCartao).nomeCompleto;
        this.nomeCompletoParts = this.nomeCompleto.split(' ').filter(part => part !== '');
        let nomePartes = this.nomeCompleto.split(' ');
        this.nomeReduzido = nomePartes[0] + ' ' + nomePartes[nomePartes.length - 1];
        this.nomeMaxCaractere();
        this.nomeCartaoEnviar = this.nomeCartaoAlterar;
        this.disableInputStatus = this.alterarStatus ? false : true;
        this.stepNameOne = true;
        if (!this.alterarStatus) {
            this.valueMotivo = this.cartaoOptions.find(option => option.value == this.valueCartao).status;
            this.valueMotivoSelecionado = this.valueMotivo;
        }

        if(this.checkedNomeReduzido == true){
            this.handleBtnVoltar();
        }
        this.verificarParteNome();
        this.verifyDisable();
    }

    verificarParteNome() {
        if (this.nomeCompletoParts.length != 2) {
            this.disableAlterarNome = false;
        } else {
            if (this.checkedNomeReduzido) {
                this.checkedNomeReduzido = false;
            }
            this.disableAlterarNome = true;
            this.stepNameTwo = false;
        }
    }

    nomeMaxCaractere() {
        if (this.nomeReduzido.length > 19) {
            this.nomeReduzido = this.nomeReduzido.substring(0, 19);
        }

    }

    handleMotivo(event) {
        this.valueMotivo = event.detail.value;
        this.valueMotivoSelecionado = event.detail.value;
        this.verifyDisable();
    }

    handleBraile(event) {
        this.checkedBraile = event.target.checked;
        this.valueBraile = event.target.checked ? "Sim" : "Não";
    }

    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.verifyDisable();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyDisable();
    }

    handleMudarCartao() {
        this.spinner = false;
        this.pageOne = true;
        this.pageTwo = false;
        this.stepOne = true;
        this.stepTwo = false;
        this.disableBtnVoltar = true;
        this.disableBtnProsseguir = true;
        this.disableBtnFinalizar = true;
        this.disableInputStatus = true;
        this.numProtocolo = "--"
        this.titleProtocol = false;
        this.secondStepOne = false;
        this.secondStepTwo = false;
        this.valueCartao = '';
        this.valueMotivo = '';
        this.valueCanal = '';
        this.valueOrigem = '';
    }
    //#endregion

    //#region - INTERAÇÕES COM USUÁRIO 
    irCase() {
        window.location.href = '/lightning/r/Case/' + this.caseId + '/view';
    }

    verifyDisable() {
        if (this.stepOne) {
            if (this.valueCartao != null) {
                this.disableBtnProsseguir = true;
                if (this.alterarStatus && this.valueMotivo != null) {
                    this.disableBtnProsseguir = false;
                } else if (!this.alterarStatus) {
                    this.disableBtnProsseguir = false;
                }
            }
        } else {
            if (this.valueCanal != null && this.valueOrigem != null) {
                this.disableBtnFinalizar = false;
            }
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

    returnApenasNumero(valor) {
        return valor.replace(/\D/g, '');
    }

    @api closeParentComponent;
    closeQuickAction() {
        if (this.closeParentComponent) {
            this.dispatchEvent(new CustomEvent('closeparentmodal'));
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    refreshPage(event) {
        // refresh the standard related list
        this.dispatchEvent(new RefreshEvent());
    }
    //#endregion 

}