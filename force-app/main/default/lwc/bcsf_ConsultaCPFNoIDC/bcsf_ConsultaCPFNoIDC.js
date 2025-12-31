import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, openTab } from 'lightning/platformWorkspaceApi';

import validarCpf from '@salesforce/apex/ConsultaCPFNoIDCcontroller.validarCpf';
import getAccount from '@salesforce/apex/ConsultaCPFNoIDCcontroller.getAccount';
import consultaContaPorCPF from '@salesforce/apex/IdentificaCockpitController.consultaContaPorCPF';

export default class Bcsf_ConsultaCPFNoIDC extends LightningElement {
    spinner = false;
    desableBuscar = true;
    showInfoAccount = false;
    canal = 'cockpit';
    
    @track cpfImput = '--';
    @track cpfImputFormat = '';
    @track accountId = '--';
    @track NameAccount = '--';
    @track DataNascimento = '--';
    @track cpfValido = false;
    @track precisaChamarAPI = false;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async buscar(){
        this.showSpinner();
        this.showInfoAccount = false;
        await this.validacaoCPF();
        if (this.cpfValido) {
            await this.buscarAccount();
            if (this.precisaChamarAPI) {
                await this.getIdentificaCockpit();
            }
        }
        this.closeSpinner();
    }

    //#region #################### VALIDAÇÕES/QUERYS ####################
    async validacaoCPF(){
        await validarCpf({
            cpf: this.cpfImput
        }).then(result=>{
            try {
                this.cpfValido = result;
                if (!result) {
                    this.showToast('', 'Este CPF é Inválido!', 'warning');
                }
            } catch (error) {
                console.log('Erro catch() validarCpf: '+ error);   
                this.showToast('Erro', 'Houve um erro ao realizar validação do CPF!', 'error');
            } 
        }).catch(error=>{
            console.log('Erro validarCpf: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao realizar validação do CPF!', 'error');
        })
    }

    async buscarAccount(){
        await getAccount({
            cpf: this.cpfImput
        }).then(result=>{
            try {
                if (result != null) {
                    let nascimentoFormatado = '--';
                    if (result.DataNascimento__c != null) {
                        let listNascimento = result.DataNascimento__c.split('-');
                        nascimentoFormatado = listNascimento[2] + '/' + listNascimento[1] + '/' + listNascimento[0];
                    }
                    this.showInfoAccount = true;
                    this.accountId = result.Id;
                    this.NameAccount = result.Name;
                    this.DataNascimento = nascimentoFormatado;
                    this.precisaChamarAPI = false;
                }else{
                    this.precisaChamarAPI = true;
                }
            } catch (error) {
                console.log('Erro catch() getAccount: '+ error);   
                this.showToast('Erro', 'Houve um erro ao tentar achar a conta do cliente!', 'error');
            } 
        }).catch(error=>{
            console.log('Erro getAccount: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao tentar achar a conta do cliente!', 'error');
        })
    }

    async getIdentificaCockpit(){
        await consultaContaPorCPF({
            cpf: this.cpfImput,
            canal: this.canal
        }).then(result=>{
            try {
                if (result != null) {
                    this.buscarAccount();
                }else{
                    this.showToast('', 'Cliente não encontrado!', 'warning');
                    this.showInfoAccount = false;
                }
            } catch (error) {
                console.log('Erro catch() consultaContaPorCPF: '+ error);   
                this.showToast('Erro', 'Houve um erro ao tentar achar a conta do cliente!', 'error');
            } 
        }).catch(error=>{
            console.log('Erro consultaContaPorCPF: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao tentar achar a conta do cliente!', 'error');
        })
    }

    irAccount(){
        openTab({
            url: '/lightning/r/Account/'+ this.accountId +'/view',
            focus: true
        }).catch((error) => {
            console.log('Erro openTab: '+ error.body.message);
        });
    }

    //#endregion

    //#region #################### HANDLERS ####################
    handlerCPF(event){
        this.cpfImput = event.target.value.replaceAll('.', '').replaceAll('-', '');
        this.desableBuscar = this.cpfImput.length == 11 ? false : true;

        let inputValue = event.target.value;
        let numeroApenas = inputValue.replace(/\D/g, '');
        if (numeroApenas.length > 3 && numeroApenas.length <= 6) {
            this.cpfImputFormat = `${numeroApenas.substring(0, 3)}.${numeroApenas.substring(3, 6)}`;
        } else if (numeroApenas.length > 6 && numeroApenas.length < 10) {
            this.cpfImputFormat = `${numeroApenas.substring(0, 3)}.${numeroApenas.substring(3, 6)}.${numeroApenas.substring(6, 9)}`;
        } else if (numeroApenas.length >= 10){
            this.cpfImputFormat = `${numeroApenas.substring(0, 3)}.${numeroApenas.substring(3, 6)}.${numeroApenas.substring(6, 9)}-${numeroApenas.substring(9, 11)}`;
        }
    }

    async handlerBtnConsultarProposta(){
        await this.validacaoCPF();
        if (!this.cpfValido) return;
        if (!this.isConsoleNavigation) return;
        let getStateShowInfo = this.showInfoAccount;
        await this.buscarAccount();
        this.showInfoAccount = getStateShowInfo;
        let accountId = this.precisaChamarAPI ? '': this.accountId;
        console.log('accountId: ', accountId);
        openTab({
            pageReference: {
                type: 'standard__component',
                attributes: {
                    actionName: 'view',
                    componentName: 'c__bcsf_ConsultarProposta',
                },
                state: {
                    c__cpf: this.cpfImputFormat,
                    c__nome: this.NameAccount,
                    c__accountId: accountId,
                }
            },
            icon: 'utility:description',
            focus: true,
            label: 'Consulta de proposta'
        }).catch((error) => {
            console.log('Erro openTab: '+ error);
        });
    }

    //#endregion

    //#region #################### INTERAÇÕES COM USUÁRIO ####################
    showSpinner() {
        this.spinner = true;
    }
    closeSpinner() {
        this.spinner = false;
    }

    showToast(titulo, mensagem, variante) {
        const evt = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variante,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    //#endregion

}