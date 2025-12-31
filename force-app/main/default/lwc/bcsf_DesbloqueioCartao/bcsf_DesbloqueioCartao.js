import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LogoCarrefour from '@salesforce/resourceUrl/LogoCarrefour';
import LogoAtacadao from '@salesforce/resourceUrl/LogoAtacadao';
import LogoSamsClub from '@salesforce/resourceUrl/LogoSamsClub';

import getContaFinanceira from '@salesforce/apex/BCSF_CancelamentoContaController.getContaFinanceira';
import getListCartoes from '@salesforce/apex/BCSF_DesbloqueioCartaoController.getListCartoes';
import desbloquearCartao from '@salesforce/apex/BCSF_DesbloqueioCartaoController.desbloquearCartao';
import createCase from '@salesforce/apex/BCSF_DesbloqueioCartaoController.createCase';
import updateAtivo from '@salesforce/apex/BCSF_DesbloqueioCartaoController.updateAtivo';
import getInfoStatus from '@salesforce/apex/BCSF_BloqueioCartaoController.getInfoStatus';
import AREA_PRINCIPAL from '@salesforce/schema/User.AreaPrincipal__c';
import USER_ID from '@salesforce/user/Id';





export default class Bcsf_DesbloqueioCartao extends LightningElement {
    //#region ######### VARIAVEIS ##########
    spinner = false;
    logoTipo;
    caseId;
    @api recordId;

    @track disableButton = true;
    @track buttonPross = true;

    @track stepOne = true;
    @track stepTwo = false;
    @track stepThree = false;
    @track showCardPrincipal = true;
    @track showButtonProsseguir = true;
    @track valueCartoes = null;
    @track numeroCartao = null;
    @track numeroSerno = null;
    @track valueStatusCartoes = null;
    @track newValueStatus = null;
    @track valueOrigem = null;
    @track valueCanal = null;
    @track unidadeNegocio = null;
    @track accountId = null;
    @track  contaValidada = false;
    @track currentStep = '1';
    @track nome = '--';
    @track nomeNoCartao = '--';
    @track numeroConta = '--';
    @track statusConta = '--';
    @track tipoConta = '--';
    @track cpf = '--';
    @track dataNascimento = '--';
    @track hasErrorSteps = false;
    @track hasErrorSteps = false;
    
    @track statusContaInfo = 'Informação indisponível';
    @track statusCartaoInfo = 'Informação indisponível';
    @track Area = null;
 
    @track canal = 'cockpit';

    optionsCartoes = [];
    listaCartoes = [];
    numProtocolo;
    
//#endregion 
    
//#region ########## CARREGAMENTO DE DATA OPTIONS ##########

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    } 
    @wire(getRecord, { recordId: USER_ID, fields: [AREA_PRINCIPAL]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.Area = data.fields.AreaPrincipal__c.value;
        } else if (error) {
            this.error = error ;
        }
    }
    connectedCallback() { 
        this.showSpinner();
        getContaFinanceira({
            contaFinanceiraId: this.recordId
        }).then(result => {
            try {
                this.nome = result.Nome;
                this.numeroConta = result.NumeroConta;
                this.statusConta = result.StatusConta;
                this.cpf = result.CPF;
                this.dataNascimento = result.DataNascimento;
                this.unidadeNegocio = result.UnidadeNegocio;
                this.accountId = result.AccountId;
                
                this.statusContaInfo = this.GetStatusInfo(result.StatusConta, false, true);
                
                if (result.UnidadeNegocio == "1") {
                    this.tipoConta = 'Carrefour';
                    this.logoTipo = LogoCarrefour;
                } else if (result.UnidadeNegocio == "2") {
                    this.tipoConta = 'Atacadão';
                    this.logoTipo = LogoAtacadao;
                }else if (result.UnidadeNegocio == "6"){
                    this.tipoConta = "Sam's Club";
                    this.logoTipo = LogoSamsClub;
                }
                this.listarCartoes(this.canal, this.Area);
            } catch (error) {
                console.log('Erro catch() getContaFinanceira: '+ error);   
                this.showToast('Erro', 'Houve um erro ao buscar informações!', 'error', true);
            } 
        }).catch(error => {
            console.log('Erro getContaFinanceira: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao buscar informações sobre a Conta Financeira!', 'error', true);
        });
       
    }
//#endregion 

//#region ########## HANDLER PICKLISTS ##########

    handleChangeStatusCartao(event) {
        this.valueCartoes = event.detail.value;
        console.log(this.valueCartoes);
        this.nomeNoCartao = event.detail.value.split(" - ")[0];
        this.numeroCartao = event.detail.value.split(" - ")[1];
        this.valueStatusCartoes = event.detail.value.split(" - ")[2];
        this.verifyDesable();
        this.GetStatusInfo(event.detail.value.split(" - ")[2], true, false);
        
        this.listaCartoes.forEach(item => {            
            if (item.numeroCartaoOfuscado == this.numeroCartao) {
                this.numeroSerno = item.numeroCartaoSerno;
            }
        });    
        
        
    }


    handleChangeOrigem(event) {
        this.valueOrigem = event.detail.value;
        this.verifyDesable();
    }

    handleChangeCanal(event) {
        this.valueCanal = event.detail.value;
        this.verifyDesable();
    }
//#endregion 


//#region ########## BUTTONS ##########
    
    handleProsseguir(event) {
        if(this.stepOne == true){
            this.currentStep = '2';
            this.stepOne = false;
            this.stepTwo = true;
            this.disableButton = false;
            this.showButtonProsseguir = false;
        }else if(this.stepTwo == true){
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.disableButton = false;
        }
    }

    handleButtonVoltar(event) {
        if(this.stepTwo == true){
            this.currentStep = '1';
            this.disableButton = true;
            this.stepOne = true;
            this.stepTwo = false;
            this.showButtonProsseguir = true;
            
        }else if(this.stepThree == true){
            this.currentStep = '2';
            this.stepTwo = true;
            this.stepThree = false;
            this.showCardPrincipal = true;
            this.disableButton = false;
        }
    }

    handleConfirmaDesbloqueio(event){
        this.DesbloquearCartao(this.canal, this.Area);;
    }

    verifyDesable(){
        if (this.valueCartoes == null || this.valueCartoes == undefined ||
            this.valueOrigem == null || this.valueOrigem == undefined ||
            this.valueCanal == null || this.valueCanal == undefined) {
            
            this.buttonPross = true;
        }else{
            this.buttonPross = false;
        }
    }

    irCase(){
        window.location.href = '/lightning/r/Case/'+ this.caseId +'/view';
    }
//#endregion 

//#region ########## DML/QUERY ##########

    CreateCase(){
        this.showSpinner();
        createCase({
            origem: this.valueOrigem,
            contaFinanceiraId: this.recordId,
            accountId: this.accountId,
            unidadeNegocio: this.unidadeNegocio,
            canal: this.valueCanal
        }).then(result => {
            this.UpdateCartao();
            this.currentStep = '3';
            this.showCardPrincipal = false;
            this.stepTwo = false;
            this.stepThree = true;
            this.disableButton = true;
            this.numProtocolo = result.CaseNumber;
            this.caseId = result.Id;
        }).catch(error => {
            console.log('Erro createCase: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao criar Caso!', 'error', true);
        });
    }


    UpdateCartao(){
        this.showSpinner();

        updateAtivo({
            contaFinanceiraId: this.recordId,
            cartaoOfuscado: this.numeroCartao,
            newStatus: 'NORM'
        }).then(() => {
            this.closeSpinner();
        }).catch(error => {
            console.log('Erro updateAtivo: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao atualizar Cartão!', 'error', true);
        });
    }
    
    GetStatusInfo(status, StatusCartao, StatusConta){
        getInfoStatus({
            status: status
        }).then(result => {
            
            if (StatusCartao && !StatusConta) {
                this.statusCartaoInfo = result.Descricao__c;
            }else if(!StatusCartao && StatusConta){
                this.statusContaInfo = result.Descricao__c;
            }
        }).catch(error => {
            console.log('Erro getInfoStatus: '+ error.body.message);
        });
    }

//#endregion 

//#region ########## INTEGRAÇÕES API ##########

    listarCartoes(canal, area){
        console.log(canal + ' - ' + area);
        //this.showSpinner();
            /* canal: 'cockpit',
            area: 'atendimento_tambore',
            cpf: '49926079857',
            numeroConta: '10000019496' */

        getListCartoes({
            canal: canal,
            area: area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''),
            numeroConta: this.numeroConta
        }).then(result => {
            if (result.length > 0) {
                this.listaCartoes = result;
                let opcoes = [];

                result.forEach(item => {
                    opcoes.push(
                        {
                            label: item.nomeCartao + ' - ' +item.numeroCartaoOfuscado + ' - ' + item.status, 
                            value: item.nomeCartao + ' - ' +item.numeroCartaoOfuscado + ' - ' + item.status,
                            ehPrimario: item.ehPrimario
                        }
                    );

                });

                this.optionsCartoes = opcoes;
                this.closeSpinner();
            }else{
                this.showToast('Erro', 'Esta conta financeira não possui cartões de crédito disponíveis para desbloqueio.', 'warning', true);
            }
            
        }).catch(error => {
            console.log('Erro getListCartoes: '+ error.body.message);
            console.log('Erro getListCartoes body: '+ error.body);
            this.showToast('Erro', 'Houve um erro ao buscar cartões para desbloquear!', 'error', true);
        });
    }

    DesbloquearCartao(canal, area){
        console.log(canal + ' - ' + area);
        this.showSpinner();

        desbloquearCartao({
            idEmpresa: this.unidadeNegocio, 
            sistema: canal, 
            canal: canal, 
            area: area,
            cpf: this.cpf.replaceAll('.', '').replaceAll('-', ''), 
            numeroConta: this.numeroConta, 
            numeroCartaoSerno: this.numeroSerno, 
            novoStatus: this.newValueStatus
        }).then(result => {
            if (result) {
                this.CreateCase();
            }else{
                this.showToast('Erro', 'Não foi possivel desbloquear o Cartão!', 'error', true);
            }
        }).catch( error => {
            console.log('Erro debloquearCartao: '+ error.body.message);
            this.showToast('Erro', 'Houve um erro ao desbloquear o Cartão!', 'error', true);
        })
    }
//#endregion 

//#region ########## INTERAÇÕES COM USUÁRIO ##########
    
    showSpinner(){
        this.spinner = true;
    }
    closeSpinner(){
        this.spinner = false;
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

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
//#endregion 
}